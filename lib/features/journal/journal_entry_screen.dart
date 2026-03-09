import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../shared/providers/journal_provider.dart';
import 'widgets/mood_picker.dart';

/// Full-screen journal entry editor with auto-save.
class JournalEntryScreen extends ConsumerStatefulWidget {
  final String? entryId;

  const JournalEntryScreen({super.key, this.entryId});

  @override
  ConsumerState<JournalEntryScreen> createState() =>
      _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  String? _entryId;
  Mood? _selectedMood;
  int _wordCount = 0;

  bool get _isEditing => widget.entryId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _entryId = widget.entryId;

    if (_isEditing) {
      final entry =
          ref.read(journalProvider.notifier).getEntry(widget.entryId!);
      if (entry != null) {
        _controller.text = entry.content;
        _selectedMood = Mood.fromTag(entry.moodTag);
        _wordCount = entry.wordCount ?? 0;
      }
    }

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _save();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _save();
    }
  }

  void _onTextChanged() {
    final text = _controller.text;
    final words = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;
    setState(() => _wordCount = words);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 1500),
      _save,
    );
  }

  void _save() {
    final content = _controller.text;
    if (content.trim().isEmpty) return;

    final notifier = ref.read(journalProvider.notifier);
    if (_entryId == null) {
      _entryId = notifier.addEntry(
        content: content,
        moodTag: _selectedMood?.tag,
      );
    } else {
      notifier.updateEntry(
        id: _entryId!,
        content: content,
        moodTag: _selectedMood?.tag,
      );
    }
  }

  Future<void> _pickMood() async {
    final mood = await showMoodPicker(
      context,
      currentMood: _selectedMood,
    );
    if (mood != null) {
      setState(() => _selectedMood = mood);
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateStr = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(dateStr, style: textTheme.titleMedium),
        actions: [
          if (_selectedMood != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _pickMood,
                child: Text(
                  _selectedMood!.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _pickMood,
              icon: const Icon(Icons.mood_outlined),
              tooltip: 'Set mood',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
                style: textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          // Bottom bar with word count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.divider),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '$_wordCount words',
                  style: textTheme.labelSmall,
                ),
                const Spacer(),
                if (_selectedMood == null)
                  TextButton.icon(
                    onPressed: _pickMood,
                    icon: const Icon(Icons.mood_outlined, size: 18),
                    label: const Text('Add mood'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
