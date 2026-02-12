## 0.1.2

- Added `firebase-sync` command to fetch Firebase app/project data via Firebase CLI.
- Added automatic env injection into `fastlane/.env.default` from fetched Firebase data.
- Added `init` one-shot command (`setup` + `firebase-sync` + `fetch-data`).
- Updated generated `Fastfile` `fetch_data` lane to run Firebase sync automatically.
- Added Dartdoc comments for public API symbols.
- Added `example/main.dart` for pub.dev example scoring.

## 0.1.1

- Improved executable usage with a short alias: `flc`.
- Added clear "Use this package as an executable" section in README.
- Added no-global-install command example using `dart run`.

## 0.1.0

- Initial public release.
- Added `setup` command to generate Fastlane, environment, and GitHub Actions files.
- Added `fetch-data` command to export app/git/GitHub metadata JSON.
- Added Firebase App Distribution and CI lane templates for Flutter projects.
