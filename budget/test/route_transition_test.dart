import 'package:budget/widgets/util/afterRouteTransition.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Entry extends StatefulWidget {
  const _Entry(this.onReady);
  final VoidCallback onReady;

  @override
  State<_Entry> createState() => _EntryState();
}

class _EntryState extends State<_Entry> {
  late final VoidCallback cancel;

  @override
  void initState() {
    super.initState();
    cancel = afterRouteTransition(context, widget.onReady);
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('entry'));
}

void main() {
  testWidgets('container reparenting finishes before opening input',
      (tester) async {
    int starts = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OpenContainer<void>(
          tappable: false,
          transitionDuration: const Duration(milliseconds: 400),
          closedBuilder: (_, open) => TextButton(
            onPressed: open,
            child: const Text('open'),
          ),
          openBuilder: (_, __) => _Entry(() => starts++),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(starts, 0);
    await tester.pump(const Duration(milliseconds: 251));
    await tester.pump();
    expect(starts, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('input starts once after route entrance, not during it',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    int starts = 0;
    await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const Scaffold()));
    final route = PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _Entry(() => starts++),
    );
    navigator.currentState!.push(route);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(starts, 0);
    await tester.pump(const Duration(milliseconds: 151));
    await tester.pump();
    expect(starts, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(starts, 1);
  });

  testWidgets('back during entrance never opens an orphan input sheet',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    int starts = 0;
    await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const Scaffold()));
    navigator.currentState!.push(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _Entry(() => starts++),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(starts, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero duration route does not add an artificial wait',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    int starts = 0;
    await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const Scaffold()));
    navigator.currentState!.push(PageRouteBuilder<void>(
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => _Entry(() => starts++),
    ));
    await tester.pump();
    expect(starts, 1);
    await tester.pump();
    expect(starts, 1);
  });

  testWidgets('removing owner cancels pending entrance callback',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    int starts = 0;
    await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const Scaffold()));
    final route = PageRouteBuilder<void>(
      transitionDuration: const Duration(seconds: 1),
      pageBuilder: (_, __, ___) => _Entry(() => starts++),
    );
    navigator.currentState!.push(route);
    await tester.pump();
    navigator.currentState!.removeRoute(route);
    await tester.pumpAndSettle();
    expect(starts, 0);
    expect(tester.takeException(), isNull);
  });
}
