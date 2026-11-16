import 'dart:math';

import 'package:a2ui_vgv_smart_home/api_key/gemini_key_store.dart';
import 'package:a2ui_vgv_smart_home/api_key/view/api_key_gate.dart';
import 'package:a2ui_vgv_smart_home/dashboard/agent_factory.dart';
import 'package:a2ui_vgv_smart_home/dashboard/view/dashboard_page.dart';
import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/live/cubit/live_cubit.dart';
import 'package:a2ui_vgv_smart_home/shell/device_frame.dart';
import 'package:a2ui_vgv_smart_home/theme/cubit/theme_cubit.dart';
import 'package:a2ui_vgv_smart_home/theme/panel_theme.dart';
import 'package:a2ui_vgv_smart_home/timeline/cubit/timeline_cubit.dart';
import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:a2ui_vgv_smart_home/voice/microphone.dart';
import 'package:a2ui_vgv_smart_home/voice/transcription_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repository/home_repository.dart';
import 'package:material_ui/material_ui.dart';
// Same library, prefixed: the app's MaterialApp is material_ui's, and its
// widgets read the MaterialLocalizations of material_ui, which the gen'd
// delegate (flutter_localizations) does not provide.
import 'package:material_ui/material_ui.dart' as mui;

/// Below this width the window is a phone's, and the panel takes almost all of
/// it instead of floating as a tablet.
const double _phoneWidth = 700;

/// How much of a phone's window the panel takes, on both axes.
const double _phoneFill = 0.98;

/// {@template app}
/// The page around the demo: a tablet frame holding the actual application.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({
    required this.agentFactory,
    required this.keys,
    required this.usersRepository,
    required this.scenarioRepository,
    required this.liveRepository,
    required this.microphone,
    required this.transcriptionClient,
    super.key,
  });

  /// Builds the agent of each user's dashboard.
  final AgentFactory agentFactory;

  /// Holds the person's own Gemini API key.
  final GeminiKeyStore keys;

  /// Where the household's members come from.
  final UsersRepository usersRepository;

  /// Where the scenario's timeline comes from.
  final ScenarioRepository scenarioRepository;

  /// Where the live updates of the home come from.
  final LiveRepository liveRepository;

  /// Captures the voice commands' audio.
  final Microphone microphone;

  /// Turns the voice commands' audio into text.
  final TranscriptionClient transcriptionClient;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GeminiKeyStore>.value(value: keys),
        RepositoryProvider<AgentFactory>.value(value: agentFactory),
        RepositoryProvider<UsersRepository>.value(value: usersRepository),
        RepositoryProvider<ScenarioRepository>.value(value: scenarioRepository),
        RepositoryProvider<LiveRepository>.value(value: liveRepository),
        RepositoryProvider<Microphone>.value(value: microphone),
        RepositoryProvider<TranscriptionClient>.value(
          value: transcriptionClient,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LiveCubit(repository: liveRepository)),
          BlocProvider(
            create: (_) => TimelineCubit(
              repository: scenarioRepository,
              live: liveRepository,
              autoPlay: true,
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, PanelTheme>(
          builder: (context, panelTheme) {
            final phase = context.select<TimelineCubit, DayPhase>(
              (cubit) => DayPhase.at(cubit.state.now),
            );
            return MaterialApp(
              onGenerateTitle: (context) => context.l10n.appTitle,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: panelTheme.modeFor(phase),
              localizationsDelegates: const [
                ...AppLocalizations.localizationsDelegates,
                ...mui.GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              // The page around the panel: the kitchen, and the panel itself.
              builder: (context, child) => ColoredBox(
                color: context.colors.bezel,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _Backdrop(),
                    // On a desktop the tablet keeps its 16:10 shape and floats
                    // in the middle of the page. A phone's window has no room
                    // for that framing, so the panel itself fills 98% of it and
                    // the screen sits centered inside, never stretched. The
                    // demo's clock lives in the panel's navigation rail.
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final phone = constraints.maxWidth < _phoneWidth;
                        if (phone) {
                          return Center(
                            child: SizedBox(
                              width: constraints.maxWidth * _phoneFill,
                              height: constraints.maxHeight * _phoneFill,
                              child: DeviceFrame(fill: true, child: child!),
                            ),
                          );
                        }
                        final frameHeight = [
                          DeviceFrame.maxHeight,
                          constraints.maxWidth *
                              DeviceFrame.maxHeight /
                              DeviceFrame.maxWidth,
                          constraints.maxHeight - 2 * AppSpacing.s5,
                        ].reduce(min).clamp(0, double.infinity).toDouble();
                        return Center(
                          child: SizedBox(
                            width:
                                frameHeight *
                                DeviceFrame.maxWidth /
                                DeviceFrame.maxHeight,
                            height: frameHeight,
                            child: DeviceFrame(child: child!),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              home: const ApiKeyGate(child: DashboardPage()),
            );
          },
        ),
      ),
    );
  }
}

/// The kitchen behind the tablet, in the light of the time on the timeline.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    final light = context.select<TimelineCubit, KitchenLight>(
      (cubit) => DayPhase.at(cubit.state.now).light,
    );
    return KitchenBackdrop(light: light);
  }
}
