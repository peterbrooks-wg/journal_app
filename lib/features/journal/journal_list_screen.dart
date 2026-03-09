import 'package:flutter/material.dart';

/// Placeholder for the journal entry list.
class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: const Center(
        child: Text('Journal List — Phase 4'),
      ),
    );
  }
}
