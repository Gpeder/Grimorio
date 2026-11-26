import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/model/campaign.dart';

const _valfenda = 'sombras-de-valfenda';
const _trono = 'o-trono-de-cinzas';

final campanhasMock = [
  Campaign(
    id: _valfenda,
    nome: 'Sombras de Valfenda',
    capitulo: 'Capítulo 3: A Floresta Sombria',
    progresso: 0.3,
    capa: AppImages.bg3,
    mestreId: 'u_bruno',
    codigoConvite: 'VALF-42',
    sessaoAtual: 8,
    emSessao: true,
    missoes: [
      Missao(
        id: 'druida-desaparecido',
        campanhaId: _valfenda,
        titulo: 'O Druida Desaparecido',
        tipo: TipoMissao.principal,
        regiao: 'Floresta Sombria',
        descricao:
            'Halvar, o guardião do bosque, sumiu. Desde então os animais da '
            'floresta andam inquietos.',
        revelada: true,
        entradas: [
          EntradaMissao(
            id: 'dd-1',
            texto:
                'Bram, o taverneiro, contou que Halvar sumiu há três noites.',
            sessao: 6,
            concluida: true,
            criadaEm: DateTime(2026, 11, 5, 20),
          ),
          EntradaMissao(
            id: 'dd-2',
            texto:
                'Encontramos o acampamento de Halvar revirado na trilha norte.',
            sessao: 7,
            concluida: true,
            criadaEm: DateTime(2026, 11, 12, 21),
          ),
          EntradaMissao(
            id: 'dd-3',
            texto: 'Seguir os rastros até o coração da Floresta Sombria.',
            sessao: 8,
            objetivo: true,
            criadaEm: DateTime(2026, 11, 25, 19, 30),
          ),
          EntradaMissao(
            id: 'dd-4',
            texto: 'Descobrir que o culto do Galho Podre levou Halvar.',
            sessao: 8,
            objetivo: true,
            revelada: false,
            criadaEm: DateTime(2026, 11, 25, 19, 45),
          ),
        ],
        recompensaXp: 900,
        recompensaItens: ['amuleto_saude'],
        npcIds: ['bram', 'halvar'],
        atualizadaEm: DateTime(2026, 11, 25, 19, 45),
      ),
      Missao(
        id: 'lobos-clareira',
        campanhaId: _valfenda,
        titulo: 'Lobos na Clareira',
        regiao: 'Estrada Norte',
        descricao: 'Uma alcateia ataca as carroças que passam pela clareira.',
        revelada: true,
        entradas: [
          EntradaMissao(
            id: 'lc-1',
            texto: 'Afastar a alcateia antes da próxima caravana.',
            sessao: 7,
            objetivo: true,
            criadaEm: DateTime(2026, 11, 12, 22),
          ),
        ],
        recompensaXp: 300,
        atualizadaEm: DateTime(2026, 11, 12, 22),
      ),
      Missao(
        id: 'divida-bram',
        campanhaId: _valfenda,
        titulo: 'A Dívida de Bram',
        regiao: 'Valfenda',
        descricao: 'Bram deve 20 PO a um agiota da cidade.',
        estado: EstadoMissao.concluida,
        revelada: true,
        entradas: [
          EntradaMissao(
            id: 'db-1',
            texto: 'Pagamos a dívida e Bram prometeu hospedagem grátis.',
            sessao: 6,
            objetivo: true,
            concluida: true,
            criadaEm: DateTime(2026, 11, 5, 22),
          ),
        ],
        recompensaXp: 100,
        npcIds: ['bram'],
        atualizadaEm: DateTime(2026, 11, 5, 22),
      ),
      Missao(
        id: 'mercador-sumido',
        campanhaId: _valfenda,
        titulo: 'O Mercador Sumido',
        regiao: 'Estrada Sul',
        descricao: 'Odo, o mercador de especiarias, não chegou à feira.',
        estado: EstadoMissao.falhou,
        revelada: true,
        entradas: [
          EntradaMissao(
            id: 'ms-1',
            texto: 'Odo foi encontrado sem vida na beira da estrada.',
            sessao: 7,
            criadaEm: DateTime(2026, 11, 12, 20),
          ),
        ],
        recompensaXp: 200,
        atualizadaEm: DateTime(2026, 11, 12, 20),
      ),
      Missao(
        id: 'altar-profanado',
        campanhaId: _valfenda,
        titulo: 'O Altar Profanado',
        tipo: TipoMissao.principal,
        regiao: 'Templo Antigo',
        descricao: 'Alguém está profanando o altar esquecido do vale.',
        entradas: [
          EntradaMissao(
            id: 'ap-1',
            texto: 'Investigar as marcas de sangue no altar.',
            sessao: 8,
            objetivo: true,
            revelada: false,
            criadaEm: DateTime(2026, 11, 25, 18),
          ),
        ],
        recompensaXp: 1200,
        npcIds: ['ilsa'],
        atualizadaEm: DateTime(2026, 11, 25, 18),
      ),
    ],
    npcs: [
      Npc(
        id: 'bram',
        campanhaId: _valfenda,
        nome: 'Bram',
        funcao: 'Taverneiro',
        imagem: AppImages.especieAnaoM,
        revelado: true,
      ),
      Npc(
        id: 'halvar',
        campanhaId: _valfenda,
        nome: 'Halvar',
        funcao: 'Druida',
        imagem: AppImages.especieElfoM,
        revelado: true,
      ),
      Npc(
        id: 'ilsa',
        campanhaId: _valfenda,
        nome: 'Sacerdotisa Ilsa',
        funcao: 'Sacerdotisa',
        imagem: AppImages.especieMeioElfoF,
      ),
    ],
    sessoes: [
      Sessao(
        id: 'valf-s6',
        campanhaId: _valfenda,
        numero: 6,
        data: DateTime(2026, 11, 5),
        resumo:
            'O grupo chegou a Valfenda e ouviu de Bram sobre o sumiço de '
            'Halvar.',
        xpTotal: 600,
      ),
      Sessao(
        id: 'valf-s7',
        campanhaId: _valfenda,
        numero: 7,
        data: DateTime(2026, 11, 12),
        resumo:
            'Na trilha norte, o grupo achou o acampamento revirado e '
            'enfrentou os lobos.',
        xpTotal: 1200,
      ),
    ],
    registros: [
      RegistroMesa(
        id: 'valf-r3',
        campanhaId: _valfenda,
        tipo: TipoRegistro.xp,
        texto: '+150 XP para Thorgar',
        personagemId: 'thorgar',
        valor: 150,
        criadoEm: DateTime(2026, 11, 25, 20, 10),
      ),
      RegistroMesa(
        id: 'valf-r2',
        campanhaId: _valfenda,
        tipo: TipoRegistro.item,
        texto: 'Poção de cura para Mirela',
        personagemId: 'mirela',
        itemKey: 'pocao_cura',
        criadoEm: DateTime(2026, 11, 25, 20, 5),
      ),
      RegistroMesa(
        id: 'valf-r1',
        campanhaId: _valfenda,
        tipo: TipoRegistro.sessao,
        texto: 'Sessão 8 iniciada',
        criadoEm: DateTime(2026, 11, 25, 19),
      ),
    ],
  ),
  Campaign(
    id: _trono,
    nome: 'O Trono de Cinzas',
    capitulo: 'Capítulo 1: Brasas no Horizonte',
    progresso: 0.05,
    capa: AppImages.bgCastelo,
    mestreId: 'u_gustavo',
    codigoConvite: 'TRON-17',
    sessaoAtual: 1,
    missoes: [
      Missao(
        id: 'coroa-partida',
        campanhaId: _trono,
        titulo: 'A Coroa Partida',
        tipo: TipoMissao.principal,
        regiao: 'Cidadela de Cinzas',
        descricao: 'A coroa do último rei foi dividida em três fragmentos.',
        revelada: true,
        entradas: [
          EntradaMissao(
            id: 'cp-1',
            texto: 'Encontrar o ferreiro que guarda o primeiro fragmento.',
            sessao: 1,
            objetivo: true,
            criadaEm: DateTime(2026, 11, 20, 20),
          ),
        ],
        recompensaXp: 100,
        npcIds: ['doran'],
        atualizadaEm: DateTime(2026, 11, 20, 20),
      ),
    ],
    npcs: [
      Npc(
        id: 'doran',
        campanhaId: _trono,
        nome: 'Doran',
        funcao: 'Ferreiro',
        imagem: AppImages.especieHumanoM,
        revelado: true,
      ),
    ],
    sessoes: [
      Sessao(
        id: 'tron-s1',
        campanhaId: _trono,
        numero: 1,
        data: DateTime(2026, 11, 20),
        resumo: 'Kael chegou à cidadela e ouviu a lenda da coroa partida.',
      ),
    ],
  ),
];
