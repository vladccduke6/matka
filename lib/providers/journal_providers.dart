import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import '../repositories/journal_repository.dart';
import 'journey_providers.dart' show uuidProvider;

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final uuid = ref.watch(uuidProvider);
  return JournalRepository(idFactory: uuid.v4);
});

final journalEntriesProvider =
    StateNotifierProvider.family<JournalListNotifier, List<JournalEntry>, String>((ref, journeyId) {
  final repo = ref.watch(journalRepositoryProvider);
  return JournalListNotifier(repo, journeyId);
});

class JournalListNotifier extends StateNotifier<List<JournalEntry>> {
  JournalListNotifier(this._repository, this.journeyId) : super(const []) {
    _load();
  }

  final JournalRepository _repository;
  final String journeyId;

  Future<void> _load() async {
    final entries = await _repository.getEntries(journeyId);
    state = entries;
  }

  Future<void> refresh() async => _load();

  Future<void> addEntry({
    required String text,
    required List<File> imageFiles,
  }) async {
    final entry = await _repository.addEntry(
      journeyId: journeyId,
      text: text,
      imageFiles: imageFiles,
    );
    state = ([entry] + state)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteEntry(String entryId) async {
    await _repository.deleteEntry(journeyId, entryId);
    state = state.where((e) => e.id != entryId).toList();
  }

  Future<Uint8List> buildPdf() => _repository.buildPdf(journeyId);

  Future<List<String>> collectImagePaths() => _repository.collectImagePaths(journeyId);
}
