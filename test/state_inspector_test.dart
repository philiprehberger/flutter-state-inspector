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

    test('exportJson returns list of maps', () {
      logger.add(label: 'counter', newValue: '1', previousValue: '0');
      logger.add(label: 'theme', newValue: 'dark');

      final json = logger.exportJson();
      expect(json.length, equals(2));
      expect(json[0]['label'], equals('counter'));
      expect(json[0]['newValue'], equals('1'));
      expect(json[0]['previousValue'], equals('0'));
      expect(json[0]['timestamp'], isA<String>());
      expect(json[1]['label'], equals('theme'));
      expect(json[1]['previousValue'], isNull);
    });

    test('exportCsv returns CSV with header and rows', () {
      logger.add(label: 'counter', newValue: '1', previousValue: '0');
      logger.add(label: 'theme', newValue: 'dark');

      final csv = logger.exportCsv();
      final lines = csv.trim().split('\n');
      expect(lines[0], equals('timestamp,label,new_value,previous_value'));
      expect(lines[1], contains('counter,1,0'));
      expect(lines[2], contains('theme,dark,'));
    });

    test('exportCsv escapes values containing commas', () {
      logger.add(label: 'data', newValue: 'a,b', previousValue: 'x,y');

      final csv = logger.exportCsv();
      final lines = csv.trim().split('\n');
      expect(lines[1], contains('"a,b"'));
      expect(lines[1], contains('"x,y"'));
    });

    test('diffSince returns empty for fresh logger', () {
      expect(logger.diffSince(const Duration(seconds: 1)), isEmpty);
    });

    test('diffSince includes recent entries', () {
      logger.add(label: 'a', newValue: '1');
      logger.add(label: 'b', newValue: '2');

      final recent = logger.diffSince(const Duration(seconds: 5));
      expect(recent.length, equals(2));
      expect(recent[0].label, equals('a'));
      expect(recent[1].label, equals('b'));
    });

    test('diffSince filters out old entries', () {
      // Inject an old entry directly using add then mutate... we can't mutate
      // timestamps, so instead add via delayed insertion using a small window.
      logger.add(label: 'old', newValue: '1');
      // Wait briefly so the entry falls outside a tiny window.
      final cutoff = DateTime.now();
      // Spin until at least 50ms has passed.
      while (DateTime.now().difference(cutoff) <
          const Duration(milliseconds: 50)) {
        // busy-wait
      }
      logger.add(label: 'new', newValue: '2');

      final recent = logger.diffSince(const Duration(milliseconds: 25));
      expect(recent.length, equals(1));
      expect(recent.first.label, equals('new'));
    });

    test('diffSince preserves chronological order', () {
      logger.add(label: 'first', newValue: '1');
      logger.add(label: 'second', newValue: '2');
      logger.add(label: 'third', newValue: '3');

      final recent = logger.diffSince(const Duration(minutes: 1));
      expect(recent.map((e) => e.label).toList(),
          equals(['first', 'second', 'third']));
    });
  });

  group('PerformanceMetrics', () {
    late PerformanceMetrics metrics;

    setUp(() {
      metrics = PerformanceMetrics();
    });

    test('starts with zero values', () {
      expect(metrics.frameCount, equals(0));
      expect(metrics.totalFrameTime, equals(Duration.zero));
      expect(metrics.peakFrameTime, equals(Duration.zero));
      expect(metrics.averageFrameTimeMs, equals(0));
      expect(metrics.estimatedFps, equals(0));
    });

    test('recordFrame updates counts', () {
      metrics.recordFrame(const Duration(milliseconds: 16));

      expect(metrics.frameCount, equals(1));
      expect(metrics.totalFrameTime, equals(const Duration(milliseconds: 16)));
    });

    test('averageFrameTimeMs calculation', () {
      metrics.recordFrame(const Duration(milliseconds: 10));
      metrics.recordFrame(const Duration(milliseconds: 20));

      expect(metrics.averageFrameTimeMs, equals(15.0));
    });

    test('peakFrameTimeMs tracks max', () {
      metrics.recordFrame(const Duration(milliseconds: 10));
      metrics.recordFrame(const Duration(milliseconds: 30));
      metrics.recordFrame(const Duration(milliseconds: 20));

      expect(metrics.peakFrameTimeMs, equals(30.0));
    });

    test('estimatedFps calculation', () {
      metrics.recordFrame(const Duration(milliseconds: 10));
      metrics.recordFrame(const Duration(milliseconds: 10));

      expect(metrics.estimatedFps, equals(100.0));
    });

    test('reset zeros everything', () {
      metrics.recordFrame(const Duration(milliseconds: 16));
      metrics.recordFrame(const Duration(milliseconds: 20));
      metrics.reset();

      expect(metrics.frameCount, equals(0));
      expect(metrics.totalFrameTime, equals(Duration.zero));
      expect(metrics.peakFrameTime, equals(Duration.zero));
      expect(metrics.averageFrameTimeMs, equals(0));
      expect(metrics.estimatedFps, equals(0));
    });

    test('toJson exports metrics as map', () {
      metrics.recordFrame(const Duration(milliseconds: 10));
      metrics.recordFrame(const Duration(milliseconds: 20));

      final json = metrics.toJson();
      expect(json['frameCount'], equals(2));
      expect(json['averageFrameTimeMs'], equals(15.0));
      expect(json['peakFrameTimeMs'], equals(20.0));
      expect(json['estimatedFps'], closeTo(66.67, 0.01));
      expect(json['totalFrameTimeMs'], equals(30.0));
    });

    test('measureMark returns positive duration between two marks', () {
      metrics.recordMark('start');
      // Busy-wait briefly to ensure non-zero elapsed time.
      final waitFrom = DateTime.now();
      while (DateTime.now().difference(waitFrom) <
          const Duration(milliseconds: 5)) {
        // busy-wait
      }
      metrics.recordMark('end');

      final elapsed = metrics.measureMark('start', 'end');
      expect(elapsed, greaterThan(Duration.zero));
    });

    test('measureMark returns zero when start mark is missing', () {
      metrics.recordMark('end');
      expect(
        metrics.measureMark('missing', 'end'),
        equals(Duration.zero),
      );
    });

    test('measureMark returns zero when end mark is missing', () {
      metrics.recordMark('start');
      expect(
        metrics.measureMark('start', 'missing'),
        equals(Duration.zero),
      );
    });

    test('measureMark returns zero when both marks are missing', () {
      expect(
        metrics.measureMark('a', 'b'),
        equals(Duration.zero),
      );
    });

    test('reset clears recorded marks', () {
      metrics.recordMark('start');
      metrics.recordMark('end');
      metrics.reset();

      expect(
        metrics.measureMark('start', 'end'),
        equals(Duration.zero),
      );
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

    test('trackFrame delegates to performance', () {
      inspector.trackFrame(const Duration(milliseconds: 16));
      inspector.trackFrame(const Duration(milliseconds: 20));

      expect(inspector.performance.frameCount, equals(2));
      expect(inspector.performance.peakFrameTimeMs, equals(20.0));
    });

    test('reset clears logger, tracker, and performance', () {
      inspector.logState('counter', '1');
      inspector.trackRebuild('MyWidget');
      inspector.trackFrame(const Duration(milliseconds: 16));
      inspector.show();
      inspector.reset();

      expect(inspector.logger.count, equals(0));
      expect(inspector.tracker.total, equals(0));
      expect(inspector.performance.frameCount, equals(0));
      expect(inspector.isVisible, isFalse);
    });

    test('logState notifies listeners', () {
      var notified = false;
      inspector.addListener(() => notified = true);
      inspector.logState('counter', '1');

      expect(notified, isTrue);
      inspector.removeListener(() {});
    });

    test('trackRebuild notifies listeners', () {
      var count = 0;
      void listener() => count++;
      inspector.addListener(listener);
      inspector.trackRebuild('MyWidget');

      expect(count, equals(1));
      inspector.removeListener(listener);
    });

    test('trackFrame notifies listeners', () {
      var count = 0;
      void listener() => count++;
      inspector.addListener(listener);
      inspector.trackFrame(const Duration(milliseconds: 16));

      expect(count, equals(1));
      inspector.removeListener(listener);
    });

    test('show notifies listeners', () {
      var count = 0;
      void listener() => count++;
      inspector.addListener(listener);
      inspector.show();

      expect(count, equals(1));
      inspector.removeListener(listener);
    });

    test('hide notifies listeners', () {
      var count = 0;
      void listener() => count++;
      inspector.addListener(listener);
      inspector.hide();

      expect(count, equals(1));
      inspector.removeListener(listener);
    });

    test('toggle notifies listeners', () {
      var count = 0;
      void listener() => count++;
      inspector.addListener(listener);
      inspector.toggle();

      expect(count, equals(1));
      inspector.removeListener(listener);
    });

    test('reset notifies listeners', () {
      var count = 0;
      void listener() => count++;
      inspector.addListener(listener);
      inspector.reset();

      expect(count, equals(1));
      inspector.removeListener(listener);
    });
  });

  group('InspectorOverlay', () {
    testWidgets('renders without errors', (tester) async {
      final logger = StateLogger();
      final tracker = RebuildTracker();
      final performance = PerformanceMetrics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
              performance: performance,
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
      final performance = PerformanceMetrics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
              performance: performance,
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
      final performance = PerformanceMetrics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
              performance: performance,
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
      final performance = PerformanceMetrics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
              performance: performance,
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

    testWidgets('shows Perf tab', (tester) async {
      final logger = StateLogger();
      final tracker = RebuildTracker();
      final performance = PerformanceMetrics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorOverlay(
              logger: logger,
              tracker: tracker,
              performance: performance,
            ),
          ),
        ),
      );

      expect(find.text('Perf'), findsOneWidget);
    });
  });

  group('DraggableOverlay', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DraggableOverlay(
              child: Text('Debug Panel'),
            ),
          ),
        ),
      );

      expect(find.text('Debug Panel'), findsOneWidget);
    });
  });
}
