import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:snap_jp_learn_app/sync/change_journal.dart';

void main() {
  group('ChangeJournal', () {
    late ChangeJournal journal;

    setUpAll(() async {
      await setUpTestHive();
    });

    setUp(() async {
      journal = ChangeJournal();
      await journal.initialize();
    });

    tearDown(() async {
      await journal.close();
    });

    tearDownAll(() async {
      await tearDownTestHive();
    });

    test('should add entry successfully', () async {
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'test_id',
        operation: ChangeOperation.create,
      );

      final entries = journal.getPendingEntries();
      expect(entries.length, 1);
      expect(entries.first.entityType, 'Post');
      expect(entries.first.entityId, 'test_id');
      expect(entries.first.operation, ChangeOperation.create);
    });

    test('should get entries sorted by timestamp', () async {
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'id1',
        operation: ChangeOperation.create,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await journal.addEntry(
        entityType: 'Post',
        entityId: 'id2',
        operation: ChangeOperation.update,
      );

      final entries = journal.getPendingEntries();
      expect(entries.length, 2);
      expect(entries.first.entityId, 'id1');
      expect(entries.last.entityId, 'id2');
    });

    test('should remove entry after processing', () async {
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'test_id',
        operation: ChangeOperation.create,
      );

      final entries = journal.getPendingEntries();
      expect(entries.length, 1);

      await journal.removeEntry(entries.first.id);

      final remainingEntries = journal.getPendingEntries();
      expect(remainingEntries.length, 0);
    });

    test('should increment attempt count', () async {
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'test_id',
        operation: ChangeOperation.create,
      );

      final entries = journal.getPendingEntries();
      expect(entries.first.attempt, 0);

      await journal.incrementAttempt(entries.first.id);

      final updatedEntries = journal.getPendingEntries();
      expect(updatedEntries.first.attempt, 1);
    });

    test('should get entries for specific entity', () async {
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.create,
      );

      await journal.addEntry(
        entityType: 'SrsCard',
        entityId: 'card1',
        operation: ChangeOperation.create,
      );

      await journal.addEntry(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.update,
      );

      final postEntries = journal.getEntriesForEntity('Post', 'post1');
      expect(postEntries.length, 2);

      final cardEntries = journal.getEntriesForEntity('SrsCard', 'card1');
      expect(cardEntries.length, 1);
    });

    test('should provide statistics', () async {
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'id1',
        operation: ChangeOperation.create,
      );

      await journal.addEntry(
        entityType: 'Post',
        entityId: 'id2',
        operation: ChangeOperation.update,
      );

      final stats = journal.getStatistics();
      expect(stats['total'], 2);
      expect(stats['create'], 1);
      expect(stats['update'], 1);
    });

    test('should handle metadata correctly', () async {
      final metadata = {
        'imagePath': 'test.jpg',
        'rawText': 'Test content',
      };

      await journal.addEntry(
        entityType: 'Post',
        entityId: 'test_id',
        operation: ChangeOperation.create,
        metadata: metadata,
      );

      final entries = journal.getPendingEntries();
      expect(entries.first.metadata, metadata);
    });
  });

  group('ChangeJournalEntry', () {
    test('should create entry with correct properties', () {
      final entry = ChangeJournalEntry(
        id: 'test_id',
        entityType: 'Post',
        entityId: 'entity_id',
        operation: ChangeOperation.create,
        timestamp: DateTime.now(),
        attempt: 0,
      );

      expect(entry.id, 'test_id');
      expect(entry.entityType, 'Post');
      expect(entry.entityId, 'entity_id');
      expect(entry.operation, ChangeOperation.create);
      expect(entry.attempt, 0);
    });

    test('should copy with new values', () {
      final original = ChangeJournalEntry(
        id: 'test_id',
        entityType: 'Post',
        entityId: 'entity_id',
        operation: ChangeOperation.create,
        timestamp: DateTime.now(),
        attempt: 0,
      );

      final copied = original.copyWith(
        attempt: 1,
        operation: ChangeOperation.update,
      );

      expect(copied.id, original.id);
      expect(copied.attempt, 1);
      expect(copied.operation, ChangeOperation.update);
    });

    test('should implement equality correctly', () {
      final timestamp = DateTime.now();
      final entry1 = ChangeJournalEntry(
        id: 'test_id',
        entityType: 'Post',
        entityId: 'entity_id',
        operation: ChangeOperation.create,
        timestamp: timestamp,
        attempt: 0,
      );

      final entry2 = ChangeJournalEntry(
        id: 'test_id',
        entityType: 'Post',
        entityId: 'entity_id',
        operation: ChangeOperation.create,
        timestamp: timestamp,
        attempt: 0,
      );

      expect(entry1, equals(entry2));
      expect(entry1.hashCode, equals(entry2.hashCode));
    });
  });
}
