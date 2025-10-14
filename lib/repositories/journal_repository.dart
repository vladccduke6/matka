import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/journal_entry.dart';

class JournalRepository {
  JournalRepository({required String Function() idFactory}) : _idFactory = idFactory;

  final String Function() _idFactory;
  final Map<String, List<JournalEntry>> _entriesByJourney = {};
  bool _loaded = false;

  Future<Directory> _documentsDir() => getApplicationDocumentsDirectory();

  Future<File> _storeFile() async {
    final dir = await _documentsDir();
    return File(p.join(dir.path, 'journal_entries.json'));
  }

  Future<Directory> _imagesDir(String journeyId) async {
    final dir = await _documentsDir();
    final imagesDir = Directory(p.join(dir.path, 'journal_images', journeyId));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final file = await _storeFile();
    if (await file.exists()) {
      final raw = await file.readAsString();
      if (raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final journeyId = entry.key;
          final list = (entry.value as List<dynamic>)
              .map((e) => JournalEntry.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _entriesByJourney[journeyId] = list;
        }
      }
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final file = await _storeFile();
    final map = <String, dynamic>{};
    for (final entry in _entriesByJourney.entries) {
      map[entry.key] = entry.value.map((e) => e.toMap()).toList();
    }
    await file.writeAsString(jsonEncode(map));
  }

  Future<List<JournalEntry>> getEntries(String journeyId) async {
    await _ensureLoaded();
    final list = _entriesByJourney[journeyId];
    if (list == null) return const [];
    return List.unmodifiable(list);
  }

  Future<JournalEntry> addEntry({
    required String journeyId,
    required String text,
    required List<File> imageFiles,
    DateTime? createdAt,
  }) async {
    await _ensureLoaded();
    final imagesDir = await _imagesDir(journeyId);
    final storedPaths = <String>[];
    for (final file in imageFiles) {
      final ext = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
      final destPath = p.join(imagesDir.path, '${_idFactory()}$ext');
      await file.copy(destPath);
      storedPaths.add(destPath);
    }
    final entry = JournalEntry(
      id: _idFactory(),
      journeyId: journeyId,
      text: text,
      imagePaths: storedPaths,
      createdAt: createdAt ?? DateTime.now(),
    );
    final list = _entriesByJourney.putIfAbsent(journeyId, () => <JournalEntry>[]);
    list.add(entry);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _persist();
    return entry;
  }

  Future<void> deleteEntry(String journeyId, String entryId) async {
    await _ensureLoaded();
    final list = _entriesByJourney[journeyId];
    if (list == null) return;
    final originalLength = list.length;
    final removedEntries = list.where((e) => e.id == entryId).toList();
    list.removeWhere((e) => e.id == entryId);
    if (originalLength != list.length) {
      for (final entry in removedEntries) {
        for (final path in entry.imagePaths) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
      await _persist();
    }
  }

  Future<void> importEntries(String journeyId, List<JournalEntry> entries) async {
    await _ensureLoaded();
    final list = _entriesByJourney.putIfAbsent(journeyId, () => <JournalEntry>[]);
    list
      ..clear()
      ..addAll(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _persist();
  }

  Future<Uint8List> buildPdf(String journeyId) async {
    await _ensureLoaded();
    final entries = List<JournalEntry>.from(_entriesByJourney[journeyId] ?? const [])
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final doc = pw.Document();

    final content = <pw.Widget>[];
    for (final entry in entries) {
      final imageWidgets = <pw.Widget>[];
      for (final path in entry.imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          imageWidgets.add(
            pw.Container(
              width: 200,
              child: pw.Image(
                pw.MemoryImage(bytes),
                fit: pw.BoxFit.cover,
              ),
            ),
          );
        }
      }

      content.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              entry.createdAt.toLocal().toString(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            if (entry.text.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4, bottom: 8),
                child: pw.Text(entry.text),
              ),
            if (imageWidgets.isNotEmpty)
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imageWidgets,
              ),
            pw.SizedBox(height: 24),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        build: (context) => content,
      ),
    );

    return doc.save();
  }

  Future<List<String>> collectImagePaths(String journeyId) async {
    await _ensureLoaded();
    return _entriesByJourney[journeyId]
            ?.expand((entry) => entry.imagePaths)
            .toList(growable: false) ??
        const [];
  }
}
