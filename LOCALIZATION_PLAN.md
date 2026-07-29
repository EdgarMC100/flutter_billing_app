# Localization (i18n) Plan

Status: **planning — paused, resume next session**

## Goal

Add multi-language support to the app.

## Current state (as of this planning session)

- No localization infrastructure exists yet (no `l10n.yaml`, no `.arb` files, no `flutter_localizations` dependency).
- `intl: ^0.19.0` is already in `pubspec.yaml`, currently only used for date formatting in `lib/core/utils/printer_helper.dart`.
- Roughly 68 `Text()` widgets with hardcoded English strings, spread across 12 files. Heaviest: `home_page.dart` (17), `product_list_page.dart` (13), `settings_page.dart` (11), `checkout_page.dart` (8), `shop_details_page.dart` (6).
- ~16 additional hardcoded strings in `hintText:`/`labelText:`/SnackBar `content:` across features.
- Printed thermal receipt text (`printer_helper.dart`) also has hardcoded strings ("Item Price Total", "TOTAL:") — `printer_helper.dart` is a plain utility class with **no `BuildContext`**, so those strings must be resolved by the caller (bloc/page) and passed in as parameters, extending the existing pattern where `shopName`/`footer` are already passed into `printReceipt(...)`.

## Approach comparison

| | **Official Flutter intl (gen-l10n)** | **easy_localization** |
|---|---|---|
| New dependency | None — `flutter_localizations` ships with the SDK, `intl` already present | Adds a third-party package + transitive deps |
| Translation files | `.arb` (structured JSON, per-locale) | Plain `.json`/`.csv`/`.yaml` |
| Access pattern | `AppLocalizations.of(context)!.scannedItems` — generated, **compile-time checked** | `'scanned_items'.tr()` — string-keyed, typos fail silently at runtime |
| Codegen | `flutter gen-l10n` runs automatically via `flutter pub get`/`flutter run` once `generate: true` is set | None — loads JSON at runtime |
| Pluralization/ICU | Built-in ICU message format | Supported, less standardized |
| Maintainer | Flutter team (core SDK) | Community package |

### Recommendation: **official Flutter intl (gen-l10n)**

Reasoning, specific to this project:

1. **Zero new dependencies** — fits the project's existing minimal-dependency pattern and reuses `intl`, which is already a dependency.
2. **Compile-time safety** — matches the codebase's existing preference for type-safety (`Either<Failure, T>`, `Equatable`) over stringly-typed patterns; avoids easy_localization's silent-fallback-on-typo behavior.
3. **No backend, no live-translation-push use case** — this is an offline-first, single-shop POS app with no remote config. easy_localization's main advantage (swap translations without rebuild) doesn't pay for itself here, since a rebuild is required for any release anyway.
4. **Modest scope either way** — ~68 strings across 12 files doesn't need the "simpler workflow" easy_localization offers to justify the extra dependency.

Tradeoff to note: ARB files are more ceremony to hand-edit than plain JSON, and `AppLocalizations.of(context)` needs a `BuildContext` — meaning `printer_helper.dart`'s receipt strings must be resolved by the caller and passed in as plain strings (same as the ARB approach would require for easy_localization too, so this isn't a differentiator between the two options).

## Open decisions (still need input — pick up here next session)

1. **Which languages to support initially?**
   - Leaning: English + Spanish (matches existing Mexican shop/pricing context already in the code, e.g. `shop_repository_impl.dart` defaults).
2. **Manual in-app language switch vs. follow device locale automatically?**
   - Leaning: manual switch in Settings, persisted in the existing Hive `settingsBox` (same pattern already used for the saved printer MAC address).

## Planned implementation stages (draft, pending confirmation of the above)

- **Stage A — Infra**: add `flutter_localizations` + `generate: true` in `pubspec.yaml`, add `l10n.yaml`, create `lib/l10n/app_en.arb` + `app_es.arb`, wire `main.dart` (`localizationsDelegates`, `supportedLocales`, `locale` sourced from Hive settings with device-locale fallback), add a Language option in `SettingsPage`.
- **Stage B — Migrate strings**: sweep each feature folder replacing hardcoded `Text()`/hints/labels/SnackBars/dialogs with `AppLocalizations.of(context)!.key`, including the recently-added "Product Not Found" dialog and `app_validators.dart` error messages.
- **Stage C — Printer receipt**: localize receipt header strings in `printer_helper.dart` by resolving them via `AppLocalizations` in the calling bloc/page and passing them into `printReceipt(...)` as new parameters.
- **Stage D — Audit**: final `flutter analyze` + manual sweep for any missed literal strings.

## Next session

Resume by confirming the two open decisions above, then start Stage A.
