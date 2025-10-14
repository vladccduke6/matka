import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/journey.dart';
import 'package:matka/providers/journey_providers.dart';

class AddJourneyDialog extends ConsumerStatefulWidget {
  const AddJourneyDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const AddJourneyDialog(),
    );
  }

  @override
  ConsumerState<AddJourneyDialog> createState() => _AddJourneyDialogState();
}

class _AddJourneyDialogState extends ConsumerState<AddJourneyDialog> {
  final _titleController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Adjust end if earlier than start
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEnd() async {
    final base = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? base,
      firstDate: base,
      lastDate: DateTime(base.year + 5),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String? _validate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return 'Title is required';
    if (_startDate == null) return 'Start date is required';
    if (_endDate == null) return 'End date is required';
    if (_endDate!.isBefore(_startDate!)) {
      return 'End date must be on or after start date';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final uuid = ref.read(uuidProvider);
    final repo = ref.read(journeyRepositoryProvider);
    final nav = Navigator.of(context);

    final journey = Journey(
      id: uuid.v4(),
      title: _titleController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      createdAt: DateTime.now(),
    );

    try {
      await repo.addJourney(journey);
      // Close with success
      nav.pop(true);
    } catch (_) {
      setState(() => _error = 'Failed to add journey');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Journey'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStart,
                    child: Text(
                      _startDate == null
                          ? 'Pick start date'
                          : 'Start: ${_startDate!.toLocal().toString().split(' ').first}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEnd,
                    child: Text(
                      _endDate == null
                          ? 'Pick end date'
                          : 'End: ${_endDate!.toLocal().toString().split(' ').first}',
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
