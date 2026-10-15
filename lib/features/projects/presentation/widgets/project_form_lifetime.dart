import 'package:flutter/material.dart';

/// Keeps controllers alive until the modal closing animation has finished.
class ProjectFormLifetime extends StatefulWidget {
  const ProjectFormLifetime({
    super.key,
    required this.resources,
    required this.child,
  });
  final List<ChangeNotifier> resources;
  final Widget child;
  @override
  State<ProjectFormLifetime> createState() => _ProjectFormLifetimeState();
}

class _ProjectFormLifetimeState extends State<ProjectFormLifetime> {
  @override
  void dispose() {
    for (final resource in widget.resources) {
      resource.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
