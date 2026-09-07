# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Cinemapedia is a Flutter movie-browsing app built against The Movie DB (TMDB) API. It's a course project (`curso_fernando`) — the goal is for the user to *learn* Flutter/Dart, not just to get features merged.

## Working style (this project is for learning)

- Explain the concept, the architecture decision, and the "why" behind any change in detail before/alongside the code.
- Do **not** use Edit/Write to author implementation code directly in this repo, unless the user explicitly asks you to make the edit yourself in that message (e.g. "modify the file", "just do it"). Default to giving the code as a snippet in the chat for the user to copy-paste or type themselves; only switch to editing directly when explicitly told to for that specific change — it reverts back to snippet-only for the next change unless asked again.
- Reading files, running commands (`flutter test`, `flutter analyze`, `flutter run`, etc.), and research/exploration are fine to do directly — only the actual authoring of implementation code defaults to being left to the user.

## Setup

Copy `.env.template` to `.env` and set `THE_MOVIEDB_KEY` to a valid TMDB API key. `.env` is loaded at startup via `flutter_dotenv` (see `lib/main.dart`) and is declared as a Flutter asset in `pubspec.yaml`, so it must exist (even if empty) for the app to build/run.

## Commands

```
flutter pub get                          # install dependencies
flutter run                              # run the app (select device/emulator)
flutter analyze                          # lint (uses flutter_lints via analysis_options.yaml)
flutter test                             # run all tests
flutter test test/widget_test.dart       # run a single test file
flutter test --plain-name "<test name>"  # run a single test by name
```

## Architecture

The code follows a layered/clean architecture under `lib/`, organized by layer first, then by feature (`movies`):

- **`domain/`** — pure Dart, no dependencies on Flutter or external packages. Defines the `Movie` entity, and abstract contracts (`MoviesDatasource`, `MoviesRepository`) that the rest of the app depends on.
- **`infrastructure/`** — concrete implementations of the domain contracts:
  - `models/moviedb/` — JSON-serializable models matching TMDB's API response shape (`MovieMovieDB`, `MovieDbResponse`).
  - `mappers/movie_mapper.dart` — converts `MovieMovieDB` (API model) into `Movie` (domain entity). This is where backdrop/poster URLs are built (prefixed with `https://image.tmdb.org/t/p/w500...`) and missing-image fallbacks are applied.
  - `datasources/moviedb_datasource.dart` — implements `MoviesDatasource` using `Dio` against `https://api.themoviedb.org/3`, injecting `api_key` and `language` (`es-MX`) as default query params. Filters out movies with no poster.
  - `repositories/movie_repository_impl.dart` — implements `MoviesRepository` by delegating to a `MoviesDatasource`.
- **`presentation/`** — Flutter/Riverpod layer:
  - `providers/movies/movies_repository_provider.dart` — wires `MoviedbDatasource` → `MovieRepositoryImpl` behind `movieRepositoryProvider`. This is the single place a concrete datasource/repository is constructed; swapping the data source means changing only this file.
  - `providers/movies/movies_providers.dart` — `nowPlayingMoviesProvider`, a `StateNotifierProvider<MoviesNotifier, List<Movie>>` that paginates through `getNowPlaying`, appending pages to its state via `loadNextPage()`.
  - `providers/movies/movies_slideshow_provider.dart` — a derived `Provider` that watches `nowPlayingMoviesProvider` and exposes the first 6 movies for the slideshow. Note this provider is **not** re-exported from `providers/providers.dart`; import it directly where needed.
  - `screens/` and `widgets/` — UI. Barrel files (`screens.dart`, `widgets.dart`) re-export individual screens/widgets for shorter imports elsewhere; when adding a new screen or shared widget, add its export there too.
- **`config/`**
  - `router/app_router.dart` — single `go_router` instance (`appRouter`), routes registered with a static `name` constant on each screen (e.g. `HomeScreen.name`).
  - `constants/environment.dart` — typed accessors over `flutter_dotenv` env values (e.g. `Environment.theMovieDbKey`).
  - `theme/app_theme.dart` — Material 3 theme (`AppTheme().getTheme()`), wired in `main.dart`.

### Data flow

`MoviedbDatasource` (Dio call to TMDB) → `MovieMapper.movieDBToEntity` → `MovieRepositoryImpl` → `movieRepositoryProvider` → `nowPlayingMoviesProvider` (pagination state) → derived providers like `moviesSlidesshowProvider` → widgets/screens via `ref.watch`.

When adding a new TMDB endpoint, follow this same chain: add the method to `MoviesDatasource`/`MoviesRepository` abstracts, implement it in `MoviedbDatasource`/`MovieRepositoryImpl`, then expose it through a new or existing Riverpod provider.
