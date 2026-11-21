part of '../dashboard_page.dart';

class _TutorialsSection extends StatelessWidget {
  const _TutorialsSection({required this.tutorials});
  final List<TutorialItem> tutorials;

  Future<void> _open(BuildContext context, TutorialItem tutorial) async {
    final uri = Uri.tryParse(tutorial.url);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tutorialOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) => _DashboardSurface(
    padding: EdgeInsets.zero,
    radius: 18,
    child: ExpansionTile(
      dense: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.only(bottom: 6),
      key: const PageStorageKey('dashboard-tutorials-expanded'),
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Icon(AppIcons.playCircle, color: context.colors.primary),
      title: Text(
        context.l10n.tutorialsCount(tutorials.length),
        style: _DashboardStyle.section(context),
      ),
      children: [
        for (final tutorial in tutorials)
          ListTile(
            leading: Icon(AppIcons.play, color: context.colors.primary),
            title: Text(
              tutorial.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(AppIcons.externalLink, size: 18),
            onTap: () => _open(context, tutorial),
          ),
      ],
    ),
  );
}
