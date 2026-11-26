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
