# Moises Music App

A modern iOS music app that searches songs via the iTunes API, built as a code challenge for [Moises.ai](https://moises.ai).

![iOS 17.0+](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift 6](https://img.shields.io/badge/Swift-6-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5-green.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

## Features

- Search songs from iTunes catalog
- Play song previews with audio player
- View album details and track listings
- Recently played songs history (persisted locally)
- Infinite scroll pagination
- Debounced search with minimum character threshold
- Dark mode UI design

## Screenshots

| Songs List | Player | Album |
|:----------:|:------:|:-----:|
| Search and browse songs | Full-screen audio player | Album track listing |

---

## Architecture

This project follows **Clean Architecture** principles with a modular **Swift Package Manager (SPM)** structure, ensuring separation of concerns, testability, and maintainability.

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Presentation Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  SongsView  │  │ PlayerView  │  │  AlbumView  │  │    Design System    │ │
│  │             │  │             │  │             │  │  Colors/Typography  │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └─────────────────────┘ │
│         │                │                │                                  │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐                          │
│  │SongsViewModel│ │PlayerViewModel│ │AlbumViewModel│    @Observable MVVM    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                          │
└─────────┼────────────────┼────────────────┼─────────────────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                               Domain Layer                                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │
│  │ SearchSongsUseCase│  │SaveRecentlyPlayed│  │GetAlbumSongsUseCase│         │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘           │
│           │                     │                     │                      │
│           └─────────────────────┼─────────────────────┘                      │
│                                 ▼                                            │
│                    ┌────────────────────────┐                                │
│                    │   SongRepository       │  ◄── Protocol (Interface)      │
│                    │      (Protocol)        │                                │
│                    └────────────────────────┘                                │
│                                                                              │
│  ┌─────────────┐  ┌─────────────┐                                           │
│  │    Song     │  │    Album    │  ◄── Domain Entities                      │
│  └─────────────┘  └─────────────┘                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                Data Layer                                    │
│                    ┌────────────────────────┐                                │
│                    │  SongRepositoryImpl    │  ◄── Concrete Implementation   │
│                    └───────────┬────────────┘                                │
│                                │                                             │
│              ┌─────────────────┼─────────────────┐                           │
│              ▼                                   ▼                           │
│  ┌───────────────────────┐           ┌───────────────────────┐              │
│  │   iTunesDataSource    │           │   LocalDataSource     │              │
│  │    (Remote API)       │           │   (SwiftData)         │              │
│  └───────────┬───────────┘           └───────────┬───────────┘              │
│              │                                   │                           │
│              ▼                                   ▼                           │
│  ┌───────────────────────┐           ┌───────────────────────┐              │
│  │   iTunesSearchDTO     │           │     SongEntity        │              │
│  │   (API Response)      │           │   (SwiftData Model)   │              │
│  └───────────────────────┘           └───────────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                Core Layer                                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │   HTTPClient    │  │ AudioPlayerSvc  │  │   Extensions    │              │
│  │  (Networking)   │  │  (AVFoundation) │  │   (Utilities)   │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Dependency Rule

The architecture follows the **Dependency Rule**: source code dependencies can only point inward. Nothing in an inner circle can know anything about an outer circle.

```
┌─────────────────┐
│  MoisesMusicApp │  (Main Target)
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│  Presentation   │────►│     Domain      │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│      Data       │────►│      Core       │
└────────┬────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│   Persistence   │
└─────────────────┘

Legend: ────► depends on
```

---

## Data Flow

### Unidirectional Data Flow

```
┌──────────┐    ┌───────────┐    ┌─────────┐    ┌────────────┐    ┌─────────┐
│   User   │───►│   View    │───►│ViewModel│───►│  UseCase   │───►│Repository│
│  Action  │    │(SwiftUI)  │    │(@Observable)│ │            │    │         │
└──────────┘    └───────────┘    └─────────┘    └────────────┘    └────┬────┘
                     ▲                                                  │
                     │                                                  ▼
                     │                                         ┌───────────────┐
                     │                                         │  DataSource   │
                     │              State Update               │ (Remote/Local)│
                     └─────────────────────────────────────────└───────────────┘
```

### Search Flow (Detailed)

```
User types "Queen" in search bar
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  SongsView                                                                  │
│    │                                                                        │
│    │  TextField onChange                                                    │
│    ▼                                                                        │
│  SongsViewModel.onSearchQueryChanged("Queen")                               │
│    │                                                                        │
│    │  Debounce 300ms (cancels previous search task)                         │
│    │  Validate: query.count >= 2                                            │
│    ▼                                                                        │
│  state = .loading                                                           │
│    │                                                                        │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER                                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  SearchSongsUseCase.execute(query: "Queen", offset: 0, limit: 25)           │
│    │                                                                        │
│    │  Calls repository protocol                                             │
│    ▼                                                                        │
│  SongRepository.searchSongs(query:offset:limit:)                            │
│                                                                             │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ DATA LAYER                                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  SongRepositoryImpl                                                         │
│    │                                                                        │
│    ▼                                                                        │
│  iTunesDataSource.searchSongs(term: "Queen", offset: 0, limit: 25)          │
│    │                                                                        │
│    │  Builds endpoint                                                       │
│    ▼                                                                        │
│  iTunesEndpoint.search(term:offset:limit:).endpoint                         │
│    │                                                                        │
│    │  path: "/search"                                                       │
│    │  queryItems: [term=Queen, media=music, entity=song, offset=0, limit=25]│
│    │                                                                        │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ CORE LAYER                                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  URLSessionHTTPClient.request(endpoint)                                     │
│    │                                                                        │
│    │  GET https://itunes.apple.com/search?term=Queen&media=music&entity=song│
│    │                                                                        │
│    ▼                                                                        │
│  URLSession.shared.data(for: request)                                       │
│    │                                                                        │
│    │  async/await                                                           │
│    ▼                                                                        │
│  JSONDecoder().decode(iTunesSearchResponse.self, from: data)                │
│                                                                             │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     │  Response flows back up
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ DATA LAYER (Mapping)                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│  iTunesSearchResponse (DTO)                                                 │
│    │                                                                        │
│    │  Map DTO to Domain Entity                                              │
│    ▼                                                                        │
│  [Song] (Domain Entities)                                                   │
│    │                                                                        │
│    │  Return to UseCase                                                     │
│                                                                             │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER (State Update)                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│  SongsViewModel                                                             │
│    │                                                                        │
│    │  songs = results                                                       │
│    │  hasMorePages = results.count >= pageSize                              │
│    │  state = results.isEmpty ? .empty : .loaded                            │
│    │                                                                        │
│    ▼                                                                        │
│  @Observable triggers SwiftUI re-render                                     │
│    │                                                                        │
│    ▼                                                                        │
│  SongsView displays song list                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Play Song Flow

```
User taps song row
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ NAVIGATION                                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  RootView                                                                   │
│    │                                                                        │
│    │  SongsView callback: onSongTap(song)                                   │
│    ▼                                                                        │
│  selectedSong = song                                                        │
│    │                                                                        │
│    │  Triggers .fullScreenCover(item: $selectedSong)                        │
│    ▼                                                                        │
│  PlayerView presented with PlayerViewModel                                  │
│                                                                             │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PLAYER INITIALIZATION                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  AppDependencyContainer.makePlayerViewModel(song: song)                     │
│    │                                                                        │
│    │  Injects:                                                              │
│    │    - song: Song (domain entity)                                        │
│    │    - audioPlayer: AudioPlayerService                                   │
│    │    - saveRecentlyPlayedUseCase: SaveRecentlyPlayedUseCase              │
│    │                                                                        │
│    ▼                                                                        │
│  PlayerViewModel initialized                                                │
│                                                                             │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     │  User taps play button
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ AUDIO PLAYBACK                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  PlayerViewModel.togglePlayPause()                                          │
│    │                                                                        │
│    │  if !isPlaying                                                         │
│    ▼                                                                        │
│  audioPlayer.play(url: song.previewUrl)                                     │
│    │                                                                        │
│    ▼                                                                        │
│  AudioPlayerServiceImpl (Core Layer)                                        │
│    │                                                                        │
│    │  AVPlayer.play()                                                       │
│    │  Starts time observer                                                  │
│    │                                                                        │
│    ▼                                                                        │
│  Progress updates via Combine publisher                                     │
│    │                                                                        │
│    │  currentTimePublisher emits every 0.5s                                 │
│    ▼                                                                        │
│  PlayerViewModel.currentTime updated                                        │
│    │                                                                        │
│    ▼                                                                        │
│  PlayerView progress slider updates                                         │
│                                                                             │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     │  Persist recently played (async)
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PERSISTENCE                                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  SaveRecentlyPlayedUseCase.execute(song)                                    │
│    │                                                                        │
│    ▼                                                                        │
│  SongRepository.saveRecentlyPlayed(song)                                    │
│    │                                                                        │
│    ▼                                                                        │
│  LocalDataSource.saveRecentlyPlayed(song)                                   │
│    │                                                                        │
│    ▼                                                                        │
│  SwiftData ModelContext.insert(SongEntity)                                  │
│    │                                                                        │
│    │  Persisted to local database                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### View Album Flow

```
User taps "View Album" in action sheet
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ NAVIGATION                                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  SongActionSheet                                                            │
│    │                                                                        │
│    │  onViewAlbum(song.collectionId)                                        │
│    ▼                                                                        │
│  RootView.navigationPath.append(.album(albumId))                            │
│    │                                                                        │
│    │  NavigationStack pushes AlbumView                                      │
│    ▼                                                                        │
│  AlbumView(viewModel: makeAlbumViewModel(albumId))                          │
│                                                                             │
└────┼────────────────────────────────────────────────────────────────────────┘
     │
     │  AlbumViewModel.onAppear()
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ ALBUM DATA FETCH                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  AlbumViewModel.loadAlbum()                                                 │
│    │                                                                        │
│    │  state = .loading                                                      │
│    ▼                                                                        │
│  GetAlbumSongsUseCase.execute(albumId: albumId)                             │
│    │                                                                        │
│    ▼                                                                        │
│  SongRepository.getSongsForAlbum(id: albumId)                               │
│    │                                                                        │
│    ▼                                                                        │
│  iTunesDataSource.lookupAlbum(id: albumId)                                  │
│    │                                                                        │
│    │  GET https://itunes.apple.com/lookup?id={albumId}&entity=song          │
│    ▼                                                                        │
│  Returns album metadata + all songs                                         │
│    │                                                                        │
│    │  First result = Album info                                             │
│    │  Remaining results = Songs                                             │
│    ▼                                                                        │
│  AlbumViewModel updates:                                                    │
│    - album: Album?                                                          │
│    - songs: [Song]                                                          │
│    - state = .loaded                                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Module Structure

```
MoisesMusicApp/
├── MoisesMusicApp/                    # Main App Target
│   ├── App/
│   │   ├── MoisesMusicApp.swift       # @main entry point
│   │   ├── AppDependencyContainer.swift # DI container (lazy initialization)
│   │   └── RootView.swift             # Navigation coordinator
│   └── Resources/
│       └── Assets.xcassets/           # App icons, images, colors
│
└── Packages/                          # SPM Modules
    │
    ├── Core/                          # Foundation Layer
    │   └── Sources/Core/
    │       ├── Network/
    │       │   ├── HTTPClient.swift          # Protocol: generic request
    │       │   ├── URLSessionHTTPClient.swift # Implementation
    │       │   ├── Endpoint.swift            # URL builder
    │       │   └── NetworkError.swift        # Error types
    │       ├── Audio/
    │       │   └── AudioPlayerService.swift  # AVPlayer wrapper
    │       ├── Extensions/
    │       │   ├── Date+Extensions.swift
    │       │   └── View+Extensions.swift
    │       └── Utils/
    │           └── TimeFormatter.swift
    │
    ├── Domain/                        # Business Logic Layer
    │   └── Sources/Domain/
    │       ├── Entities/
    │       │   ├── Song.swift               # Core business object
    │       │   └── Album.swift              # Album metadata
    │       ├── Repositories/
    │       │   └── SongRepository.swift     # Protocol (Dependency Inversion)
    │       └── UseCases/
    │           ├── SearchSongsUseCase.swift
    │           ├── GetRecentlyPlayedUseCase.swift
    │           ├── SaveRecentlyPlayedUseCase.swift
    │           └── GetAlbumSongsUseCase.swift
    │
    ├── Data/                          # Data Access Layer
    │   └── Sources/Data/
    │       ├── DTOs/
    │       │   └── iTunesSearchResponse.swift  # API response models
    │       ├── DataSources/
    │       │   └── iTunesDataSource.swift      # Remote API client
    │       ├── Repositories/
    │       │   └── SongRepositoryImpl.swift    # Concrete implementation
    │       └── Mappers/
    │           └── SongMapper.swift            # DTO -> Entity
    │
    ├── Persistence/                   # Local Storage Layer
    │   └── Sources/Persistence/
    │       ├── Models/
    │       │   └── SongEntity.swift          # SwiftData @Model
    │       ├── SwiftDataSource.swift         # CRUD operations
    │       └── ModelContainer+Extensions.swift
    │
    └── Presentation/                  # UI Layer
        ├── Sources/Presentation/
        │   ├── DesignSystem/
        │   │   ├── Colors.swift              # AppColors enum
        │   │   ├── Typography.swift          # AppTypography enum
        │   │   ├── Spacing.swift             # AppSpacing enum
        │   │   └── Strings.swift             # Localized strings
        │   ├── Components/
        │   │   ├── SearchBarView.swift
        │   │   ├── SongActionSheet.swift
        │   │   └── AsyncImageView.swift
        │   ├── Songs/
        │   │   ├── SongsView.swift
        │   │   ├── SongsViewModel.swift
        │   │   └── Components/
        │   │       └── SongRowView.swift
        │   ├── Player/
        │   │   ├── PlayerView.swift
        │   │   ├── PlayerViewModel.swift
        │   │   └── Components/
        │   │       ├── PlaybackControlsView.swift
        │   │       └── ProgressSliderView.swift
        │   ├── Album/
        │   │   ├── AlbumView.swift
        │   │   └── AlbumViewModel.swift
        │   └── Splash/
        │       └── SplashView.swift
        │
        └── Tests/PresentationTests/
            ├── ViewModelTests/
            │   └── SongsViewModelTests.swift
            └── SnapshotTests/
                ├── SongsViewSnapshotTests.swift
                ├── PlayerViewSnapshotTests.swift
                ├── AlbumViewSnapshotTests.swift
                ├── SongRowSnapshotTests.swift
                └── SplashViewSnapshotTests.swift
```

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Language** | Swift 6 (strict concurrency) |
| **UI Framework** | SwiftUI 5 |
| **Architecture** | Clean Architecture + MVVM |
| **State Management** | @Observable (Observation framework) |
| **Persistence** | SwiftData |
| **Networking** | URLSession + async/await |
| **Audio** | AVFoundation (AVPlayer) |
| **Dependency Injection** | Manual (AppDependencyContainer) |
| **Testing** | XCTest + swift-snapshot-testing |
| **Minimum iOS** | 17.0 |

---

## Design System

The app uses a centralized design system located in `Packages/Presentation/Sources/Presentation/DesignSystem/`:

### Colors (`AppColors`)

| Token | Usage | Value |
|-------|-------|-------|
| `background` | Main background | Black |
| `cardBackground` | Card surfaces | Dark gray |
| `searchBarBackground` | Input backgrounds | #1C1C1E |
| `primaryText` | Main text | White |
| `secondaryText` | Supporting text | Gray |
| `placeholderText` | Placeholder text | #A8A8A8 |
| `accent` | Interactive elements | Blue |

### Typography (`AppTypography`)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `largeTitle` | 34pt | Bold | Screen titles |
| `title` | 22pt | Bold | Section headers |
| `headline` | 17pt | Semibold | Card titles |
| `body` | 17pt | Regular | Body text |
| `caption` | 12pt | Regular | Metadata |

### Spacing (`AppSpacing`)

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4pt | Minimal spacing |
| `sm` | 8pt | Tight spacing |
| `md` | 16pt | Standard spacing |
| `lg` | 24pt | Section spacing |
| `xl` | 32pt | Large gaps |

---

## Getting Started

### Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 6

### Installation

1. Clone the repository:
```bash
git clone https://github.com/mattramsi/MoisesMusicApp.git
cd MoisesMusicApp
```

2. Open in Xcode:
```bash
open MoisesMusicApp.xcodeproj
```

3. Build and run on simulator or device (iOS 17.0+)

### Build Commands

```bash
# Build the project
xcodebuild -scheme MoisesMusicApp \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
  build

# Run all tests
xcodebuild -scheme MoisesMusicApp \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
  test

# Run package tests only
cd Packages/Presentation && swift test
```

---

## Testing

The project includes comprehensive tests:

### Unit Tests
- **ViewModelTests**: Test ViewModel logic, state transitions, and business rules
- **UseCaseTests**: Test business logic in isolation with mocked repositories
- **RepositoryTests**: Test data mapping and flow between layers

### Snapshot Tests
Using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) for UI regression testing:

| Test Suite | Coverage |
|------------|----------|
| `SongsViewSnapshotTests` | Empty state, loading, results, empty search |
| `PlayerViewSnapshotTests` | Playing, paused, progress states |
| `AlbumViewSnapshotTests` | Loading, with tracks |
| `SongRowSnapshotTests` | Default, explicit, long text, skeleton |
| `SplashViewSnapshotTests` | Launch screen |

```bash
# Run snapshot tests
cd Packages/Presentation
swift test --filter Snapshot
```

---

## API Reference

The app uses the [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/):

### Search Songs
```
GET https://itunes.apple.com/search
  ?term={query}
  &media=music
  &entity=song
  &offset={offset}
  &limit={limit}
```

### Album Lookup
```
GET https://itunes.apple.com/lookup
  ?id={albumId}
  &entity=song
```

---

## Git Workflow

### Branch Strategy
- `main` - Production ready code
- `develop` - Development branch
- `feature/*` - Feature branches

### Commit Convention
Using [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Usage |
|--------|-------|
| `feat:` | New features |
| `fix:` | Bug fixes |
| `refactor:` | Code refactoring |
| `test:` | Test additions/changes |
| `docs:` | Documentation |
| `chore:` | Maintenance |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

Built with care for [Moises.ai](https://moises.ai)
