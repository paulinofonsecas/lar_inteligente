import 'package:a2ui_vgv_smart_home/dashboard/view/dashboard_page.dart';
import 'package:a2ui_vgv_smart_home/shell/device_frame.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_agent.dart';
import '../../helpers/helpers.dart';

Brightness _brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(DashboardPage))).brightness;

void main() {
  group('App', () {
    testWidgets('renders the dashboard inside the device frame', (
      tester,
    ) async {
      await tester.pumpApp(FakeAgentFactory());
      expect(
        find.descendant(
          of: find.byType(DeviceFrame),
          matching: find.byType(DashboardPage),
        ),
        findsOneWidget,
      );
    });

    testWidgets('puts the morning kitchen behind the frame', (tester) async {
      await tester.pumpApp(FakeAgentFactory());

      expect(
        tester.widget<KitchenBackdrop>(find.byType(KitchenBackdrop)).light,
        KitchenLight.morning,
      );
    });

    testWidgets('requests the first user dashboard on load', (tester) async {
      final factory = FakeAgentFactory();
      await tester.pumpApp(factory);
      expect(factory.agents, hasLength(1));
      expect(factory.agents.single.user, palmira);
      expect(factory.agents.single.sent, [palmira.prompt]);
    });

    testWidgets('the appearance sheet turns the panel dark', (tester) async {
      await tester.pumpApp(FakeAgentFactory());

      await tester.tap(find.byTooltip('Aparência do painel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Escuro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final context = tester.element(find.byType(DashboardPage));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(context.colors.surfaceRaised, AppPalette.dark.surfaceRaised);
    });

    testWidgets('the time of day makes the panel light by day and dark at '
        'night', (tester) async {
      await tester.pumpApp(FakeAgentFactory());
      expect(_brightness(tester), Brightness.light);

      await tester.tap(find.text('Noite'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(_brightness(tester), Brightness.dark);

      await tester.tap(find.text('Manhã'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(_brightness(tester), Brightness.light);
    });

    testWidgets('switching user rebuilds and requests again', (tester) async {
      final factory = FakeAgentFactory();
      await tester.pumpApp(factory);

      await tester.tap(find.text(paulino.name));
      await tester.pump();

      expect(factory.agents, hasLength(2));
      expect(factory.agents.first.disposed, isTrue);
      expect(factory.agents.last.user, paulino);
      expect(factory.agents.last.sent, [paulino.prompt]);
    });

    testWidgets('switching back requests the first user again', (
      tester,
    ) async {
      final factory = FakeAgentFactory();
      await tester.pumpApp(factory);

      await tester.tap(find.text(paulino.name));
      await tester.pump();
      await tester.tap(find.text(palmira.name));
      await tester.pump();

      expect(factory.agents, hasLength(3));
      expect(factory.agents.last.user, palmira);
    });
  });

  group('DeviceFrame', () {
    Future<Size> frameSize(WidgetTester tester, Size window) async {
      tester.view
        ..physicalSize = window
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(home: DeviceFrame(child: SizedBox.expand())),
      );
      return tester.getSize(find.byType(AspectRatio));
    }

    testWidgets('never exceeds tablet size', (tester) async {
      final size = await frameSize(tester, const Size(3000, 2000));
      expect(size, const Size(DeviceFrame.maxWidth, DeviceFrame.maxHeight));
    });
    testWidgets('shrinks on a small window keeping its ratio', (tester) async {
      final size = await frameSize(tester, const Size(600, 900));
      expect(size.width, 600);
      expect(
        size.width / size.height,
        closeTo(DeviceFrame.maxWidth / DeviceFrame.maxHeight, 0.001),
      );
    });
  });
}
