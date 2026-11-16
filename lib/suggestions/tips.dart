import 'package:app_ui/app_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// One entry of the tips sheet.
typedef Tip = TipsSheetItem;

/// {@template tip_sink}
/// The bridge the tips sheet sends through: the dashboard on screen registers
/// its handler when it builds, and a tip lands there as a typed turn.
/// {@endtemplate}
class TipSink {
  void Function(String ask)? _send;

  /// Registers the dashboard that receives the tips, replacing the previous
  /// one when the person switches.
  // ignore: use_setters_to_change_properties
  void register(void Function(String ask) send) => _send = send;

  /// Sends [ask] to the dashboard on screen, if there is one.
  void request(String ask) => _send?.call(ask);
}

/// The panel's suggestions, most useful for someone new first.
const tips = <Tip>[
  Tip(
    icon: Symbols.mic_rounded,
    title: 'Fale com o painel',
    description:
        'Toque no microfone e peça. Também funciona digitando na barra.',
    ask: 'preaqueça o forno para o jantar',
  ),
  Tip(
    icon: Symbols.undo_rounded,
    title: 'Desfazer com um toque',
    description: 'Toda mudança tem volta, sem pedir de novo.',
    ask: 'desfazer a última mudança',
  ),
  Tip(
    icon: Symbols.table_bar_rounded,
    title: 'Cenas que mudam a sala',
    description: 'Luzes, música e clima de uma vez, com o botão Iniciar.',
    ask: 'dê o play na cena de jantar',
  ),
  Tip(
    icon: Symbols.schedule_rounded,
    title: 'A agenda manda na casa',
    description:
        'Mude a hora do jantar e o forno, a receita e as rotas se ajustam sozinhos.',
    ask: 'as visitas chegam uma hora mais cedo',
  ),
  Tip(
    icon: Symbols.cake_rounded,
    title: 'A padaria entrega',
    description: 'Peça a entrega e acompanhe o bolo até a porta.',
    ask: 'peça à padaria que entregue o bolo',
  ),
  Tip(
    icon: Symbols.checklist_rounded,
    title: 'Listas que a família compartilha',
    description: 'Marque o que comprou e o outro vê na hora.',
    ask: 'marque o tomilho como comprado',
  ),
  Tip(
    icon: Symbols.timer_rounded,
    title: 'Programe o forno',
    description: 'Diga a hora do preaquecimento e o painel acompanha.',
    ask: 'agende o forno para as 18:30',
  ),
  Tip(
    icon: Symbols.notifications_rounded,
    title: 'Fique sabendo das mudanças',
    description:
        'Quando alguém muda algo que te afeta, um alerta abre com a melhor saída.',
    ask: 'o que mudou para mim?',
  ),
];

/// Opens the tips sheet. [send] runs a tip's `ask` as a typed turn.
Future<void> showTipsSheet(
  BuildContext context, {
  required ValueChanged<Tip> send,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height;
      return Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + AppSpacing.s4,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height * 0.82),
          child: TipsSheet(
            title: 'Sugestões',
            subtitle: 'O que o painel do Lar Inteligente pode fazer por você.',
            tryLabel: 'Experimentar',
            items: tips,
            onTry: (tip) {
              Navigator.of(context).pop();
              send(tip);
            },
          ),
        ),
      );
    },
  );
}
