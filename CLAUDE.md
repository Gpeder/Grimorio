# Grimório RPG — instruções para o Claude

App Flutter de apoio a campanhas de D&D 5e na mesa. Dados da API Open5e v2 (SRD 5.1, `document__key=srd-2014`, keys `srd_*`).

## Regras do produto

1. **Nada de dado:** sem ícone, botão "Rolar" ou sorteio. Mostrar o bônus ("Ataque +5", "1d8 + 3") e o jogador digita o resultado.
2. **Só tema escuro.** Não criar variante clara.
3. Textos da interface em **português do Brasil**.

## Regras de código

- Cores: só `AppColors`. Nunca `Color(0x…)` solto.
- Texto: só `Theme.of(context).textTheme`. Nunca `GoogleFonts` fora de `app_typography.dart`.
- Espaços: `AppSpacing`. Raio: 8 (cards internos 4, máximo 12).
- Imagens: só via `AppImages`. Pixel art sempre com `filterQuality: FilterQuality.none`.
- Ícones de interface: `pixelarticons` (`Pixel.*`).
- Reaproveitar `lib/widgets/` (AppCard, ImageFrame, ProgressBar, ButtonInfo, AvatarCircle, ImageBg) antes de criar outro.
- Estilo de botão, divisor, card e campo fica em `app_theme.dart`. Widget não passa `style:` próprio.
- Telas dentro do `AppShell` terminam com padding inferior de 96 (barra flutuante).
- Sem gradiente roxo, neon, glassmorphism ou emoji.

## Mapa rápido

- Tema: `lib/app/theme/`
- Shell e barra: `lib/app/app_shell.dart`
- Model de personagem: `lib/models/` (valores calculados ficam como getters no model)
- Assets: `images/` — **não abrir**, os nomes estão todos em `app_images.dart`

## Skills (carregar só a da tarefa)

| Tarefa | Skill |
| --- | --- |
| Tela/componente | `flutter-build-responsive-layout` + `kill-ai-slop` |
| Feature (model, repo, provider) | `flutter-apply-architecture-best-practices` |
| Rotas | `flutter-setup-declarative-routing` |
| Teste de widget | `flutter-add-widget-test` |
| Teste de lógica | `dart-add-unit-test` |
| Conflito de pacote | `dart-resolve-package-conflicts` |
| Antes de dizer "pronto" | `dart-run-static-analysis` + `verification-before-completion` |

Não usar `flutter-setup-localization` nem `test-driven-development` sem pedido.

## Antes de terminar

```sh
dart format lib test && flutter analyze && flutter test
```

Respostas curtas, em português.
