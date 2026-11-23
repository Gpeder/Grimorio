import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/models/character.dart';

const personagemAtivoMock = Character(
  id: 'elyndra',
  nome: 'Elyndra',
  retrato: AppImages.especieHumanoF,
  especie: 'Humana',
  classes: [
    CharacterClass(
      apiKey: 'srd_cleric',
      nome: 'Clériga',
      nivel: 5,
      dadoDeVida: 8,
      subclasse: 'Domínio da Vida',
    ),
  ],
  atributos: AbilityScores(
    forca: 12,
    destreza: 10,
    constituicao: 14,
    inteligencia: 10,
    sabedoria: 18,
    carisma: 13,
  ),
  xp: 6500,
  hpMax: 38,
  hpAtual: 32,
  ca: 16,
  deslocamentoM: 9,
  salvaguardas: {Ability.sabedoria, Ability.carisma},
  espacosDeMagia: [
    SpellSlot(circulo: 1, total: 4, usados: 1),
    SpellSlot(circulo: 2, total: 3),
    SpellSlot(circulo: 3, total: 2, usados: 2),
  ],
  ativo: true,
);
