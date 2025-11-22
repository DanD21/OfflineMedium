//
//  PostSyncService.swift
//  Offline Medium
//
//  Modern service using Combine for reactive post synchronization
//

import Foundation
import Combine

/// Service for syncing posts from Medium with Combine publishers
@MainActor
class PostSyncService: ObservableObject {

    // MARK: - Published Properties

    @Published var syncState: SyncState = .idle
    @Published var progress: Double = 0.0

    // MARK: - Dependencies

    private let databaseActor: DatabaseActor

    // MARK: - State

    enum SyncState: Equatable {
        case idle
        case fetching
        case parsing
        case downloading
        case saving
        case completed
        case failed(String)

        var description: String {
            switch self {
            case .idle: return "Ready"
            case .fetching: return "Fetching bookmarks..."
            case .parsing: return "Parsing articles..."
            case .downloading: return "Downloading images..."
            case .saving: return "Saving to database..."
            case .completed: return "Sync completed!"
            case .failed(let error): return "Failed: \(error)"
            }
        }
    }

    // MARK: - Initialization

    init(databaseActor: DatabaseActor) {
        self.databaseActor = databaseActor
    }

    // MARK: - Public Methods

    func syncPosts(from html: String) async {
        syncState = .fetching
        progress = 0.0

        do {
            // Parse bookmarks
            syncState = .parsing
            progress = 0.2
            let parser = BookmarksParser(html: html)
            let links = parser.getPostLinks()

            // Download posts
            syncState = .downloading
            progress = 0.4
            let downloader = PostDownloader(links: links)
            let posts = downloader.getMyPosts()

            // Parse posts
            progress = 0.6
            let postParser = PostParser(posts: posts)
            postParser.parse()

            // Save to database
            syncState = .saving
            progress = 0.8
            try await databaseActor.deleteAll()
            try await databaseActor.savePosts(postParser.getPosts())

            // Download images
            syncState = .downloading
            let imageDownloader = ImageDownloader(posts: postParser.getPosts())
            await imageDownloader.downloadAllImages()

            // Complete
            progress = 1.0
            syncState = .completed

            // Notify completion
            NotificationCenter.default.post(name: .syncDidComplete, object: nil)

        } catch {
            syncState = .failed(error.localizedDescription)
            NotificationCenter.default.post(name: .syncDidFail, object: error)
        }
    }

    func reset() {
        syncState = .idle
        progress = 0.0
    }
}
