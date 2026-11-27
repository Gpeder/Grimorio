// nomes de tabela, coluna de filtro, select e rpc do supabase
abstract final class BancoRotas {
  // tabelas
  static const perfis = 'perfis';
  static const campanhas = 'campanhas';
  static const notasMestre = 'notas_mestre';
  static const personagens = 'personagens';
  static const notasHeroi = 'notas_heroi';
  static const missoes = 'missoes';
  static const entradas = 'entradas_missao';
  static const npcs = 'npcs';
  static const sessoes = 'sessoes';
  static const registros = 'registros_mesa';

  // colunas de filtro e ordem
  static const id = 'id';
  static const nome = 'nome';
  static const texto = 'texto';
  static const donoId = 'dono_id';
  static const campanhaId = 'campanha_id';
  static const personagemId = 'personagem_id';
  static const missaoId = 'missao_id';
  static const criadoEm = 'criado_em';

  // campanha inteira num select so
  static const campanhaInteira =
      '*, missoes(*, entradas:entradas_missao(*)), npcs(*), sessoes(*)';

  // rpcs
  static const entrarCampanha = 'entrar_campanha';
  static const sairCampanha = 'sair_campanha';
  static const removerHeroi = 'remover_heroi';
  static const novoCodigo = 'novo_codigo';
  static const iniciarSessao = 'iniciar_sessao';
  static const encerrarSessao = 'encerrar_sessao';
  static const darXp = 'dar_xp';
  static const darItem = 'dar_item';
  static const desfazerRegistro = 'desfazer_registro';
  static const concluirMissao = 'concluir_missao';
  static const falharMissao = 'falhar_missao';
  static const ativarHeroi = 'ativar_heroi';
  static const apagarMinhaConta = 'apagar_minha_conta';

  // realtime: tabelas da mesa que mudam ao vivo
  static const tabelasDaMesa = [
    personagens,
    missoes,
    entradas,
    npcs,
    sessoes,
    registros,
  ];
}
