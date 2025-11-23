//
//  MediumAppIntents.swift
//  Offline Medium
//
//  App Intents for Siri and Shortcuts integration
//  Showcases: App Intents framework, Siri integration, Shortcuts
//

import AppIntents
import Foundation

// MARK: - Get Recent Posts Intent

struct GetRecentPostsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Recent Posts"
    static var description = IntentDescription("Retrieve your recently saved Medium posts")

    @Parameter(title: "Number of Posts", default: 5)
    var count: Int

    func perform() async throws -> some IntentResult & ReturnsValue<[PostEntity]> {
        let actor = try DatabaseActor()
        let posts = await actor.getPostData()
        let limited = Array(posts.prefix(count))

        let entities = limited.map { post in
            PostEntity(
                id: post.id,
                title: post.title,
                author: post.author
            )
        }

        return .result(value: entities)
    }
}

// MARK: - Search Posts Intent

struct SearchPostsIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Posts"
    static var description = IntentDescription("Search your saved posts")

    @Parameter(title: "Search Query")
    var query: String

    func perform() async throws -> some IntentResult & ReturnsValue<[PostEntity]> {
        let actor = try DatabaseActor()
        let posts = actor.getPosts(query: query)

        let entities = posts.map { post in
            PostEntity(
                id: post.idPost,
                title: post.title,
                author: post.author
            )
        }

        return .result(value: entities)
    }
}

// MARK: - Get Post Count Intent

struct GetPostCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Post Count"
    static var description = IntentDescription("Get the total number of saved posts")

    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        let actor = try DatabaseActor()
        let posts = await actor.getPostData()

        return .result(value: posts.count)
    }
}

// MARK: - Post Entity

struct PostEntity: AppEntity {
    var id: String
    var title: String
    var author: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Post"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "by \(author)"
        )
    }

    static var defaultQuery = PostEntityQuery()
}

// MARK: - Post Entity Query

struct PostEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [PostEntity] {
        let actor = try DatabaseActor()
        let posts = await actor.getPostData()

        return posts
            .filter { identifiers.contains($0.id) }
            .map { PostEntity(id: $0.id, title: $0.title, author: $0.author) }
    }

    func suggestedEntities() async throws -> [PostEntity] {
        let actor = try DatabaseActor()
        let posts = await actor.getPostData()

        return Array(posts.prefix(10))
            .map { PostEntity(id: $0.id, title: $0.title, author: $0.author) }
    }
}

// MARK: - App Shortcuts Provider

struct MediumAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetRecentPostsIntent(),
            phrases: [
                "Show my recent \(.applicationName) posts",
                "What are my latest \(.applicationName) articles",
                "Get my saved \(.applicationName) posts"
            ],
            shortTitle: "Recent Posts",
            systemImageName: "newspaper"
        )

        AppShortcut(
            intent: SearchPostsIntent(),
            phrases: [
                "Search \(.applicationName) for \(\.$query)",
                "Find \(\.$query) in \(.applicationName)"
            ],
            shortTitle: "Search Posts",
            systemImageName: "magnifyingglass"
        )

        AppShortcut(
            intent: GetPostCountIntent(),
            phrases: [
                "How many posts do I have in \(.applicationName)",
                "Count my \(.applicationName) posts"
            ],
            shortTitle: "Post Count",
            systemImageName: "number"
        )
    }
}

// MARK: - Focus Filter

@available(iOS 16.0, *)
struct ReadingFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Reading Focus"
    static var description = IntentDescription("Filter to show only reading-related content")

    func perform() async throws -> some IntentResult {
        // Configure focus filter for reading mode
        return .result()
    }
}
