import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philiprehberger_state_inspector/state_inspector.dart';

void main() {
  group('StateEntry', () {
    test('creates with all fields', () {
      final now = DateTime.now();
      final entry = StateEntry(
        timestamp: now,
        label: 'counter',
        newValue: '1',
        previousValue: '0',
      );

      expect(entry.timestamp, equals(now));
      expect(entry.label, equals('counter'));
      expect(entry.newValue, equals('1'));
      expect(entry.previousValue, equals('0'));
    });

    test('creates without previousValue', () {
      final entry = StateEntry(
        timestamp: DateTime.now(),
        label: 'theme',
        newValue: 'dark',
      );

      expect(entry.previousValue, isNull);
      expect(entry.newValue, equals('dark'));
    });
  });

  group('StateLogger', () {
    late StateLogger logger;

    setUp(() {
      logger = StateLogger();
    });

    test('starts empty', () {
      expect(logger.count, equals(0));
      expect(logger.all, isEmpty);
    });

    test('add records an entry', () {
      logger.add(label: 'counter', newValue: '1');

      expect(logger.count, equals(1));
      expect(logger.all.first.label, equals('counter'));
      expect(logger.all.first.newValue, equals('1'));
    });

    test('add records previousValue', () {
      logger.add(label: 'counter', newValue: '2', previousValue: '1');

      expect(logger.all.first.previousValue, equals('1'));
    });

    test('all returns unmodifiable list', () {
      logger.add(label: 'a', newValue: '1');
      final entries = logger.all;

      expect(() => entries.add(StateEntry(
        timestamp: DateTime.now(),
        label: 'b',
        newValue: '2',
      )), throwsUnsupportedError);
    });

    test('recent returns last n entries', () {
      for (var i = 0; i < 10; i++) {
        logger.add(label: 'counter', newValue: '$i');
      }

      final recent = logger.recent(3);
      expect(recent.length, equals(3));
      expect(recent.first.newValue, equals('7'));
      expect(recent.last.newValue, equals('9'));
    });

    test('recent returns all when n exceeds count', () {
      logger.add(label: 'a', newValue: '1');
      logger.add(label: 'b', newValue: '2');

      expect(logger.recent(10).length, equals(2));
    });

    test('filterByLabel returns matching entries', () {
      logger.add(label: 'counter', newValue: '1');
      logger.add(label: 'theme', newValue: 'dark');
      logger.add(label: 'counter', newValue: '2');

      final filtered = logger.filterByLabel('counter');
      expect(filtered.length, equals(2));
      expect(filtered.every((e) => e.label == 'counter'), isTrue);
    });

    test('filterByLabel returns empty for unknown label', () {
      logger.add(label: 'counter', newValue: '1');

      expect(logger.filterByLabel('unknown'), isEmpty);
    });

    test('clear removes all entries', () {
      logger.add(label: 'a', newValue: '1');
      logger.add(label: 'b', newValue: '2');
      logger.clear();

      expect(logger.count, equals(0));
      expect(logger.all, isEmpty);
    });

    test('count returns number of entries', () {
      logger.add(label: 'a', newValue: '1');
      logger.add(label: 'b', newValue: '2');
      logger.add(label: 'c', newValue: '3');

      expect(logger.count, equals(3));
    });

    test('export formats entries with previousValue', () {
      logger.add(label: 'counter', newValue: '1', previousValue: '0');
      final output = logger.export();

      expect(output, contains('counter: 0 -> 1'));
    });

    test('export formats entries without previousValue', () {
      logger.add(label: 'theme', newValue: 'dark');
      final output = logger.export();

      expect(output, contains('theme: dark'));
      expect(output, isNot(contains('->')));
    });
  });

  group('RebuildTracker', () {
    late RebuildTracker tracker;

    setUp(() {
      tracker = RebuildTracker();
    });

    test('starts with zero total', () {
      expect(tracker.total, equals(0));
    });

    test('increment increases count', () {
      tracker.increment('MyWidget');

      expect(tracker.count('MyWidget'), equals(1));
    });

    test('increment accumulates', () {
      tracker.increment('MyWidget');
      tracker.increment('MyWidget');
      tracker.increment('MyWidget');

      expect(tracker.count('MyWidget'), equals(3));
    });

    test('count returns 0 for untracked widget', () {
      expect(tracker.count('Unknown'), equals(0));
    });

    test('topRebuilders returns sorted descending', () {
      tracker.increment('A');
      tracker.increment('B');
      tracker.increment('B');
      tracker.increment('C');
      tracker.increment('C');
      tracker.increment('C');

      final top = tracker.topRebuilders(3);
      expect(top.length, equals(3));
      expect(top[0].key, equals('C'));
      expect(top[0].value, equals(3));
      expect(top[1].key, equals('B'));
      expect(top[1].value, equals(2));
      expect(top[2].key, equals('A'));
      expect(top[2].value, equals(1));
    });

    test('topRebuilders limits to n', () {
      tracker.increment('A');
      tracker.increment('B');
      tracker.increment('C');

      expect(tracker.topRebuilders(2).length, equals(2));
    });

    test('reset clears all counts', () {
      tracker.increment('A');
      tracker.increment('B');
      tracker.reset();

      expect(tracker.count('A'), equals(0));
      expect(tracker.count('B'), equals(0));
      expect(tracker.total, equals(0));
    });

    test('total sums all counts', () {
      tracker.increment('A');
      tracker.increment('A');
      tracker.increment('B');

      expect(tracker.total, equals(3));
    });
  });

  group('StateInspector', () {
    late StateInspector inspector;

    setUp(() {
      inspector = StateInspector.instance;
      inspector.reset();
    });

    test('logState adds entry to logger', () {
      inspector.logState('counter', '1', previous: '0');

      expect(inspector.logger.count, equals(1));
      expect(inspector.logger.all.first.label, equals('counter'));
      expect(inspector.logger.all.first.newValue, equals('1'));
      expect(inspector.logger.all.first.previousValue, equals('0'));
    });

    test('trackRebuild increments tracker', () {
      inspector.trackRebuild('MyWidget');
      inspector.trackRebuild('MyWidget');

      expect(inspector.tracker.count('MyWidget'), equals(2));
    });

    test('show sets isVisible to true', () {
      inspector.show();

      expect(inspector.isVisible, isTrue);
    });

    test('hide sets isVisible to false', () {
      inspector.show();
      inspector.hide();

      expect(inspector.isVisible, isFalse);
    });

    test('toggle flips visibility', () {
      expect(inspector.isVisible, isFalse);
      inspector.toggle();
      expect(inspector.isVisible, isTrue);
      inspector.toggle();
      expect(inspector.isVisible, isFalse);
    });

    test('reset clears logger and tracker', () {
      inspector.logState('counter', '1');
      inspector.trackRebuild('MyWidget');
      inspector.show();
      inspector.reset();

      expect(inspector.logger.count, equals(0));
      expect(inspector.tracker.total, equals(0));
      expect(inspector.isVisible, isFalse);
    });
  });

  group('InspectorOverlay', () {
    testWidgets('renders without errors', (tester) async {
      final logger = StateLogger();
      final tracker = RebuildTracker();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
            ),
          ),
        ),
      );

      expect(find.text('State Inspector'), findsOneWidget);
      expect(find.text('State'), findsOneWidget);
      expect(find.text('Rebuilds'), findsOneWidget);
    });

    testWidgets('shows empty state message', (tester) async {
      final logger = StateLogger();
      final tracker = RebuildTracker();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
            ),
          ),
        ),
      );

      expect(find.text('No state changes'), findsOneWidget);
    });

    testWidgets('shows state entries', (tester) async {
      final logger = StateLogger();
      logger.add(label: 'counter', newValue: '5');
      final tracker = RebuildTracker();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
            ),
          ),
        ),
      );

      expect(find.text('counter: 5'), findsOneWidget);
    });

    testWidgets('shows close button when onClose provided', (tester) async {
      var closed = false;
      final logger = StateLogger();
      final tracker = RebuildTracker();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      expect(closed, isTrue);
    });
  });
}
