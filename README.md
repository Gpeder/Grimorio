# Grimório RPG

App Flutter para acompanhar campanhas de RPG de mesa (D&D 5e): personagens, nível, vida, espaços de magia, XP, inventário e compêndio.

- Regras e compêndio vêm da **[API Open5e v2](https://api.open5e.com/v2/)** (SRD 5.1).
- **Sem rolagem de dados.** O dado físico continua na mesa: o app mostra o bônus e o jogador digita o resultado.
- Visual escuro, vinho e dourado, com itens em pixel art.

## Stack

| Uso | Pacote |
| --- | --- |
| Estado | `flutter_riverpod` |
| Navegação | `go_router` |
| HTTP | `dio` |
| Banco local | `drift`, `drift_flutter` |
| Fontes | `google_fonts` (Cinzel e Inter) |
| Ícones | `pixelarticons` |
| Barra inferior | `flutter_floating_bottom_bar` |

## Estrutura

```
images/          # pixel art (.webp)
lib/
├── app/         # shell e tema (cores, espaçamento, tipografia, imagens)
├── home/        # tela inicial
├── characters/  # personagens
├── campaign/    # campanhas
├── grimoire/    # compêndio
├── models/      # models e mocks
└── widgets/     # componentes reutilizáveis
test/            # testes de unidade e de widget
```

As regras de código e de produto para agentes de IA estão no [CLAUDE.md](CLAUDE.md).

## Como rodar

```sh
flutter pub get
cp env.example.json env.json   # preencher com a URL e a chave pública do Supabase
flutter run --dart-define-from-file=env.json
```

No VS Code o `.vscode/launch.json` já passa o `env.json`.

## Testes

```sh
dart format lib test
flutter analyze
flutter test
```

## Créditos

Este trabalho inclui material do System Reference Document 5.1 ("SRD 5.1"), da Wizards of the Coast LLC, disponível em <https://dnd.wizards.com/resources/systems-reference-document>. O SRD 5.1 é licenciado sob a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/legalcode). Os dados são obtidos pela API [Open5e](https://open5e.com/).

## Supabase

Login com e-mail e senha no Supabase Auth. Confirmação de e-mail e recuperação de senha por código de 6 números digitado no app (sem link).

Antes de rodar, no painel do Supabase:

1. **Authentication → Sign In / Providers → Email:** ligado, "Confirm email" ligado, "Email OTP length" = 6.
2. **Authentication → Policies (senha):** mínimo 8, exigir letras e dígitos.
3. **Authentication → Emails → Templates:** em "Confirm signup" e "Reset password", trocar o link por `{{ .Token }}`. Texto em PT-BR, curto. Exemplo do corpo:
   ```html
   <h2>Grimório RPG</h2>
   <p>Seu código: <strong>{{ .Token }}</strong></p>
   <p>Ele vence em 1 hora. Se não foi você, ignore este e-mail.</p>
   ```
4. **SMTP:** o e-mail padrão do Supabase manda pouquíssimos e-mails por hora. Para testar serve. Antes de publicar, configurar SMTP próprio (ex.: Resend).
5. **Project Settings → API:** copiar a URL e a chave pública (anon/publishable) para o `env.json`. **Nunca** a `service_role`.

Banco (precisa do [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) e do Docker):

```sh
supabase db reset     # aplica supabase/migrations/
supabase test db      # roda supabase/tests/
supabase db push      # manda as migrations para o projeto
```
