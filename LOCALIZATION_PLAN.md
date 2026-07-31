# Localization (i18n) Plan

Status: **All stages (A–D) complete.**

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

## Decisions (confirmed)

1. **Languages**: English + Spanish.
2. **Locale source**: manual switch in Settings, persisted in Hive `settingsBox` (`locale` key) — no device-locale auto-detection.

## Stage A — Infra (done)

Implemented via official Flutter `gen-l10n`:
- `pubspec.yaml`: added `flutter_localizations` (SDK), bumped `intl` to `^0.20.2` (pinned transitively by `flutter_localizations`), `generate: true`.
- `l10n.yaml` (repo root): `arb-dir: lib/l10n`, output to `lib/l10n/generated/` (committed, not synthetic package), `nullable-getter: false`.
- `lib/l10n/app_en.arb` + `app_es.arb`: 5 keys seeded so far (Preferences section title, Language row title, language dialog title, English/Spanish display names). Nothing else migrated yet.
- New `lib/features/settings/{domain,data}/repositories/locale_repository{,_impl}.dart` and `presentation/bloc/locale_{event,state,bloc}.dart`, mirroring the `printer` sub-feature 1:1 (no usecase layer, plain Hive get/put with `'locale'` key, default `'en'`).
- `service_locator.dart`: `LocaleBloc` factory + `LocaleRepository` lazy singleton registered.
- `main.dart`: `LocaleBloc` added to `MultiBlocProvider`, `MaterialApp.router` wrapped in `BlocBuilder<LocaleBloc, LocaleState>` supplying `locale`/`localizationsDelegates`/`supportedLocales`.
- `settings_page.dart`: new "Preferences" section with a "Language" row opening a radio-button dialog (`RadioGroup<String>` — the current non-deprecated API, not the old `RadioListTile.groupValue`).
- Verified end-to-end via `flutter run -d chrome`: language switches instantly, persists across a full page reload (cold start), `flutter analyze` clean (only pre-existing unrelated infos).

## Stage B — Migrate strings (done)

Swept every feature page, replacing hardcoded `Text()`/hints/labels/SnackBars/dialogs with `AppLocalizations.of(context).key`:
- `home_page.dart`, `product_list_page.dart`, `add_product_page.dart`, `edit_product_page.dart`, `settings_page.dart`, `checkout_page.dart`, `scanner_page.dart`, `shop_details_page.dart`.
- `AppValidators.price` refactored from a static function with hardcoded messages to a factory taking `requiredMessage`/`invalidMessage`/`negativeMessage` params (mirroring the existing `AppValidators.required(message)` pattern), so call sites pass localized text.
- Shared/generic strings (e.g. "Cancel", "Delete", "Add Product", barcode hint/required-error, scanner hint) were consolidated into `common*`/reused keys rather than duplicated per page.
- Deliberately left untranslated: example placeholder data in form hints (e.g. `'e.g. QuickMart Superstore'`, sample address/phone/UPI examples) and the default fallback shop name/initials (`'Elite Groceries'`/`'EG'`) — these are illustrative sample data, not app UI chrome.
- **Bloc/repository-layer strings** (`product_bloc.dart`, `billing_bloc.dart`, `printer_bloc.dart`): these have no `BuildContext`, so each bloc now emits a stable message *code* (e.g. `ProductMessageCode.added`, `PrinterMessageCode.noPairedDevices`, `BillingErrorCode.autoConnectFailed`) instead of literal English text; the presentation-layer `BlocListener`/`BlocConsumer` maps the code to a localized string via `AppLocalizations`. `BillingErrorCode.printFailedPrefix` is a special case — the raw exception text after the prefix is left untranslated (same convention as `CacheFailure`'s `e.toString()` messages, which are technical and not meant to be localized).

## Stage C — Printer receipt (done)

`printer_helper.dart`'s `printReceipt(...)` now takes `itemColumnLabel`/`priceColumnLabel`/`totalColumnLabel`/`totalLinePrefix` as required parameters instead of hardcoding `'Item ... Price ... Total'` and `'TOTAL: $total'`. The header line is now built with `padRight(...)` from the labels (same pattern already used for item rows), so translators don't need to manage column-alignment whitespace inside the ARB value.
- `PrintReceiptEvent` (`billing_event.dart`) gained the 4 new fields; `billing_bloc.dart` passes them straight through to `printReceipt(...)`.
- `checkout_page.dart` (which has a `BuildContext`) resolves the 4 labels via `AppLocalizations` and supplies them when constructing `PrintReceiptEvent`.

## Stage D — Audit (done)

- Full-project `flutter analyze` after all migrations matches the original Stage A baseline exactly (same 13 pre-existing infos, zero new issues).
- Grep sweep (`Text('...'`, `hintText: '...'`, `labelText: '...'`) across `lib/features/` and `lib/core/` found no remaining hardcoded literals.
- `LOCALIZATION_MISSING_LABELS.md` tracked and resolved the "Product added/updated/deleted successfully" bloc messages found during on-device testing.

## Status: complete

All four stages are done. Both `app_en.arb`/`app_es.arb` are the source of truth; `lib/l10n/generated/*.dart` is regenerated via `flutter gen-l10n` (or any `flutter run`/`pub get`, since `generate: true` is set) and should never be hand-edited.

Verified end-to-end on a physical device (moto g15) and the `Pixel_8_API_35` emulator across Home, Product Management, Add/Edit Product, Settings, Checkout, Scanner, and Shop Details in both English and Spanish.
