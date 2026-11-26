import 'package:grimorio/model/character.dart';

const atributosTeste = AbilityScores(
  forca: 10,
  destreza: 10,
  constituicao: 10,
  inteligencia: 10,
  sabedoria: 10,
  carisma: 10,
);

CharacterClass classeTeste(int nivel, {String nome = 'Guerreiro'}) =>
    CharacterClass(apiKey: 'srd_x', nome: nome, nivel: nivel, dadoDeVida: 10);

Character personagemTeste({
  List<CharacterClass>? classes,
  int xp = 0,
  int hpMax = 30,
  int hpAtual = 30,
  int hpTemp = 0,
  List<SpellSlot> espacosDeMagia = const [],
  List<InventoryItem> inventario = const [],
}) => Character(
  id: 'teste',
  nome: 'Teste',
  retrato: '',
  especie: 'Humano',
  classes: classes ?? [classeTeste(1)],
  atributos: atributosTeste,
  xp: xp,
  hpMax: hpMax,
  hpAtual: hpAtual,
  hpTemp: hpTemp,
  ca: 10,
  deslocamentoM: 9,
  espacosDeMagia: espacosDeMagia,
  inventario: inventario,
);
