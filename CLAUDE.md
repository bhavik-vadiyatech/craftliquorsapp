# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Craft Discount Liquors is a Flutter e-commerce app (Android, iOS, Web) for a liquor delivery platform. It connects to a REST backend at `https://admin.craftdiscountliquors.com`.

- **Flutter SDK**: 3.41.1
- **Dart SDK**: ^3.8.1
- **State management**: Provider (`ChangeNotifier`)
- **Routing**: `go_router`
- **HTTP**: `dio`
- **DI**: `get_it`
- **Local DB**: `drift` (SQLite) + `shared_preferences`

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app (specify device or use Chrome for web)
flutter run
flutter run -d chrome

# Run tests (note: test/widget_test.dart is the default Flutter counter
# smoke test and does not match the real app — there is no meaningful suite)
flutter test
flutter test test/widget_test.dart   # run a single test file

# Static analysis (uses default flutter_lints rules)
flutter analyze

# Generate drift/db code (if editing lib/data/datasource/local/cache_response.dart)
dart run build_runner build

# Build for production
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## Architecture

### Feature-based structure

Each feature under `lib/features/` follows this layout:

```
features/<name>/
  domain/models/          # Data models (e.g., order_model.dart)
  domain/reposotories/    # Repository classes (note the typo: "reposotories")
  providers/              # ChangeNotifier providers
  screens/                # Page-level widgets
  widgets/                # Feature-specific reusable widgets
```

Shared code lives in `lib/common/` (models, providers, widgets, enums, repositories).

### Dependency injection

All dependencies are registered in `lib/di_container.dart` using `GetIt` (`sl`):

- **Singletons**: `DioClient`, repositories, `SharedPreferences`
- **Factories**: Providers (so each widget tree gets a fresh instance)

Providers are injected at app startup in `lib/main.dart` via `MultiProvider`.

### Data flow

1. **Screens** read from `Provider` and call methods on it.
2. **Providers** hold UI state and call **Repositories**.
3. **Repositories** use `DioClient` to hit REST endpoints defined in `AppConstants`.
4. Responses are wrapped in `ApiResponseModel`; errors go through `ApiErrorHandler`.

### Routing

`lib/helper/route_helper.dart` defines all routes as constants and a single `GoRouter` instance (`goRoutes`). Navigation helpers return route strings and optionally execute `context.push`, `pushReplacement`, or `go`. The app uses `url_strategy` for clean web URLs.

### DioClient configuration

- Base URL set from `AppConstants.baseUrl`
- Auth header: `Bearer <token>` (from `SharedPreferences`)
- Localization header: `X-localization`
- Guest ID header: `guest-id`
- 30-second connect/receive timeouts
- `LoggingInterceptor` attached for debug logging

### Web vs mobile

- `ResponsiveHelper.isDesktop(context)` is used to branch UI/layout for web.
- `kIsWeb` guards platform-specific code (Firebase init, notifications, deep links).
- Facebook Auth is initialized only on web in release mode.

### Important files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, Firebase init, provider tree |
| `lib/di_container.dart` | `get_it` registrations |
| `lib/helper/route_helper.dart` | All routing logic |
| `lib/utill/app_constants.dart` | API endpoints, shared keys, app config |
| `lib/data/datasource/remote/dio/dio_client.dart` | HTTP client |
| `lib/common/models/api_response_model.dart` | API response wrapper |
| `lib/data/datasource/local/cache_response.dart` | Drift (SQLite) cache table — regenerate `.g.dart` with build_runner |
| `lib/theme/light_theme.dart`, `lib/theme/dark_theme.dart` | App themes (Poppins font family) |

## Key Conventions

- **Repository folder spelling**: The codebase uses `reposotories` (with a typo) consistently across `lib/common/` and all features. Match this spelling when creating new folders or imports.
- **Avoid print in production**: The project uses `debugPrint` and `kDebugMode` guards.
- **Localization**: Strings use `getTranslated(context, 'key')` (from `lib/localization/language_constraints.dart`), backed by JSON files in `assets/language/`. Languages enabled in `AppConstants.languages`: English (`en`) and Spanish (`es`). (`ar`/`bn` asset files exist but are not registered.)
- **`utill` folder spelling**: Shared constants/styles live in `lib/utill/` (also a typo, like `reposotories`). Match it in imports.
- **App mode**: `AppConstants.appMode` can be `AppMode.demo` or `AppMode.release`. Demo mode skips some live integrations.
- **Maintenance mode**: `RouteHelper` checks `MaintenanceHelper` before rendering any screen and redirects to `MaintenanceScreen` if enabled.
