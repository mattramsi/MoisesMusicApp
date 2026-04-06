# Moises Music App

An iOS app that searches for songs via Apple iTunes API, built as a code challenge for Moises.ai.

## Features

- **Song Search**: Search for songs using the iTunes Search API
- **Recently Played**: View your recently played tracks
- **Audio Preview**: Play 30-second song previews
- **Album Details**: View album information and track listings
- **Offline Support**: Cached recently played songs via SwiftData
- **Dark Mode**: Beautiful dark theme throughout

## Architecture

This project follows **Clean Architecture** principles with a modular **Swift Package Manager (SPM)** structure:

```
┌─────────────────────────────────────────────────────────────┐
│                    MoisesMusicApp (Main Target)             │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  Presentation │    │     Data      │    │  Persistence  │
│    (UI Kit)   │    │ (Repositories)│    │  (SwiftData)  │
└───────────────┘    └───────────────┘    └───────────────┘
        │                    │                     │
        └────────────┬───────┴─────────────────────┘
                     ▼
            ┌───────────────┐
            │    Domain     │
            │  (Entities,   │
            │   UseCases)   │
            └───────────────┘
                     │
                     ▼
            ┌───────────────┐
            │     Core      │
            │  (Network,    │
            │   Utilities)  │
            └───────────────┘
```

### Module Descriptions

| Module | Responsibility |
|--------|---------------|
| **Core** | Network abstraction, utilities, extensions, audio player service |
| **Domain** | Business entities (`Song`, `Album`), use cases, repository protocols |
| **Data** | Repository implementations, DTOs, mappers, iTunes data source |
| **Persistence** | SwiftData models, local data source for caching |
| **Presentation** | SwiftUI views, view models, design system components |

## Tech Stack

- **Swift 6** with strict concurrency checking
- **SwiftUI** for declarative UI
- **SwiftData** for local persistence
- **MVVM** architecture with `@Observable`
- **Async/await** for all async operations
- **Swift Package Manager** for modularization
- **swift-snapshot-testing** for UI regression tests

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 6.0+

## Getting Started

### Clone & Open

```bash
git clone <repository-url>
cd MoisesMusicApp
open MoisesMusicApp.xcodeproj
```

### Build & Run

1. Select the `MoisesMusicApp` scheme
2. Choose a simulator or device (iOS 17+)
3. Press `Cmd + R` to build and run

### Run Tests

```bash
# Run all tests
xcodebuild test -project MoisesMusicApp.xcodeproj -scheme MoisesMusicApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Or run package tests individually
cd Packages/Core && swift test
cd Packages/Domain && swift test
cd Packages/Data && swift test
cd Packages/Persistence && swift test
cd Packages/Presentation && swift test
```

## Project Structure

```
MoisesMusicApp/
├── MoisesMusicApp.xcodeproj/
├── MoisesMusicApp/
│   ├── App/
│   │   ├── MoisesMusicApp.swift
│   │   ├── AppDependencyContainer.swift
│   │   └── RootView.swift
│   └── Resources/
│       └── Assets.xcassets
│
├── Packages/
│   ├── Core/
│   ├── Domain/
│   ├── Data/
│   ├── Persistence/
│   └── Presentation/
│
├── .gitignore
└── README.md
```

## API Reference

This app uses the [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html):

- **Search endpoint**: `https://itunes.apple.com/search`
- **Lookup endpoint**: `https://itunes.apple.com/lookup`

## Testing

### Unit Tests

Each module contains its own test target with unit tests for:
- Network layer (Core)
- Use cases (Domain)
- Repository implementations (Data)
- SwiftData operations (Persistence)
- View models (Presentation)

### Snapshot Tests

The Presentation module includes snapshot tests using Point-Free's `swift-snapshot-testing` library to ensure UI consistency across:
- SplashView
- SongsView (all states)
- SongRowView
- PlayerView (all states)
- AlbumView

## Design System

### Colors

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#1C1C1E` | Main background |
| Card | `#2C2C2E` | Card surfaces |
| Search Bar | `#3A3A3C` | Input backgrounds |
| Accent | `#007AFF` | Interactive elements |
| Primary Text | `#FFFFFF` | Main text |
| Secondary Text | `#8E8E93` | Supporting text |

### Typography

Uses SF Pro with standard iOS sizes for accessibility and readability.

## Git Workflow

This project uses conventional commits:

- `feat:` New features
- `fix:` Bug fixes
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `docs:` Documentation
- `chore:` Maintenance

## License

This project is for demonstration purposes as part of a code challenge.

## Author

Built with care for Moises.ai
