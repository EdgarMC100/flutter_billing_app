# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Offline-first mobile POS & billing app built with Flutter. Targets small/medium retail shops: barcode-driven checkout, Bluetooth thermal receipt printing, and local-only data persistence via Hive (no backend/network dependency).

## Commands

```bash
flutter pub get                                          # install dependencies
dart run build_runner build --delete-conflicting-outputs # regenerate Hive adapters (*.g.dart) and JSON serializers after editing any @HiveType/@JsonSerializable model
dart run build_runner watch --delete-conflicting-outputs # same, but watches for changes
flutter run                                               # run on connected device/emulator
flutter analyze                                           # static analysis (flutter_lints)
flutter test                                              # run tests
flutter test test/widget_test.dart                        # run a single test file
```

Note: `test/widget_test.dart` is the unmodified Flutter project template (asserts a counter UI) and does not reflect this app's actual widget tree — it will fail if run as-is. There is no other test coverage yet.

Code generation is required any time a Hive model (`*_model.dart`) or JSON-annotated class changes, since `product_model.g.dart` / `shop_model.g.dart` are committed generated output.

## Architecture

Feature-first Clean Architecture. Each feature under `lib/features/<name>/` is subdivided into `data/`, `domain/`, and `presentation/` layers:

- `domain/` — entities (plain Dart, `equatable`-based) and repository interfaces; no Flutter/Hive imports.
- `data/` — Hive-backed models (`*_model.dart`, annotated with `@HiveType`, code-generated) and repository implementations that map models ↔ entities and talk to `HiveDatabase` boxes directly (repositories currently open boxes via `HiveDatabase.productBox` etc. rather than an injected data source).
- `presentation/` — `flutter_bloc` BLoCs (event/state/bloc split into three files) plus pages/widgets.

Cross-feature/shared code lives in `lib/core/`:
- `core/data/hive_database.dart` — single place Hive is initialized and boxes are opened/registered; add new adapters/boxes here.
- `core/error/failure.dart` — `Failure` (Equatable) hierarchy returned by repositories.
- `core/usecase/usecase.dart` — `UseCase<Result, Params>` contract; all use cases return `Future<Either<Failure, Result>>` via `fpdart`.
- `core/service_locator.dart` — `get_it` DI setup (`sl`); register new BLoCs/use cases/repositories here, following the existing factory-for-BLoC / lazySingleton-for-usecase-and-repository convention.
- `core/theme/`, `core/widgets/`, `core/utils/` — shared styling, reusable widgets, helpers (e.g. `PrinterHelper`).

Routing is centralized in `lib/config/routes/app_routes.dart` using `go_router` with nested routes (e.g. `/products/add`, `/products/edit/:id`, `/scanner`, `/checkout` nested under `/`). Routes needing a full object (not just an ID) pass it via `state.extra` — see the `/products/edit/:id` route, which falls back to the list page if `extra` is missing (e.g. on a cold deep link).

`lib/main.dart` wires everything at startup: `HiveDatabase.init()` → `di.init()` → `MultiBlocProvider` wrapping `MaterialApp.router`. Top-level BLoCs (`ProductBloc`, `ShopBloc`, `BillingBloc`, `PrinterBloc`) are provided app-wide rather than scoped per-page.

### Conventions to follow (per README contributing guidelines)

1. Keep strict boundaries between `domain`, `data`, and `presentation` — domain must not depend on data or Flutter.
2. BLoC states must be immutable and use `equatable`.
3. Don't throw/catch exceptions across layer boundaries for control flow; propagate errors as `Either<Failure, T>` (`fpdart`) from repositories through use cases into BLoCs.

## Key feature modules

- `billing/` — cart, checkout, barcode scanning (`mobile_scanner`), invoice/receipt flow. No `data/` layer of its own; it reuses `product`'s repository/use case for barcode lookups.
- `product/` — inventory CRUD, backed by the `products` Hive box.
- `shop/` — shop profile (name/address/etc.) rendered on printed receipts, backed by the `shop` Hive box.
- `settings/` — printer configuration/connection state (`print_bluetooth_thermal`), backed by a repository with no persistent Hive box (in-memory/device state).

## Platform notes

- Bluetooth thermal printing (`print_bluetooth_thermal`) and camera barcode scanning (`mobile_scanner`) require a physical device — they won't function meaningfully on a simulator/emulator.
- `permission_handler` / `app_settings` are used for runtime permission prompts (camera, Bluetooth); check `core/utils/` and the `settings` feature when touching permission flows.
