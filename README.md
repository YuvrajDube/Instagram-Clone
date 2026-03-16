# Instagram Feed Clone

A polished Flutter recreation of the Instagram home feed with a strong focus on interaction quality, spacing, scrolling behavior, and feed-style media presentation.

## Public Repo

Replace this placeholder after pushing the project:

`https://github.com/<your-username>/<your-repo-name>`

## What This Project Includes

- Instagram-style top bar and bottom navigation layout
- Stories tray with gradient story rings
- Feed posts with cached network images
- Multi-image carousel with centered page indicators
- In-image counter for carousel posts
- Double-tap like toggle
- Pinch-to-zoom media interaction with animated reset
- Shimmer loading state with mocked network latency
- Infinite scroll pagination
- Optimistic like/save interactions

## State Management Choice

This project uses `Provider + ChangeNotifier`.

### Why Provider?

- The feed state is moderate in complexity: pagination, loading states, optimistic like/save toggles, and post updates.
- `Provider` keeps the architecture simple, readable, and interview-friendly.
- It avoids unnecessary boilerplate while still keeping state separate from widgets.
- For this challenge, the tradeoff is right: faster implementation, clean separation, and easy explanation in a technical interview.

### Where State Lives

- `PostsRepository` handles mocked data and simulated latency.
- `PostsProvider` manages feed loading, pagination, and optimistic updates.
- Widget-local state is used only for view concerns like carousel index and media interaction behavior.

## Project Structure

```text
lib/
	app/
	models/
	providers/
	repositories/
	utils/
	widgets/
test/
```

## Main Packages Used

- `provider` for app state management
- `cached_network_image` for image caching
- `shimmer` for loading placeholders
- `smooth_page_indicator` for carousel dots
- `intl` for formatting support

## How To Run

### Prerequisites

- Flutter SDK installed
- Android Studio or VS Code with Flutter tooling
- At least one emulator or physical device connected

### Run Locally

```bash
flutter pub get
flutter run
```

### Run Checks

```bash
flutter analyze
flutter test
```

## Build Instructions

### Android debug build

```bash
flutter build apk --debug
```

### Android release build

```bash
flutter build apk --release
```

### iOS build

```bash
flutter build ios
```

## Notes About the Data Layer

- The feed is powered by a mocked repository.
- Post fetching includes an intentional delay to demonstrate the loading state.
- Like and save actions update optimistically in the UI first.

## Interaction Highlights

- Swipe horizontally through post media
- Double tap on media to like or unlike
- Pinch media to zoom and release to animate back
- Pull to refresh the feed
- Scroll near the bottom to trigger pagination

## Screens To Demo(Screenshot/ScreenRecording)

## Current Status

- `flutter pub get` works
- `flutter analyze` passes
- `flutter test` passes
