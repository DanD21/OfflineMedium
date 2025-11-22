//
//  PostsViewModel.swift
//  Offline Medium
//
//  Modern ViewModel using Combine for reactive UI updates
//

import Foundation
import Combine
import SwiftUI

/// Main ViewModel for the posts list
/// Uses Combine for reactive data flow and dependency injection for database access
@MainActor
class PostsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var posts: [PostData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    // MARK: - Dependencies

    private let databaseActor: DatabaseActor

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(databaseActor: DatabaseActor) {
        self.databaseActor = databaseActor
        setupSearchObserver()
    }

    // MARK: - Public Methods

    func loadPosts() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedPosts = await databaseActor.getPostData()
            self.posts = loadedPosts
        } catch {
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func refreshPosts() async {
        await loadPosts()
    }

    func deleteAllPosts() async {
        do {
            try await databaseActor.deleteAll()
            await loadPosts()
        } catch {
            errorMessage = "Failed to delete posts: \(error.localizedDescription)"
        }
    }

    // MARK: - Private Methods

    private func setupSearchObserver() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchQuery in
                Task {
                    await self?.performSearch(query: searchQuery)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) async {
        let searchQuery = query.isEmpty ? nil : query
        let results = await databaseActor.getPostData(query: searchQuery)
        self.posts = results
    }
}

// MARK: - Post Detail ViewModel

@MainActor
class PostDetailViewModel: ObservableObject {

    @Published var post: PostData
    @Published var cleanedHTML: String = ""

    init(post: PostData) {
        self.post = post
        self.cleanedHTML = cleanHTML(post.html)
    }

    private func cleanHTML(_ html: String) -> String {
        var cleaned = html.replacingOccurrences(
            of: "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>",
            with: ""
        )

        // Remove menu bar
        if let startMenuBarIndex = cleaned.range(of: "<div class=\"metabar")?.lowerBound,
           let endMenuBarIndex = cleaned.range(of: "><main")?.lowerBound {
            cleaned.removeSubrange(startMenuBarIndex...endMenuBarIndex)
        }

        // Remove footer
        if let startFooterIndex = cleaned.range(of: "<footer")?.lowerBound,
           let endFooterIndex = cleaned.range(of: "</footer>")?.upperBound {
            cleaned.removeSubrange(startFooterIndex...endFooterIndex)
        }

        // Remove popup elements
        if let startPopUpIndex = cleaned.range(of: "</main>")?.upperBound,
           let endPopUpIndex = cleaned.range(of: "<style class=\"js-collectionStyle\"")?.lowerBound {
            cleaned.removeSubrange(startPopUpIndex...endPopUpIndex)
        }

        return cleaned
    }

    func saveHTMLToFile() -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        // Sanitize filename
        let sanitizedTitle = post.title.components(separatedBy: .init(charactersIn: "/\\:*?\"<>|")).joined()
        let filePath = dir.appendingPathComponent("\(sanitizedTitle).html")

        do {
            try cleanedHTML.write(to: filePath, atomically: true, encoding: .utf8)
            return filePath
        } catch {
            print("Failed to save HTML: \(error.localizedDescription)")
            return nil
        }
    }
}
