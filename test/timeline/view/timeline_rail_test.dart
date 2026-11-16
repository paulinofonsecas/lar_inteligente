import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/timeline/cubit/timeline_cubit.dart';
import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:a2ui_vgv_smart_home/timeline/view/timeline_rail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui/material_ui.dart' as mui;

import '../../helpers/fake_live_repository.dart';
import '../../helpers/fake_scenario_repository.dart';

void main() {
  group(TimelineRail, () {
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
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...mui.GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(
            body: Center(child: SizedBox(width: 88, child: TimelineRail())),
          ),
        ),
      ),
    );

    Finder button(String label) => find.text(label);

    bool enabled(WidgetTester tester, String label) =>
        tester
            .widget<GestureDetector>(
              find
                  .ancestor(
                    of: button(label),
                    matching: find.byType(GestureDetector),
                  )
                  .first,
            )
            .onTap !=
        null;

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    }

    testWidgets('has a labelled button for each part of the day', (
      tester,
    ) async {
      await pump(tester);

      for (final label in ['Manhã', 'Dia', 'Pôr do sol', 'Noite']) {
        expect(button(label), findsOneWidget);
      }
      for (final phase in DayPhase.values) {
        expect(find.byIcon(phase.icon), findsOneWidget);
      }
    });

    testWidgets('fills the part of the day the time is in', (tester) async {
      final semantics = tester.ensureSemantics();
      await cubit.reset();
      await pump(tester);

      expect(
        tester.getSemantics(find.text('Manhã')),
        isSemantics(
          label: 'Manhã',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
        ),
      );

      cubit.emit(
        cubit.state.copyWith(now: DayPhase.evening.on(cubit.state.now)),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Manhã')),
        isSemantics(label: 'Manhã', isButton: true, isSelected: false),
      );
      expect(
        tester.getSemantics(find.text('Noite')),
        isSemantics(label: 'Noite', isButton: true, isSelected: true),
      );
      semantics.dispose();
    });

    testWidgets('nothing works while it loads', (tester) async {
      await pump(tester);

      for (final label in ['Manhã', 'Dia', 'Pôr do sol', 'Noite']) {
        expect(enabled(tester, label), isFalse, reason: label);
      }
    });

    testWidgets('choosing a part of the day takes the time there', (
      tester,
    ) async {
      live.answers = false;
      await cubit.reset();
      await pump(tester);

      await tester.tap(button('Pôr do sol'));
      await tester.pump();

      // Locked until the backend has the clock there.
      expect(enabled(tester, 'Dia'), isFalse);
      expect(cubit.state.now, DayPhase.sunset.on(cubit.state.now));

      await settle(tester);

      expect(live.moves.last, DayPhase.sunset.on(cubit.state.now));
      expect(enabled(tester, 'Dia'), isTrue);
    });

    testWidgets('a failed clock is asked again by any button', (tester) async {
      cubit.emit(cubit.state.copyWith(status: TimelineStatus.failure));
      await pump(tester);

      expect(
        find.text('Não é possível alcançar o relógio da demo'),
        findsOneWidget,
      );
      expect(enabled(tester, 'Dia'), isTrue);

      await tester.tap(button('Dia'));
      await tester.pump();
      await tester.pump();

      expect(repository.resets, 1);
      expect(cubit.state.status, TimelineStatus.ready);
    });

    testWidgets('is labelled for a screen reader', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      expect(find.bySemanticsLabel('Horário da demo'), findsOneWidget);
      semantics.dispose();
    });
  });
}
