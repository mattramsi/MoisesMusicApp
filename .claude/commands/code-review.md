---
name: code-review
description: Deep code quality review applying DRY, SOLID, naming, and SwiftUI best practices
usage: /code-review [path]
---

# Deep Code Quality Review

You are performing a comprehensive code quality review on Swift files in this iOS project.

## Task

Review all new and modified Swift files (excluding test files) in the current branch, applying the principles below. Then apply the fixes.

## Scope

1. **Identify changed files**: Run `git diff --name-only HEAD~1` or `git status` to find new/modified Swift source files
2. **Read each file** fully before suggesting changes
3. **Apply fixes** incrementally, confirming each category of change
4. If a specific path is provided, focus the review on that path

## Principles to Apply

### DRY (Don't Repeat Yourself)
- Look for duplicated code blocks, repeated patterns, or copy-pasted logic
- Extract shared behavior into helper methods or computed properties
- If 3+ lines are repeated across switch cases or conditionals, extract them
- Create reusable View components for repeated UI patterns

### SOLID

- **Single Responsibility**: Each method/class should have one reason to change
- **Open/Closed**: Prefer adding computed properties to enums over external switch statements
- **Liskov Substitution**: Subclasses/implementations must be substitutable for their base types
- **Interface Segregation**: Split large protocols into smaller, focused ones
- **Dependency Inversion**: Use protocols for dependencies, inject them rather than hardcoding

### Naming
- Variable and method names must be descriptive of their purpose
- Avoid abbreviations unless universally understood (e.g., `url`, `id`)
- Boolean variables should read as questions: `isLoading`, `hasError`, `shouldRetry`
- Views should end with `View`, ViewModels with `ViewModel`

### No Redundant Comments
- Remove TODO comments, inline explanations, and redundant documentation
- `// MARK: -` comments are acceptable and encouraged for organization
- Code should be self-documenting through clear naming

### Brief Methods
- Methods longer than ~20 lines should be refactored into smaller, focused methods
- Each method should have a single level of abstraction
- Extract complex conditions into descriptively-named computed properties

### Remove Dead Code
- Remove unused variables, parameters, and methods
- Remove redundant assignments
- Remove commented-out code blocks

### SwiftUI Best Practices

#### Use Design System Tokens
- **Never** use hardcoded colors — use `AppColors.*` tokens
- **Never** use hardcoded fonts — use `AppTypography.*` tokens
- **Never** use hardcoded spacing — use `AppSpacing.*` constants
- Flag any `Color(hex:)`, `Font.system(size:)`, or magic numbers for spacing

#### View Organization
- Extract complex views into private computed properties
- Use `@ViewBuilder` for conditional view logic
- Keep `body` property focused and readable
- Group related modifiers together

#### Extract Private Views & Methods

When a View's `body` becomes hard to scan, extract nested views into private computed properties:

**Naming Conventions for Extracted Views:**
| Pattern | When to Use | Example |
|---------|-------------|---------|
| `{semantic}View` | Main content sections | `headerView`, `contentView`, `footerView` |
| `{component}Section` | Grouped UI sections | `controlsSection`, `infoSection` |
| `{action}Button` | Buttons with specific actions | `playButton`, `shuffleButton` |
| `{data}Row` | List/collection items | `songRow`, `albumRow` |
| `{state}Overlay` | Conditional overlays | `loadingOverlay`, `errorOverlay` |

**Example Extraction:**
```swift
// Before: Hard to scan
var body: some View {
    VStack {
        HStack {
            Image("album").resizable().frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Text(song.title).font(AppTypography.headline)
                Text(song.artist).font(AppTypography.subheadline)
            }
        }
        // ... more nested views
    }
}

// After: Clean and scannable
var body: some View {
    VStack {
        songInfoView
        controlsSection
        progressView
    }
}

private var songInfoView: some View {
    HStack {
        artworkView
        metadataView
    }
}

private var artworkView: some View {
    Image("album")
        .resizable()
        .frame(width: AppSpacing.artworkSizeMedium, height: AppSpacing.artworkSizeMedium)
}
```

**When to Extract:**
- View has more than 3 levels of nesting
- A section has 5+ lines of modifiers
- Logic is repeated in multiple places
- View contains conditional rendering (`if/else`, `switch`)
- View has inline closures (e.g., `.onTapGesture { ... }` with multiple statements)

#### State Management
- Use `@Observable` for ViewModels (not `ObservableObject`)
- Use `@Bindable` when binding to Observable properties
- Prefer computed properties for derived state
- Avoid unnecessary `@State` when parent owns the data

#### Asset Usage
- Use custom assets from `Assets.xcassets` when available
- Reference with `Image("asset-name", bundle: .main)`
- Use `.renderingMode(.template)` for tintable icons

### Reuse Components

Check `Packages/Presentation/Sources/Presentation/` for existing components:

- `Components/` - Shared UI components (SearchBarView, SongActionSheet, etc.)
- `DesignSystem/` - Colors, Typography, Spacing
- `Songs/Components/` - Song-related components (SongRowView, etc.)
- `Player/Components/` - Player-related components (PlaybackControlsView, etc.)

If an existing component is close but not an exact match, suggest extending it with parameters rather than duplicating code.

### Accessibility
- Ensure interactive elements have `.accessibilityLabel()`
- Use semantic colors that work with Dark Mode
- Ensure touch targets are at least 44x44 points

## Token Audit & Creation

When reviewing files, actively audit for hardcoded values and replace them with Design System tokens. If a token doesn't exist, create it first.

### Step 1: Scan for Hardcoded Values

Search the file for:

| Category | Patterns to Find |
|----------|------------------|
| **Colors** | `Color(hex:)`, `Color.white`, `Color.black`, `Color.gray`, `.opacity(X)`, `Color(uiColor:)` |
| **Fonts** | `Font.system(size:)`, `.font(.system(size:))`, `Font.custom()` |
| **Spacing** | Magic numbers in `.padding()`, `.frame()`, `.spacing()`, `.offset()` |
| **Corner Radius** | `.cornerRadius()`, `.clipShape(RoundedRectangle(cornerRadius:))` |
| **Icon Sizes** | Hardcoded `.frame(width:height:)` on icons/images |
| **Artwork Sizes** | Hardcoded dimensions for album art, thumbnails |
| **Strings** | Hardcoded UI text in `Text()`, `.accessibilityLabel()`, `.navigationTitle()`, button labels, placeholders |

### Step 2: Check Against Existing Tokens

Read the Design System files to find existing tokens:

```
Packages/Presentation/Sources/Presentation/DesignSystem/Colors.swift
Packages/Presentation/Sources/Presentation/DesignSystem/Typography.swift
Packages/Presentation/Sources/Presentation/DesignSystem/Spacing.swift
Packages/Presentation/Sources/Presentation/DesignSystem/Strings.swift
```

**Current Token Inventory:**

| File | Available Tokens |
|------|------------------|
| `Colors.swift` | `background`, `secondaryBackground`, `cardBackground`, `searchBarBackground`, `primaryText`, `secondaryText`, `tertiaryText`, `placeholderText`, `accent`, `accentGreen`, `accentRed`, `divider`, `skeleton` |
| `Typography.swift` | `largeTitle`, `title`, `title2`, `title3`, `headline`, `subheadline`, `body`, `callout`, `footnote`, `caption`, `caption2` |
| `Spacing.swift` | `xxxs(2)`, `xxs(4)`, `xs(8)`, `sm(12)`, `md(16)`, `lg(20)`, `xl(24)`, `xxl(32)`, `xxxl(40)`, `screenPadding(16)`, `cardPadding(12)`, `cornerRadiusSmall(4)`, `cornerRadiusMedium(8)`, `cornerRadiusLarge(12)`, `cornerRadiusXLarge(16)`, `iconSizeSmall(16)`, `iconSizeMedium(24)`, `iconSizeLarge(32)`, `iconSizeXLarge(48)`, `artworkSizeSmall(48)`, `artworkSizeMedium(60)`, `artworkSizeLarge(80)`, `artworkSizeXLarge(120)`, `artworkSizePlayer(280)` |
| `Strings.swift` | Check file for existing string tokens (create file if it doesn't exist) |

### Step 3: Create Missing Tokens

If a hardcoded value doesn't match any existing token:

1. **Determine the appropriate file** based on value type
2. **Choose a semantic name** following the naming conventions below
3. **Add the token** to the appropriate Design System file
4. **Then replace** the hardcoded value in the reviewed file

### Token Naming Conventions

| Category | Pattern | Examples |
|----------|---------|----------|
| **Colors** | `AppColors.{semantic}` | `buttonStroke`, `progressTrack`, `playerBackground`, `overlayBackground` |
| **Spacing** | `AppSpacing.{semantic}` | `playerArtworkTop`, `controlsSpacing`, `headerHeight` |
| **Typography** | `AppTypography.{semantic}` | Already well-covered; add only if needed |
| **Sizes** | `AppSpacing.{component}Size{variant}` | `buttonSizeGhost`, `sliderHeight`, `progressBarHeight` |
| **Strings** | `AppStrings.{Feature}.{element}` | `AppStrings.Search.placeholder`, `AppStrings.Player.shuffleLabel`, `AppStrings.Common.cancel` |

**Naming Guidelines:**
- Use **camelCase**
- Be **semantic** (describe purpose, not value): `buttonStroke` not `gray30`
- Be **specific** when context-dependent: `playerControlsSpacing` not just `spacing`
- Group related tokens: `progressTrack`, `progressFill`, `progressThumb`
- For strings, group by **feature/screen** with nested enums: `AppStrings.Player.title`, `AppStrings.Songs.emptyState`

### Step 4: Replace Hardcoded Values

After ensuring tokens exist, replace hardcoded values:

```swift
// Before
.padding(16)
.foregroundStyle(Color.white.opacity(0.5))
.font(.system(size: 14, weight: .medium))

// After
.padding(AppSpacing.md)
.foregroundStyle(AppColors.secondaryText)
.font(AppTypography.subheadline)
```

### Common Replacements

| Hardcoded | Token |
|-----------|-------|
| `Color.white` | `AppColors.primaryText` |
| `Color.black` | `AppColors.background` |
| `Color.gray` | `AppColors.secondaryText` or `AppColors.tertiaryText` |
| `.opacity(0.1)` on white | `AppColors.searchBarBackground` |
| `Font.system(size: 17)` | `AppTypography.body` or `AppTypography.headline` |
| `.padding(16)` | `.padding(AppSpacing.md)` |
| `.padding(8)` | `.padding(AppSpacing.xs)` |
| `.cornerRadius(8)` | `.cornerRadius(AppSpacing.cornerRadiusMedium)` |
| `.frame(width: 24, height: 24)` on icon | `.frame(width: AppSpacing.iconSizeMedium, height: AppSpacing.iconSizeMedium)` |
| `Text("Search")` | `Text(AppStrings.Search.placeholder)` |
| `Text("Cancel")` | `Text(AppStrings.Common.cancel)` |
| `.navigationTitle("Songs")` | `.navigationTitle(AppStrings.Songs.title)` |

### Strings File Structure

If `Strings.swift` doesn't exist, create it with this structure:

```swift
import Foundation

public enum AppStrings {
    public enum Common {
        public static let cancel = "Cancel"
        public static let done = "Done"
        public static let error = "Error"
        public static let retry = "Retry"
    }

    public enum Search {
        public static let placeholder = "Search songs, artists..."
        public static let noResults = "No results found"
    }

    public enum Songs {
        public static let title = "Songs"
        public static let emptyState = "No songs yet"
    }

    public enum Player {
        public static let shuffleLabel = "Shuffle"
        public static let repeatLabel = "Repeat"
    }

    public enum Album {
        public static let title = "Album"
    }
}
```

## Review Checklist

For each file, verify:

- [ ] No hardcoded colors (use `AppColors.*`)
- [ ] No hardcoded fonts (use `AppTypography.*`)
- [ ] No hardcoded spacing (use `AppSpacing.*`)
- [ ] No hardcoded strings (use `AppStrings.*`)
- [ ] No magic numbers without context
- [ ] No duplicated code blocks
- [ ] Methods are under 20 lines
- [ ] Complex views extracted into private computed properties
- [ ] Descriptive naming throughout
- [ ] No dead code or unused variables
- [ ] Proper use of `@Observable`/`@Bindable`
- [ ] Accessibility labels on interactive elements
- [ ] MARK comments for organization

## Output Format

After completing the review and fixes, provide a summary:

```markdown
## Code Review Summary

### Files Reviewed
- `path/to/file1.swift`
- `path/to/file2.swift`

### Changes Made

#### DRY Improvements
- Extracted `methodName()` from duplicated code in X and Y

#### Naming Improvements
- Renamed `x` to `descriptiveName`

#### Design System Compliance
- Replaced hardcoded color with `AppColors.primaryText`

#### SwiftUI Improvements
- Extracted complex view into private computed property

#### Views Extracted for Legibility
| File | Extracted View | Purpose |
|------|----------------|---------|
| `PlayerView.swift` | `controlsSection` | Play/pause, skip buttons |
| `PlayerView.swift` | `progressView` | Playback progress slider |
| `SongsView.swift` | `headerView` | Search bar and title |

#### Dead Code Removed
- Removed unused `unusedMethod()`

### Token Audit Results

#### New Tokens Created
| Token | Value | File |
|-------|-------|------|
| `AppColors.progressTrack` | `Color(hex: 0x3A3A3C)` | `Colors.swift` |
| `AppSpacing.sliderHeight` | `4` | `Spacing.swift` |
| `AppStrings.Player.nowPlaying` | `"Now Playing"` | `Strings.swift` |

#### Hardcoded Values Replaced
| File | Before | After |
|------|--------|-------|
| `PlayerView.swift:45` | `Color(hex: 0x3A3A3C)` | `AppColors.progressTrack` |
| `PlayerView.swift:67` | `.padding(16)` | `.padding(AppSpacing.md)` |
| `SongsView.swift:23` | `Text("Songs")` | `Text(AppStrings.Songs.title)` |

### Recommendations
- Consider creating a shared component for X
- ViewModel Y could benefit from protocol extraction
```

## After Applying Fixes

Run the build to verify no compilation errors:

```bash
xcodebuild -scheme MoisesMusicApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' build 2>&1 | grep -E "(BUILD|error:)"
```
