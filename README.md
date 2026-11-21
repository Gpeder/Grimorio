# Grimório RPG

App Flutter para gerenciar campanhas de RPG de mesa: personagens, nível, vida, mana, XP, inventário e compêndio.

- Os dados de D&D 5e vêm da **[API Open5e v2](https://api.open5e.com/v2/)**.
- **Não tem rolagem de dados.** Dado físico é insubstituível.

## Identidade visual

- Só tema escuro
- Paleta vinho e dourado
- Tipografia: **Cinzel** (display, headline, title) e **Inter** (body, label)
- Itens em pixel art

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
