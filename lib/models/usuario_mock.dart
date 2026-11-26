import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/models/usuario.dart';

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

// Nomes dos outros usuários do mock, até existir login.
const nomesUsuariosMock = {
  'u_gustavo': 'Gustavo',
  'u_bruno': 'Bruno',
  'u_ana': 'Ana',
  'u_caio': 'Caio',
  'u_lia': 'Lia',
};
