import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/srd/item_srd.dart';

// pixel art e rotulos das coisas do srd
abstract final class VisualSrd {
  static String escola(String? escola) =>
      _escolas[escola?.toLowerCase()] ?? AppImages.pergMagia;

  static const monstro = AppImages.menuBestiario;

  static String classe(String key) => _classes[key] ?? AppImages.menuGrimorio;

  static String especie(String key, {bool feminino = true}) {
    final (f, m) =
        _especies[key] ?? (AppImages.especieHumanoF, AppImages.especieHumanoM);
    return feminino ? f : m;
  }

  // imagem padrao pelo tipo do item
  static String item(ItemSrd i) {
    if (i.arma) return AppImages.arma01;
    if (i.armadura) {
      return switch (i.categoriaArmadura) {
        'light' => AppImages.armaduraLeve,
        'heavy' => AppImages.armaduraPesada,
        _ => AppImages.armaduraMedio,
      };
    }
    return _itens[i.categoria?.toLowerCase()] ?? AppImages.bau;
  }

  static Raridade? raridade(String? nome) => switch (nome?.toLowerCase()) {
    'common' => Raridade.comum,
    'uncommon' => Raridade.incomum,
    'rare' => Raridade.raro,
    'very rare' => Raridade.muitoRaro,
    'legendary' || 'artifact' => Raridade.lendario,
    _ => null,
  };

  // 0 e truque
  static String nivel(int nivel) => nivel == 0 ? 'Truque' : '$nivelº círculo';

  // 0.25 vira 1/4
  static String nd(double? nd) => switch (nd) {
    null => '—',
    0.125 => '1/8',
    0.25 => '1/4',
    0.5 => '1/2',
    final n => '${n.round()}',
  };

  // 18000 vira 18.000
  static String milhar(int n) {
    final d = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) b.write('.');
      b.write(d[i]);
    }
    return b.toString();
  }

  static const _escolas = {
    'abjuration': AppImages.magoAbjuracao,
    'divination': AppImages.magoAdivinhacao,
    'conjuration': AppImages.magoConjuracao,
    'enchantment': AppImages.magoEncantamento,
    'evocation': AppImages.magoEvocacao,
    'illusion': AppImages.magoIlusao,
    'necromancy': AppImages.magoNecromancia,
    'transmutation': AppImages.magoTransmutacao,
  };

  static const _classes = {
    'srd_barbarian': AppImages.classeBarbaro,
    'srd_bard': AppImages.classeBardo,
    'srd_cleric': AppImages.classeClerico,
    'srd_druid': AppImages.classeDruida,
    'srd_fighter': AppImages.classeGuerreiro,
    'srd_monk': AppImages.classeMonge,
    'srd_paladin': AppImages.classePaladino,
    'srd_ranger': AppImages.classePatrulheiro,
    'srd_rogue': AppImages.classeLadino,
    'srd_sorcerer': AppImages.classeFeiticeiro,
    'srd_warlock': AppImages.classeBruxo,
    'srd_wizard': AppImages.classeMago,
    // subclasses
    'srd_path-of-the-berserker': AppImages.barbaroBerserker,
    'srd_college-of-lore': AppImages.bardoColegioSaber,
    'srd_life-domain': AppImages.clericoDominioVida,
    'srd_circle-of-the-land': AppImages.druidaCirculoTerra,
    'srd_champion': AppImages.guerreiroCampeao,
    'srd_way-of-the-open-hand': AppImages.mongeMaoAberta,
    'srd_oath-of-devotion': AppImages.paladinoDevocao,
    'srd_hunter': AppImages.patrulheiroCacador,
    'srd_thief': AppImages.ladinoLadrao,
    'srd_draconic-bloodline': AppImages.feiticeiroDraconica,
    'srd_the-fiend': AppImages.bruxoCorruptor,
    'srd_school-of-evocation': AppImages.magoEvocacao,
  };

  static const _especies = {
    'srd_dragonborn': (
      AppImages.especieDraconatoF,
      AppImages.especieDraconatoM,
    ),
    'srd_dwarf': (AppImages.especieAnaoF, AppImages.especieAnaoM),
    'srd_hill-dwarf': (AppImages.especieAnaoF, AppImages.especieAnaoM),
    'srd_elf': (AppImages.especieElfoF, AppImages.especieElfoM),
    'srd_high-elf': (AppImages.especieElfoF, AppImages.especieElfoM),
    'srd_gnome': (AppImages.especieGnomoF, AppImages.especieGnomoM),
    'srd_rock-gnome': (AppImages.especieGnomoF, AppImages.especieGnomoM),
    'srd_half-elf': (AppImages.especieMeioElfoF, AppImages.especieMeioElfoM),
    'srd_half-orc': (AppImages.especieOrcF, AppImages.especieOrcM),
    'srd_halfling': (AppImages.especieHalflingF, AppImages.especieHalflingM),
    'srd_lightfoot': (AppImages.especieHalflingF, AppImages.especieHalflingM),
    'srd_human': (AppImages.especieHumanoF, AppImages.especieHumanoM),
    'srd_tiefling': (AppImages.especieTieflingF, AppImages.especieTieflingM),
  };

  // pela categoria em minusculo
  static const _itens = {
    'potion': AppImages.pocao1,
    'ring': AppImages.anel,
    'scroll': AppImages.pergMagia,
    'wondrous item': AppImages.colar,
    'rod': AppImages.tocha,
    'staff': AppImages.tocha,
    'wand': AppImages.tocha,
    'ammunition': AppImages.arma02,
    'adventuring gear': AppImages.menuBolsa,
    'tools': AppImages.chave,
    'trade good': AppImages.moeda,
    'poison': AppImages.pocao7,
    'land vehicle': AppImages.bau,
    'waterborne vehicle': AppImages.bau,
    'weapon': AppImages.arma01,
    'armor': AppImages.armaduraMedio,
    'shield': AppImages.armaduraMedio,
  };
}
