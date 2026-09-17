import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'];

/// Fayl biriktirish — Kamera/Galereya/Fayl, avval alohida yuklanadi
/// (MOBILE_APP_TZ.md 4.9, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 84, 167).
class AppFileAttachment extends StatefulWidget {
  const AppFileAttachment({super.key, required this.onFilesChanged, this.initialFiles = const []});

  final ValueChanged<List<AppFile>> onFilesChanged;
  final List<AppFile> initialFiles;

  @override
  State<AppFileAttachment> createState() => _AppFileAttachmentState();
}

class _AppFileAttachmentState extends State<AppFileAttachment> {
  late List<AppFile> _files = List.of(widget.initialFiles);
  final List<String> _uploadingNames = [];
  final List<String> _failedNames = [];

  Future<void> _openPicker() async {
    final choice = await showAppBottomSheet<String>(
      context,
      title: 'Fayl biriktirish',
      heightFactor: 0.35,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Kamera'), onTap: () => Navigator.pop(context, 'camera')),
          ListTile(leading: const Icon(Icons.photo_outlined), title: const Text('Galereya'), onTap: () => Navigator.pop(context, 'gallery')),
          ListTile(leading: const Icon(Icons.insert_drive_file_outlined), title: const Text('Fayl'), onTap: () => Navigator.pop(context, 'file')),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    File? file;
    if (choice == 'camera' || choice == 'gallery') {
      final picked = await ImagePicker().pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
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
      if (mounted) AppSnackbar.error(context, 'Fayl hajmi 5 MB dan katta bo\'lmasligi kerak');
      return;
    }
    final name = file.path.split('/').last;
    setState(() => _uploadingNames.add(name));
    final result = await getIt<FileUploadService>().upload(file);
    if (!mounted) return;
    setState(() {
      _uploadingNames.remove(name);
      result.when(
        success: (uploaded) => _files = [..._files, uploaded],
        failure: (f) => _failedNames.add(name),
      );
    });
    widget.onFilesChanged(_files);
  }

  void _remove(AppFile file) {
    setState(() => _files = _files.where((f) => f.id != file.id).toList());
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
              Chip(
                label: Text(f.name ?? 'fayl_${f.id}'),
                avatar: const Icon(Icons.insert_drive_file, size: 16),
                onDeleted: () => _remove(f),
              ),
            for (final name in _uploadingNames)
              Chip(
                label: Text(name),
                avatar: const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            for (final name in _failedNames)
              Chip(
                label: Text(name),
                backgroundColor: colors.error.withValues(alpha: 0.1),
                avatar: Icon(Icons.error_outline, size: 16, color: colors.error),
                onDeleted: () => setState(() => _failedNames.remove(name)),
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
                Text('Fayl biriktirish', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
