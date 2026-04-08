import Foundation
import Domain
import Core
import Observation

public enum ViewState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case loadingMore
    case error(String)
    case empty
}

@Observable
@MainActor
public final class SongsViewModel {
    public private(set) var songs: [Song] = []
    public private(set) var recentlyPlayed: [Song] = []
    public private(set) var state: ViewState = .idle
    public var searchQuery: String = ""

    private let searchSongsUseCase: any SearchSongsUseCaseProtocol
    private let getRecentlyPlayedUseCase: any GetRecentlyPlayedUseCaseProtocol

    private var currentOffset = 0
    private let pageSize = 25
    private(set) var hasMorePages = true
    private var searchTask: Task<Void, Never>?

    // Debounce configuration
    private let debounceDelay: Int = 300  // milliseconds
    private let minimumCharacters: Int = 2

    public init(
        searchSongsUseCase: any SearchSongsUseCaseProtocol,
        getRecentlyPlayedUseCase: any GetRecentlyPlayedUseCaseProtocol
    ) {
        self.searchSongsUseCase = searchSongsUseCase
        self.getRecentlyPlayedUseCase = getRecentlyPlayedUseCase
    }

    public func onAppear() async {
        await loadRecentlyPlayed()
    }

    public func search() {
        searchTask?.cancel()

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            songs = []
            state = .idle
            return
        }

        searchTask = Task {
            await performSearch(query: query)
        }
    }

    public func onSearchQueryChanged(_ newQuery: String) {
        searchTask?.cancel()

        let trimmed = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            songs = []
            state = .idle
            return
        }

        guard trimmed.count >= minimumCharacters else {
            songs = []
            state = .idle
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(debounceDelay))
            } catch { return }

            guard !Task.isCancelled else { return }
            await performSearch(query: trimmed)
        }
    }

    private func performSearch(query: String) async {
        state = .loading
        currentOffset = 0
        hasMorePages = true

        do {
            let results = try await searchSongsUseCase.execute(query: query, offset: 0, limit: pageSize)

            guard !Task.isCancelled else { return }

            songs = results
            hasMorePages = results.count >= pageSize
            state = results.isEmpty ? .empty : .loaded
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }
    }

    public func loadMore() async {
        guard state == .loaded, hasMorePages else { return }

        state = .loadingMore
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let newOffset = currentOffset + pageSize

        do {
            let results = try await searchSongsUseCase.execute(query: query, offset: newOffset, limit: pageSize)

            songs.append(contentsOf: results)
            currentOffset = newOffset
            hasMorePages = results.count >= pageSize
            state = .loaded
        } catch {
            state = .loaded // Keep showing existing results on pagination error
        }
    }

    public func refresh() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            await loadRecentlyPlayed()
        } else {
            await performSearch(query: query)
        }
    }

    private func loadRecentlyPlayed() async {
        do {
            recentlyPlayed = try await getRecentlyPlayedUseCase.execute()
        } catch {
            // Silently fail for recently played - not critical
        }
    }

    public var showRecentlyPlayed: Bool {
        searchQuery.isEmpty && !recentlyPlayed.isEmpty
    }

    public var showEmptyRecentlyPlayed: Bool {
        searchQuery.isEmpty && recentlyPlayed.isEmpty && state != .loading
    }
}

// MARK: - Preview Support

public extension SongsViewModel {
    static func preview(
        songs: [Song] = [],
        recentlyPlayed: [Song] = [],
        state: ViewState = .idle,
        searchQuery: String = ""
    ) -> SongsViewModel {
        let viewModel = SongsViewModel(
            searchSongsUseCase: PreviewSearchSongsUseCase(),
            getRecentlyPlayedUseCase: PreviewGetRecentlyPlayedUseCase()
        )
        viewModel.songs = songs
        viewModel.recentlyPlayed = recentlyPlayed
        viewModel.state = state
        viewModel.searchQuery = searchQuery
        return viewModel
    }
}

private struct PreviewSearchSongsUseCase: SearchSongsUseCaseProtocol {
    func execute(query: String, offset: Int, limit: Int) async throws -> [Song] { [] }
}

private struct PreviewGetRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol {
    func execute() async throws -> [Song] { [] }
}
