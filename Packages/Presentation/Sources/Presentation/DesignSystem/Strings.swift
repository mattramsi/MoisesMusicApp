import Foundation

public enum AppStrings {
    public enum Common {
        public static let cancel = "Cancel"
        public static let done = "Done"
        public static let error = "Error"
        public static let retry = "Retry"
        public static let ok = "OK"
        public static let loading = "Loading..."
        public static let somethingWentWrong = "Something went wrong"
        public static let tryAgain = "Try Again"
    }

    public enum Search {
        public static let placeholder = "Search songs, artists..."
        public static let noResults = "No results found"
        public static let title = "Search"
        public static let searchPlaceholder = "Search"
        public static let trySearchingElse = "Try searching for something else"
    }

    public enum Songs {
        public static let title = "Songs"
        public static let emptyState = "No songs yet"
        public static let searchForMusic = "Search for music"
        public static let findYourFavorite = "Find your favorite songs and artists"
    }

    public enum Player {
        public static let shuffleLabel = "Shuffle"
        public static let repeatLabel = "Repeat"
        public static let nowPlaying = "Now Playing"
        public static let playLabel = "Play"
        public static let pauseLabel = "Pause"
        public static let nextLabel = "Next"
        public static let previousLabel = "Previous"
    }

    public enum Album {
        public static let title = "Album"
        public static let tracks = "Tracks"
        public static let failedToLoad = "Failed to load album"
        public static let viewAlbum = "View album"
    }

    public enum Accessibility {
        public static let playButton = "Play"
        public static let pauseButton = "Pause"
        public static let skipForward = "Skip forward"
        public static let skipBackward = "Skip backward"
        public static let shuffle = "Shuffle"
        public static let repeatMode = "Repeat"
        public static let moreOptions = "More options"
        public static let searchButton = "Search"
        public static let backButton = "Go back"
        public static let previousTrack = "Previous track"
        public static let nextTrack = "Next track"
    }
}
