import 'package:flutter/material.dart';

/// Placeholder for the journal entry editor.
class JournalEntryScreen extends StatelessWidget {
  /// Optional entry ID for editing an existing entry.
  final String? entryId;

  const JournalEntryScreen({super.key, this.entryId});

  @override
  Widget build(BuildContext context) {
    final isEditing = entryId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
      ),
      body: Center(
        child: Text(
          isEditing
              ? 'Editing entry $entryId — Phase 4'
              : 'Entry Editor — Phase 4',
        ),
      ),
    );
  }
}
