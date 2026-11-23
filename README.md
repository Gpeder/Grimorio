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
flutter run
```

## Testes

```sh
dart format lib test
flutter analyze
flutter test
```

## Créditos

Este trabalho inclui material do System Reference Document 5.1 ("SRD 5.1"), da Wizards of the Coast LLC, disponível em <https://dnd.wizards.com/resources/systems-reference-document>. O SRD 5.1 é licenciado sob a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/legalcode). Os dados são obtidos pela API [Open5e](https://open5e.com/).
