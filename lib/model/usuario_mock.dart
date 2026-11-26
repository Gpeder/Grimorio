import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/model/usuario.dart';

final usuarioMock = Usuario(
  id: 'u_gustavo',
  nome: 'Gustavo',
  email: 'gustavo@email.com',
  avatar: AppImages.especieHumanoM,
  papel: PapelMesa.ambos,
  edicao: EdicaoRegras.srd2014,
  magia: SistemaMagia.espacos,
  subida: SubidaNivel.xp,
  dicasBonus: true,
  vibrar: true,
  confirmarApagar: true,
  compendioAtualizadoEm: DateTime(2026, 11, 24),
);

// nomes dos outros usuarios até ter login
const nomesUsuariosMock = {
  'u_gustavo': 'Gustavo',
  'u_bruno': 'Bruno',
  'u_ana': 'Ana',
  'u_caio': 'Caio',
  'u_lia': 'Lia',
};
