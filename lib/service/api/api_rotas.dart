class ApiRotas {
  static const host = 'https://api.open5e.com';
  static const base = '$host/v2';

  // document__key e ignorado em items, magicitems e weapons, o __in funciona em todos
  static const filtroDocumento = 'document__key__in';
  static const documentoSrd = 'srd-2014';

  // condicoes do srd ficam no documento core
  static const documentoCondicoes = 'core';

  // busca por nome
  static const filtroBusca = 'name__icontains';
  static const pagina = 'page';

  // ordem
  static const ordem = 'ordering';
  static const ordemNome = 'name';
  static const ordemNivel = 'level,name';
  static const ordemNd = 'challenge_rating,name';

  // magias
  static const filtroNivel = 'level';
  static const filtroNivelMinimo = 'level__gte';
  static const filtroConcentracao = 'concentration';
  static const filtroClasse = 'classes__key';
  static const filtroEscola = 'school__key';

  // criaturas, tipo vai pela key em minusculo
  static const filtroTipo = 'type';
  static const filtroNdMinimo = 'challenge_rating__gte';
  static const filtroNdMaximo = 'challenge_rating__lte';

  // itens magicos, raridade pela key
  static const filtroRaridade = 'rarity';

  // /items/ separa armas e armaduras pela categoria
  // weapons e armor ignoram a busca por nome
  static const filtroCategoria = 'category__in';
  static const categoriasArma = 'weapon';
  static const categoriasArmadura = 'armor,shield';
  static const categoriasEquipamento =
      'adventuring-gear,ammunition,land-vehicle,poison,ring,rod,staff,'
      'tools,trade-good,wand,waterborne-vehicle';

  // classes e especies
  static const filtroEhSubclasse = 'is_subclass';
  static const filtroSubclasseDe = 'subclass_of';
  static const filtroSemEspecieMae = 'subspecies_of__isnull';

  // compendio
  static const magias = '/spells/';
  static const itens = '/items/';
  static const itensMagicos = '/magicitems/';
  static const armas = '/weapons/';
  static const armaduras = '/armor/';
  static const monstros = '/creatures/';
  static const classes = '/classes/';
  static const especies = '/species/';
  static const condicoes = '/conditions/';
  static const imagens = '/images/';

  static String detalhe(String rota, String key) => '$rota$key/';

  // file_url vem sem o host
  static String arquivo(String caminho) =>
      caminho.startsWith('http') ? caminho : '$host$caminho';
}
