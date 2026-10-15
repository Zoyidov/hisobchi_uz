import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../di/injector.dart';
import '../../domain/entities/app_file.dart';
import '../../services/file_upload_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../feedback/app_snackbar.dart';
import '../sheets/app_bottom_sheet.dart';

const _maxFileSizeBytes = 5 * 1024 * 1024;
const _allowedExtensions = [
  'jpg',
  'jpeg',
  'png',
  'webp',
  'pdf',
  'doc',
  'docx',
  'xls',
  'xlsx',
  'txt',
];

/// Fayl biriktirish — Kamera/Galereya/Fayl, avval alohida yuklanadi
/// (MOBILE_APP_TZ.md 4.9, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 84, 167).
class AppFileAttachment extends StatefulWidget {
  const AppFileAttachment({
    super.key,
    required this.onFilesChanged,
    this.initialFiles = const [],
    this.uploadType,
    this.onUploadingChanged,
  });

  final ValueChanged<List<AppFile>> onFilesChanged;
  final List<AppFile> initialFiles;
  final String? uploadType;
  final ValueChanged<bool>? onUploadingChanged;

  @override
  State<AppFileAttachment> createState() => _AppFileAttachmentState();
}

class _AppFileAttachmentState extends State<AppFileAttachment> {
  late List<AppFile> _files = List.of(widget.initialFiles);
  final List<String> _uploadingNames = [];
  final Map<String, File> _failedFiles = {};
  final Map<String, double> _progress = {};
  final Map<int, File> _localFiles = {};

  Future<void> _openPicker() async {
    try {
      await _pickAndUpload();
    } on PlatformException catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Kamera yoki galereyani ochib bo‘lmadi. Qurilma ruxsatlarini tekshiring.',
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Faylni ochib bo‘lmadi. Qayta urinib ko‘ring.',
        );
      }
    }
  }

  Future<void> _pickAndUpload() async {
    final choice = await showAppBottomSheet<String>(
      context,
      title: 'Fayl biriktirish',
      heightFactor: MediaQuery.textScalerOf(context).scale(14) > 20
          ? 0.6
          : 0.35,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Kamera'),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_outlined),
            title: const Text('Galereya'),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: const Text('Fayl'),
            onTap: () => Navigator.pop(context, 'file'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    File? file;
    if (choice == 'camera' || choice == 'gallery') {
      final picked = await ImagePicker().pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null) file = File(picked.path);
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );
      if (result != null && result.files.single.path != null) {
        file = File(result.files.single.path!);
      }
    }
    if (file == null || !mounted) return;
    await _upload(file);
  }

  Future<void> _upload(File file) async {
    if (await file.length() > _maxFileSizeBytes) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Fayl hajmi 5 MB dan katta bo\'lmasligi kerak',
        );
      }
      return;
    }
    final name = file.uri.pathSegments.last;
    if (!mounted || _uploadingNames.contains(name)) return;
    setState(() {
      _failedFiles.remove(name);
      _uploadingNames.add(name);
      _progress[name] = 0;
    });
    widget.onUploadingChanged?.call(true);
    final result = await getIt<FileUploadService>().upload(
      file,
      type: widget.uploadType,
      onProgress: (sent, total) {
        if (mounted && total > 0) {
          setState(() => _progress[name] = (sent / total).clamp(0, 1));
        }
      },
    );
    if (!mounted) return;
    setState(() {
      _uploadingNames.remove(name);
      _progress.remove(name);
      result.when(
        success: (uploaded) {
          _localFiles[uploaded.id] = file;
          _files = [
            ..._files,
            AppFile(
              id: uploaded.id,
              url: uploaded.url,
              name: uploaded.name ?? name,
            ),
          ];
        },
        failure: (_) => _failedFiles[name] = file,
      );
    });
    widget.onUploadingChanged?.call(_uploadingNames.isNotEmpty);
    result.when(
      success: (_) {},
      failure: (failure) => AppSnackbar.error(context, failure.message),
    );
    widget.onFilesChanged(List.unmodifiable(_files));
  }

  bool _isImage(String name) => RegExp(
    r'\.(jpe?g|png|webp|heic|heif)$',
    caseSensitive: false,
  ).hasMatch(name);

  void _preview(AppFile file) {
    final local = _localFiles[file.id];
    if (!_isImage(local?.path ?? file.name ?? file.url)) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (previewContext) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(file.name ?? 'Rasm'),
            actions: [
              IconButton(
                tooltip: 'Rasmni olib tashlash',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  if (mounted) _remove(file);
                  Navigator.of(previewContext).pop();
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: local != null
                  ? Image.file(
                      local,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                      ),
                    )
                  : Image.network(
                      file.url,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _remove(AppFile file) {
    setState(() {
      _files = _files.where((f) => f.id != file.id).toList();
      _localFiles.remove(file.id);
    });
    widget.onFilesChanged(_files);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final f in _files)
              InputChip(
                onPressed: () => _preview(f),
                label: Text(f.name ?? 'fayl_${f.id}'),
                avatar:
                    _localFiles[f.id] != null &&
                        _isImage(_localFiles[f.id]!.path)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          _localFiles[f.id]!,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.image_outlined, size: 16),
                        ),
                      )
                    : const Icon(Icons.insert_drive_file, size: 16),
                onDeleted: () => _remove(f),
              ),
            for (final name in _uploadingNames)
              Chip(
                label: Text(
                  '$name · ${((_progress[name] ?? 0) * 100).round()}%',
                ),
                avatar: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: (_progress[name] ?? 0) > 0 ? _progress[name] : null,
                  ),
                ),
              ),
            for (final name in _failedFiles.keys)
              InputChip(
                onPressed: () => _upload(_failedFiles[name]!),
                label: Text('$name · Qayta urinish'),
                backgroundColor: colors.error.withValues(alpha: 0.1),
                avatar: Icon(
                  Icons.error_outline,
                  size: 16,
                  color: colors.error,
                ),
                onDeleted: () => setState(() => _failedFiles.remove(name)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: _openPicker,
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_file, size: 18, color: colors.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Fayl biriktirish',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
