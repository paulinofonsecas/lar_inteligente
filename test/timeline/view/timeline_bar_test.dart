import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/timeline/cubit/timeline_cubit.dart';
import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:a2ui_vgv_smart_home/timeline/view/timeline_bar.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_live_repository.dart';
import '../../helpers/fake_scenario_repository.dart';

void main() {
  group(TimelineBar, () {
    late FakeScenarioRepository repository;
    late FakeLiveRepository live;
    late TimelineCubit cubit;

    setUp(() {
      repository = FakeScenarioRepository();
      live = FakeLiveRepository();
      cubit = TimelineCubit(repository: repository, live: live);
    });

    tearDown(() => cubit.close());

    Future<void> pump(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(body: TimelineBar()),
        ),
      ),
    );

    Finder button(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is TextButton),
    );

    TextButton textButton(WidgetTester tester, String label) =>
        tester.widget<TextButton>(button(label));

    bool enabled(WidgetTester tester, String label) =>
        textButton(tester, label).onPressed != null;

    bool selected(WidgetTester tester, String label) =>
        textButton(tester, label).style!.backgroundColor!.resolve({}) ==
        AppColors.ink;

    List<String> selectedLabels(WidgetTester tester) => [
      for (final label in ['Manhã', 'Dia', 'Pôr do sol', 'Noite'])
        if (selected(tester, label)) label,
    ];

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    }

    testWidgets('has a button for each part of the day, and no night', (
      tester,
    ) async {
      await pump(tester);

      for (final label in ['Manhã', 'Dia', 'Pôr do sol', 'Noite']) {
        expect(button(label), findsOneWidget);
      }
      expect(find.text('Night'), findsNothing);
      expect(find.byType(TextButton), findsNWidgets(DayPhase.values.length));
    });

    testWidgets('draws each button with the icon of its part of the day', (
      tester,
    ) async {
      await pump(tester);

      for (final phase in DayPhase.values) {
        expect(find.byIcon(phase.icon), findsOneWidget);
      }
    });

    testWidgets('fills the part of the day the time is in', (tester) async {
      await cubit.reset();
      await pump(tester);

      expect(selectedLabels(tester), ['Manhã']);

      cubit.emit(
        cubit.state.copyWith(now: DayPhase.sunset.on(cubit.state.now)),
      );
      await tester.pump();
      expect(selectedLabels(tester), ['Pôr do sol']);

      cubit.emit(
        cubit.state.copyWith(now: DayPhase.evening.on(cubit.state.now)),
      );
      await tester.pump();
      expect(selectedLabels(tester), ['Noite']);
    });

    testWidgets('fills nothing while the clock cannot be reached', (
      tester,
    ) async {
      cubit.emit(cubit.state.copyWith(status: TimelineStatus.failure));
      await pump(tester);

      expect(selectedLabels(tester), isEmpty);
    });

    testWidgets('nothing works while it loads', (tester) async {
      await pump(tester);

      for (final label in ['Manhã', 'Dia', 'Pôr do sol', 'Noite']) {
        expect(enabled(tester, label), isFalse);
      }
      expect(selected(tester, 'Manhã'), isTrue);
    });

    testWidgets('choosing a part of the day takes the time there', (
      tester,
    ) async {
      live.answers = false;
      await cubit.reset();
      await pump(tester);

      await tester.tap(button('Pôr do sol'));
      await tester.pump();

      // Locked until the backend has the clock there, but the part of the day
      // is already the one chosen.
      expect(enabled(tester, 'Dia'), isFalse);
      expect(selectedLabels(tester), ['Pôr do sol']);

      await settle(tester);

      expect(cubit.state.now, DateTime.utc(2026, 10, 10, 17, 40));
      expect(live.moves.last, DateTime.utc(2026, 10, 10, 17, 40));
      expect(selectedLabels(tester), ['Pôr do sol']);
      expect(enabled(tester, 'Dia'), isTrue);
    });

    testWidgets('goes through every part of the day, and back', (
      tester,
    ) async {
      await cubit.reset();
      await pump(tester);
      final expected = {
        'Dia': DateTime.utc(2026, 10, 10, 16, 30),
        'Noite': DateTime.utc(2026, 10, 10, 20, 40),
        'Manhã': DateTime.utc(2026, 10, 10, 7, 30),
      };

      for (final entry in expected.entries) {
        await tester.tap(button(entry.key));
        await settle(tester);

        expect(cubit.state.now, entry.value, reason: entry.key);
        expect(selectedLabels(tester), [entry.key]);
      }
    });

    testWidgets('a failed clock is asked again by any button', (
      tester,
    ) async {
      cubit.emit(cubit.state.copyWith(status: TimelineStatus.failure));
      await pump(tester);

      expect(find.text('Não é possível alcançar o relógio da demo'), findsOneWidget);
      expect(enabled(tester, 'Dia'), isTrue);

      await tester.tap(button('Dia'));
      await tester.pump();
      await tester.pump();

      expect(repository.resets, 1);
      expect(cubit.state.status, TimelineStatus.ready);
    });

    testWidgets('fits a narrow window', (tester) async {
      tester.view
        ..physicalSize = const Size(420, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cubit.reset();
      await pump(tester);

      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byType(TimelineBar)).width,
        lessThanOrEqualTo(420),
      );
      for (final label in ['Manhã', 'Dia', 'Pôr do sol', 'Noite']) {
        expect(
          tester.getRect(button(label)).right,
          lessThanOrEqualTo(420),
          reason: label,
        );
      }
    });

    testWidgets('is labelled for a screen reader', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      expect(find.bySemanticsLabel('Horário da demo'), findsOneWidget);
      semantics.dispose();
    });
  });
}
