class Rotas {
  // abas
  static const inicio = '/inicio';
  static const herois = '/herois';
  static const campanhas = '/campanhas';
  static const grimorio = '/grimorio';
  static const ajustes = '/ajustes';

  // herois
  static const novoHeroi = 'novo'; // /herois/novo
  static const ficha = ':heroiId'; // /herois/:heroiId

  // campanhas
  static const campanha = ':campanhaId'; // /campanhas/:campanhaId
  static const previa = 'previa'; // /campanhas/:campanhaId/previa
  static const missao = 'missoes/:missaoId'; // .../missoes/:missaoId

  // grimorio
  static const listaCompendio = ':tipo'; // /grimorio/:tipo
  static const detalheCompendio = ':key'; // /grimorio/:tipo/:key

  // parametros
  static const heroiId = 'heroiId';
  static const campanhaId = 'campanhaId';
  static const missaoId = 'missaoId';
  static const tipo = 'tipo';
  static const key = 'key';

  // nomes
  static const nomeInicio = 'inicio';
  static const nomeHerois = 'herois';
  static const nomeCampanhas = 'campanhas';
  static const nomeGrimorio = 'grimorio';
  static const nomeAjustes = 'ajustes';
  static const nomeNovoHeroi = 'novo-heroi';
  static const nomeFicha = 'ficha';
  static const nomeCampanha = 'campanha';
  static const nomePrevia = 'previa';
  static const nomeMissao = 'missao';
  static const nomeMissaoPrevia = 'missao-previa';
  static const nomeListaCompendio = 'lista-compendio';
  static const nomeDetalheCompendio = 'detalhe-compendio';
}

// tipos do compendio no path do grimorio
class TipoCompendio {
  static const magias = 'magias';
  static const bestiario = 'bestiario';
  static const itens = 'itens';

  // abas de itens, no detalhe dizem de onde buscar
  static const itensMagicos = 'itens-magicos';
  static const armas = 'armas';
  static const armaduras = 'armaduras';
  static const classes = 'classes';
  static const especies = 'especies';
  static const condicoes = 'condicoes';
}
