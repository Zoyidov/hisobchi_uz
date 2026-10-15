import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/app_file.dart';
import '../../theme/app_colors.dart';
import '../feedback/app_snackbar.dart';

class AppFilePreview extends StatelessWidget {
  const AppFilePreview({super.key, required this.files});
  final List<AppFile> files;

  bool _isImage(AppFile file) => RegExp(
    r'\.(jpe?g|png|webp|gif|heic|heif)$',
    caseSensitive: false,
  ).hasMatch(Uri.tryParse(file.url)?.path ?? file.name ?? '');

  Future<void> _open(BuildContext context, AppFile file) async {
    if (_isImage(file)) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(file.name ?? 'Rasm'),
            ),
            body: Center(
              child: InteractiveViewer(
                minScale: .5,
                maxScale: 5,
                child: _RemoteImage(file: file, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(file.url);
    var opened = false;
    if (uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Exception {
        opened = false;
      }
    }
    if (!opened && context.mounted) {
      AppSnackbar.error(
        context,
        'Faylni ochib bo‘lmadi. Qayta urinib ko‘ring.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Biriktirilgan fayllar (${files.length})',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 360 ? 2 : 3;
          final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final file in files)
                SizedBox(
                  width: width,
                  height: width,
                  child: Semantics(
                    button: true,
                    label:
                        file.name ??
                        (_isImage(file) ? 'Rasmni ochish' : 'Faylni ochish'),
                    child: Material(
                      color: context.colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _open(context, file),
                        child: _isImage(file)
                            ? _RemoteImage(file: file, fit: BoxFit.cover)
                            : Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: context.colors.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      file.name ?? 'Fayl #${file.id}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _RemoteImage extends StatefulWidget {
  const _RemoteImage({required this.file, required this.fit});
  final AppFile file;
  final BoxFit fit;
  @override
  State<_RemoteImage> createState() => _RemoteImageState();
}

class _RemoteImageState extends State<_RemoteImage> {
  int _attempt = 0;
  @override
  Widget build(BuildContext context) => Image.network(
    widget.file.url,
    key: ValueKey(_attempt),
    fit: widget.fit,
    width: double.infinity,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
    errorBuilder: (context, _, _) => Center(
      child: IconButton(
        tooltip: 'Rasm yuklanmadi. Qayta urinish',
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : context.colors.textSecondary,
        icon: const Icon(Icons.refresh_rounded),
        onPressed: () async {
          await NetworkImage(widget.file.url).evict();
          if (mounted) setState(() => _attempt++);
        },
      ),
    ),
  );
}
