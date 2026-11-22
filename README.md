# Grimório RPG

App Flutter para gerenciar campanhas de RPG de mesa: personagens, nível, vida, espaços de magia, XP, inventário e compêndio.

- Os dados de D&D 5e vêm da **[API Open5e v2](https://api.open5e.com/v2/)** (SRD 5.1, `document__key=srd-2014`).
- **Não tem rolagem de dados.** Dado físico é insubstituível: o app mostra o bônus ("Ataque +5", "1d8 + 3") e o jogador digita o resultado.

## Identidade visual

- Só tema escuro
- Paleta vinho e dourado (`lib/app/theme/app_colors.dart`)
- Tipografia: **Cinzel** (display, headline, title) e **Inter** (body, label)
- Itens em pixel art, sempre nítidos (`FilterQuality.none`, escala inteira)
- Card com moldura dupla dourada (`AppCard`) é o padrão de todo container

## Stack

| Uso | Pacote |
| --- | --- |
| Estado | `flutter_riverpod` |
| Navegação | `go_router` |
| HTTP | `dio` |
| Banco local | `drift`, `drift_flutter` |
| Fontes | `google_fonts` |
| Ícones | `hugeicons`, `pixelarticons` |
| Barra inferior | `flutter_floating_bottom_bar` |

## Estrutura

```
images/                # assets em pixel art (.webp), declarados no pubspec.yaml
lib/
├── app/
│   └── theme/         # cores, espaçamento, tipografia, ThemeData
├── home/              # tela inicial
├── widgets/           # componentes reutilizáveis (AppCard, ImageFrame, ProgressBar…)
└── main.dart
```

Os estilos de botão, divisor, card e campos ficam no tema (`lib/app/theme/app_theme.dart`); os widgets não passam `style:` próprio.

## Regras para agentes de IA

Leia antes de gerar tela ou componente:

1. Nada de dado: sem ícone, botão "Rolar" ou sorteio.
2. Só tema escuro. Não criar variante clara.
3. Cores, espaços e fontes só do tema. Nada de `Color(0x…)`, `TextStyle` ou `EdgeInsets` soltos.
4. Reaproveitar `lib/widgets/` antes de criar componente novo.
5. Sem gradiente roxo, neon, glassmorphism ou emoji. Raio máximo 12.
6. Textos da interface em português do Brasil.

### Skills

Carregue **só a skill da tarefa**, não todas.

| Tarefa | Skill |
| --- | --- |
| Criar ou ajustar tela/componente | `flutter-build-responsive-layout` + `kill-ai-slop` |
| Nova feature (model, repo, provider) | `flutter-apply-architecture-best-practices` |
| Rotas | `flutter-setup-declarative-routing` |
| Teste de widget | `flutter-add-widget-test` |
| Teste de lógica (XP, HP, modificadores) | `dart-add-unit-test` |
| Conflito de pacote | `dart-resolve-package-conflicts` |
| Antes de dizer "pronto" | `dart-run-static-analysis` + `verification-before-completion` |

Não usar: `flutter-setup-localization` (app só em PT-BR) e `test-driven-development` (só se pedido).

## Como rodar

```sh
flutter pub get
flutter run
```

## Validação

```sh
dart format lib test
flutter analyze
flutter test
```