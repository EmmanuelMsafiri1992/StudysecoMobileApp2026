import 'package:flutter/material.dart';

class ResourceViewerScreen extends StatelessWidget {
  final String resourceId;
  const ResourceViewerScreen({super.key, required this.resourceId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Resource Viewer')),
    body: const Center(child: Text('Resource viewer - PDF/Document display')),
  );
}
