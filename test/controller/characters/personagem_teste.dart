import 'package:grimorio/model/personagem.dart';

const atributosTeste = Atributos(
  forca: 10,
  destreza: 10,
  constituicao: 10,
  inteligencia: 10,
  sabedoria: 10,
  carisma: 10,
);

ClassePersonagem classeTeste(int nivel, {String nome = 'Guerreiro'}) =>
    ClassePersonagem(apiKey: 'srd_x', nome: nome, nivel: nivel, dadoDeVida: 10);

Personagem personagemTeste({
  List<ClassePersonagem>? classes,
  int xp = 0,
  int hpMax = 30,
  int hpAtual = 30,
  int hpTemp = 0,
  List<EspacoMagia> espacosDeMagia = const [],
  List<ItemInventario> inventario = const [],
}) => Personagem(
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
