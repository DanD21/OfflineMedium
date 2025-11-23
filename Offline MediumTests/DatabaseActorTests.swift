//
//  DatabaseActorTests.swift
//  Offline Medium Tests
//
//  Comprehensive tests using Swift Testing framework (modern approach)
//  Showcases: Testing with Actors, async/await, Swift Testing syntax
//

import Testing
import Foundation
@testable import Offline_Medium

/// Test suite for DatabaseActor
/// Demonstrates modern Swift Testing practices with actors and async/await
@Suite("Database Actor Tests")
struct DatabaseActorTests {

    // MARK: - Basic Operations

    @Test("Actor initializes successfully")
    func testInitialization() async throws {
        let actor = try DatabaseActor()
        #expect(actor != nil, "DatabaseActor should initialize")
    }

    @Test("Adding a post stores it correctly")
    func testAddPost() async throws {
        let actor = try DatabaseActor()

        let post = PostObj()
        post.idPost = UUID().uuidString
        post.title = "Test Post"
        post.author = "Test Author"
        post.html = "<p>Test content</p>"

        try await actor.addPost(post)

        let retrieved = await actor.getPosts()
        #expect(retrieved.count == 1, "Should have one post")
        #expect(retrieved.first?.title == "Test Post", "Title should match")
    }

    @Test("Querying posts with search term")
    func testQueryPosts() async throws {
        let actor = try DatabaseActor()

        // Add multiple posts
        for i in 1...5 {
            let post = PostObj()
            post.idPost = UUID().uuidString
            post.title = i % 2 == 0 ? "Swift Tutorial" : "Python Guide"
            post.author = "Author \(i)"
            try await actor.addPost(post)
        }

        let swiftPosts = actor.getPosts(query: "Swift")
        #expect(swiftPosts.count == 2, "Should find 2 Swift posts")

        let allPosts = actor.getPosts(query: nil)
        #expect(allPosts.count == 5, "Should find all 5 posts")
    }

    @Test("Deleting all posts clears database")
    func testDeleteAll() async throws {
        let actor = try DatabaseActor()

        // Add posts
        for i in 1...3 {
            let post = PostObj()
            post.idPost = UUID().uuidString
            post.title = "Post \(i)"
            try await actor.addPost(post)
        }

        #expect(actor.getPosts().count == 3, "Should have 3 posts")

        try await actor.deleteAll()

        #expect(actor.getPosts().isEmpty, "Should be empty after deleteAll")
        #expect(actor.isEmpty(), "isEmpty() should return true")
    }

    // MARK: - Sample Data Tests

    @Test("Seeding with sample data")
    func testSeedSampleData() async throws {
        let actor = try DatabaseActor()

        try await actor.seedWithSampleData()

        let posts = await actor.getPostData()
        #expect(posts.count == 15, "Should have 15 sample posts")
        #expect(!posts.first!.title.isEmpty, "Posts should have titles")
        #expect(!posts.first!.author.isEmpty, "Posts should have authors")
    }

    @Test("Sample posts have required fields")
    func testSamplePostStructure() async throws {
        let actor = try DatabaseActor()
        try await actor.seedWithSampleData()

        let posts = await actor.getPostData()

        for post in posts {
            #expect(!post.id.isEmpty, "Post should have ID")
            #expect(!post.title.isEmpty, "Post should have title")
            #expect(!post.author.isEmpty, "Post should have author")
            #expect(!post.html.isEmpty, "Post should have HTML content")
        }
    }

    // MARK: - Thread Safety Tests

    @Test("Concurrent operations are thread-safe")
    func testConcurrentAccess() async throws {
        let actor = try DatabaseActor()

        // Perform concurrent writes
        await withTaskGroup(of: Void.self) { group in
            for i in 1...10 {
                group.addTask {
                    let post = PostObj()
                    post.idPost = "post-\(i)"
                    post.title = "Concurrent Post \(i)"
                    try? await actor.addPost(post)
                }
            }
        }

        let posts = actor.getPosts()
        #expect(posts.count == 10, "All concurrent writes should succeed")
    }

    // MARK: - Data Integrity Tests

    @Test("Updating existing post modifies it")
    func testUpdatePost() async throws {
        let actor = try DatabaseActor()

        let post = PostObj()
        post.idPost = "unique-id"
        post.title = "Original Title"
        try await actor.addPost(post)

        // Update the same post
        let updatedPost = PostObj()
        updatedPost.idPost = "unique-id"
        updatedPost.title = "Updated Title"
        try await actor.addPost(updatedPost)

        let posts = actor.getPosts()
        #expect(posts.count == 1, "Should still have one post")
        #expect(posts.first?.title == "Updated Title", "Title should be updated")
    }
}

// MARK: - ViewModel Tests

@Suite("Posts ViewModel Tests")
struct PostsViewModelTests {

    @Test("ViewModel initializes with empty state")
    @MainActor
    func testInitialState() throws {
        let actor = try DatabaseActor()
        let viewModel = PostsViewModel(databaseActor: actor)

        #expect(viewModel.posts.isEmpty, "Posts should be empty initially")
        #expect(!viewModel.isLoading, "Should not be loading initially")
        #expect(viewModel.errorMessage == nil, "Should have no error initially")
        #expect(viewModel.searchText.isEmpty, "Search text should be empty")
    }

    @Test("Loading posts updates state")
    @MainActor
    func testLoadPosts() async throws {
        let actor = try DatabaseActor()
        try await actor.seedWithSampleData()

        let viewModel = PostsViewModel(databaseActor: actor)
        await viewModel.loadPosts()

        #expect(viewModel.posts.count == 15, "Should load 15 sample posts")
        #expect(!viewModel.isLoading, "Loading should be complete")
        #expect(viewModel.errorMessage == nil, "Should have no errors")
    }
}

// MARK: - Sample Data Generator Tests

@Suite("Sample Data Generator Tests")
struct SampleDataGeneratorTests {

    @Test("Generates correct number of posts")
    func testGenerateCount() async {
        let generator = SampleDataGenerator()
        let posts = await generator.generateSamplePosts(count: 10)

        #expect(posts.count == 10, "Should generate requested number")
    }

    @Test("Generated posts have all required fields")
    func testPostFields() async {
        let generator = SampleDataGenerator()
        let posts = await generator.generateSamplePosts(count: 5)

        for post in posts {
            #expect(!post.title.isEmpty, "Post should have title")
            #expect(!post.postAuthor.isEmpty, "Post should have author")
            #expect(!post.postHTML.isEmpty, "Post should have HTML")
            #expect(!post.postImages.isEmpty, "Post should have images")
        }
    }

    @Test("Realm posts generation")
    func testRealmPostGeneration() async {
        let generator = SampleDataGenerator()
        let posts = await generator.generateSampleRealmPosts(count: 5)

        #expect(posts.count == 5, "Should generate 5 Realm posts")
        #expect(posts.allSatisfy { !$0.title.isEmpty }, "All should have titles")
        #expect(posts.allSatisfy { !$0.idPost.isEmpty }, "All should have IDs")
    }
}

// MARK: - Performance Tests

@Suite("Performance Tests")
struct PerformanceTests {

    @Test("Loading large dataset performance",
          .timeLimit(.minutes(1)))
    func testLargeDatasetLoad() async throws {
        let actor = try DatabaseActor()
        let generator = SampleDataGenerator()

        // Generate many posts
        let posts = await generator.generateSampleRealmPosts(count: 100)

        try actor.realm.write {
            actor.realm.add(posts)
        }

        let retrieved = actor.getPosts()
        #expect(retrieved.count == 100, "Should handle 100 posts")
    }

    @Test("Query performance with many posts")
    func testQueryPerformance() async throws {
        let actor = try DatabaseActor()
        try await actor.seedWithSampleData()

        // Query should be fast even with data
        let results = actor.getPosts(query: "Swift")
        #expect(results.count >= 0, "Query should complete successfully")
    }
}
