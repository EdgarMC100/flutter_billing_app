# Localization — Missing Labels

Tracks hardcoded strings found during Stage B testing that needed ARB keys
and migration to `AppLocalizations`. See `LOCALIZATION_PLAN.md` for the overall
staging.

All entries below are now migrated. Bloc/repository-layer strings had no
`BuildContext` available at the call site, so each bloc now emits a stable
message *code* (e.g. `ProductMessageCode.updated`) instead of literal English
text, and the presentation-layer listener maps the code to a localized
string via `AppLocalizations`.

## Notification

- [x] "Product updated successfully" — `lib/features/product/presentation/bloc/product_bloc.dart`, SnackBar message on successful product update. Now `ProductMessageCode.updated` → `l10n.productUpdatedSuccessMessage`.

## Found in the same sweep

- [x] "Product added successfully" → `ProductMessageCode.added` → `l10n.productAddedSuccessMessage`
- [x] "Product deleted successfully" → `ProductMessageCode.deleted` → `l10n.productDeletedSuccessMessage`
