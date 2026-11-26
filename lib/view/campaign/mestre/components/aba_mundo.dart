import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/model/campaign.dart' as dados;
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

class AbaMundo extends StatelessWidget {
  const AbaMundo({
    super.key,
    required this.npcs,
    required this.onRevelar,
    required this.onNovo,
  });

  final List<dados.Npc> npcs;
  final void Function(dados.Npc npc, bool revelado) onRevelar;
  final VoidCallback onNovo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSecao(
          'Personagens do mundo',
          trailing: TextButton.icon(
            onPressed: onNovo,
            icon: const Icon(Pixel.plus, size: 18),
            label: const Text('NPC'),
          ),
        ),
        if (npcs.isEmpty)
          Text(
            'Nenhum NPC ainda.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.55)),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium - 4,
              vertical: 4,
            ),
            child: Column(
              children: [
                for (var i = 0; i < npcs.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  LinhaNpc(
                    npc: npcs[i],
                    trailing: Switch(
                      value: npcs[i].revelado,
                      onChanged: (v) => onRevelar(npcs[i], v),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class LinhaNpc extends StatelessWidget {
  const LinhaNpc({super.key, required this.npc, this.trailing});

  final dados.Npc npc;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trailing = this.trailing;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        children: [
          ImageFrame(imagePath: npc.imagem, width: 40, height: 40),
          const SizedBox(width: AppSpacing.medium - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  npc.nome,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (npc.funcao.isNotEmpty)
                  Text(
                    npc.funcao,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

Future<dados.Npc?> pedirNpc(BuildContext context, String campanhaId) =>
    showModalBottomSheet<dados.Npc>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _SheetNpc(campanhaId: campanhaId),
    );

class _SheetNpc extends StatefulWidget {
  const _SheetNpc({required this.campanhaId});

  final String campanhaId;

  @override
  State<_SheetNpc> createState() => _SheetNpcState();
}

class _SheetNpcState extends State<_SheetNpc> {
  final _nome = TextEditingController();
  final _funcao = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _funcao.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _nome.text.trim();
    if (nome.length < 2) {
      setState(() => _erro = 'Dê um nome ao NPC.');
      return;
    }
    Navigator.pop(
      context,
      dados.Npc(
        id: 'npc-${DateTime.now().microsecondsSinceEpoch}',
        campanhaId: widget.campanhaId,
        nome: nome,
        funcao: _funcao.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium,
          0,
          AppSpacing.medium,
          AppSpacing.medium + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TituloSecao('Novo NPC'),
            TextField(
              controller: _nome,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: 'Nome', errorText: _erro),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: _funcao,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Função',
                hintText: 'Taverneiro, guarda, vilão…',
              ),
              onSubmitted: (_) => _salvar(),
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(onPressed: _salvar, child: const Text('Criar NPC')),
          ],
        ),
      ),
    );
  }
}
