# Moises Music App - Claude Configuration

## Project Overview

iOS music app that searches songs via iTunes API, built as a code challenge for Moises.ai.

## Architecture

**Clean Architecture** with modular **Swift Package Manager (SPM)** structure:

```
MoisesMusicApp (Main Target)
    │
    ├── Presentation (SwiftUI Views, ViewModels, Design System)
    ├── Data (Repositories, DTOs, Mappers, iTunes DataSource)
    ├── Persistence (SwiftData models, local caching)
    │
    └── Domain (Entities: Song, Album | UseCases | Repository Protocols)
            │
            └── Core (Network, Utilities, AudioPlayer)
```

## Tech Stack

- **Swift 6** with strict concurrency
- **SwiftUI** + **MVVM** with `@Observable`
- **SwiftData** for persistence
- **Async/await** for async operations
- **iOS 17.0+** minimum

## Module Locations

| Module | Path | Responsibility |
|--------|------|----------------|
| Core | `Packages/Core/` | Network, utilities, audio player |
| Domain | `Packages/Domain/` | Entities, use cases, protocols |
| Data | `Packages/Data/` | Repository implementations, DTOs |
| Persistence | `Packages/Persistence/` | SwiftData models |
| Presentation | `Packages/Presentation/` | Views, ViewModels, Design System |
| App | `MoisesMusicApp/App/` | Entry point, DI container |

## Design System

Located in `Packages/Presentation/Sources/Presentation/DesignSystem/`:

- **Colors.swift**: `AppColors` enum with all color tokens
- **Typography.swift**: `AppTypography` enum with font styles
- **Spacing.swift**: `AppSpacing` enum with spacing constants

### Color Tokens

| Token | Usage |
|-------|-------|
| `AppColors.background` | Main background (black) |
| `AppColors.cardBackground` | Card surfaces |
| `AppColors.searchBarBackground` | Input backgrounds |
| `AppColors.primaryText` | Main text (white) |
| `AppColors.secondaryText` | Supporting text |
| `AppColors.placeholderText` | Placeholder text (#A8A8A8) |
| `AppColors.accent` | Interactive elements (blue) |

### Custom Assets

Located in `MoisesMusicApp/Resources/Assets.xcassets/`:

- `ic-back` - Back navigation button
- `ic-more` - More options button
- `ic-search` - Search button (header)
- `ic-search-stroke` - Search icon (search bar)
- `ic-skip` - Skip forward/backward
- `ic-repeat` - Repeat toggle

## Code Standards

### Naming Conventions

- **Views**: `*View.swift` (e.g., `PlayerView.swift`)
- **ViewModels**: `*ViewModel.swift` (e.g., `PlayerViewModel.swift`)
- **Components**: Descriptive names (e.g., `SongRowView.swift`, `PlaybackControlsView.swift`)
- **Boolean properties**: `is*`, `has*`, `should*` (e.g., `isPlaying`, `hasError`)

### File Organization

```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Body
// MARK: - Private Views
// MARK: - Preview
```

### SwiftUI Patterns

- Use `@Observable` for ViewModels (not `ObservableObject`)
- Use `@Bindable` to bind to Observable properties
- Prefer computed properties for derived state
- Extract complex views into private computed properties

## Build & Test Commands

```bash
# Build
xcodebuild -scheme MoisesMusicApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' build

# Test
xcodebuild -scheme MoisesMusicApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' test

# Package tests
cd Packages/Presentation && swift test
```

## Git Workflow

### Commit Format

Use conventional commits:
- `feat:` New features
- `fix:` Bug fixes
- `refactor:` Code refactoring
- `test:` Test additions
- `docs:` Documentation
- `chore:` Maintenance

### Branch Strategy

- `main` - Production ready
- `develop` - Development branch
- `feature/*` - Feature branches

## Skills Available

### `/code-review`
Deep code quality review applying DRY, SOLID, naming, and SwiftUI best practices.

## Common Tasks

### Adding a new View

1. Create `*View.swift` in appropriate feature folder
2. Create `*ViewModel.swift` with `@Observable`
3. Add preview with mock data
4. Update navigation in `RootView.swift` if needed

### Adding a new Asset

1. Add images to `Assets.xcassets/` with imageset (1x, 2x, 3x)
2. Reference with `Image("asset-name", bundle: .main)`
3. Use `.renderingMode(.template)` if color should be dynamic

### Adding a new Color

1. Add to `AppColors` enum in `Colors.swift`
2. Use `Color(hex: 0xRRGGBB)` for hex values
3. Reference as `AppColors.newColor`
