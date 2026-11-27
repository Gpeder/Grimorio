import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/campanha_service.dart';
import 'package:grimorio/service/supabase/mesa_service.dart';
import 'package:grimorio/service/supabase/missao_service.dart';
import 'package:grimorio/service/supabase/npc_service.dart';
import 'package:grimorio/service/supabase/personagem_service.dart';
import 'package:grimorio/service/supabase/realtime_service.dart';

// os services do banco juntos, para o AppProviders e os testes trocarem
class ServicosBanco {
  const ServicosBanco({
    required this.personagens,
    required this.campanhas,
    required this.missoes,
    required this.npcs,
    required this.mesa,
    required this.realtime,
  });

  factory ServicosBanco.supabase() {
    final banco = Banco();
    return ServicosBanco(
      personagens: SupabasePersonagemService(banco),
      campanhas: SupabaseCampanhaService(banco),
      missoes: SupabaseMissaoService(banco),
      npcs: SupabaseNpcService(banco),
      mesa: SupabaseMesaService(banco),
      realtime: SupabaseRealtimeService(banco),
    );
  }

  final PersonagemService personagens;
  final CampanhaService campanhas;
  final MissaoService missoes;
  final NpcService npcs;
  final MesaService mesa;
  final RealtimeService realtime;
}
