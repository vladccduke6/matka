import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../../models/journal_entry.dart';
import '../../providers/journal_providers.dart';

class JournalView extends ConsumerStatefulWidget {
  const JournalView({super.key, required this.journeyId});

  final String journeyId;

  @override
  ConsumerState<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends ConsumerState<JournalView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addEntry() async {
    final noteController = TextEditingController();
    XFile? pickedImage;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: noteController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'What happened?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (pickedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(pickedImage!.path),
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await _picker.pickImage(source: ImageSource.gallery);
                      if (result != null) {
                        setState(() => pickedImage = result);
                      }
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(pickedImage == null ? 'Pick photo' : 'Replace photo'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Save entry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (confirmed != true) return;
    final text = noteController.text.trim();
    final images = <File>[];
    if (pickedImage != null) {
      images.add(File(pickedImage!.path));
    }

    await ref.read(journalEntriesProvider(widget.journeyId).notifier).addEntry(
          text: text,
          imageFiles: images,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal entry added')),
    );
  }

  Future<void> _exportPdf() async {
    final bytes = await ref.read(journalEntriesProvider(widget.journeyId).notifier).buildPdf();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'journey_${widget.journeyId}_journal.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalEntriesProvider(widget.journeyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: _addEntry,
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Add entry'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: entries.isEmpty ? null : _exportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Export PDF'),
            ),
            const Spacer(),
          ],
        ),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No journal entries yet'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final JournalEntry entry = entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.createdAt.toLocal().toString(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    if (entry.text.isNotEmpty)
                      Text(entry.text),
                    if (entry.imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final path in entry.imagePaths)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(path),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
