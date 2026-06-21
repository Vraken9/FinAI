import 'package:flutter/material.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Data')),
      body: const Center(
        child: Text('Fitur Import Excel akan hadir di Tahap 2 (Offline Mode)'),
      ),
    );
  }
}
