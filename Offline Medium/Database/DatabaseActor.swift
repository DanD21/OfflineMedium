//
//  DatabaseActor.swift
//  Offline Medium
//
//  Swift 6 Actor-based database manager
//  Replaces the old singleton pattern with modern concurrency
//

import Foundation
import RealmSwift

/// Modern Actor-based database manager for thread-safe Realm operations
/// Replaces the old DBManager singleton with Swift 6 structured concurrency
actor DatabaseActor {

    private let realm: Realm

    init() throws {
        self.realm = try Realm()
    }

    // MARK: - Query Operations

    func getPosts(query: String? = nil) -> [PostObj] {
        var results: Results<PostObj>

        if let query = query {
            let predicate = NSPredicate(format: "title CONTAINS[c] %@", query)
            results = realm.objects(PostObj.self).filter(predicate)
        } else {
            results = realm.objects(PostObj.self)
        }

        return Array(results)
    }

    func getPost(at index: Int) -> PostObj? {
        let results = realm.objects(PostObj.self)
        guard index >= 0 && index < results.count else { return nil }
        return results[index]
    }

    // MARK: - Write Operations

    func addPost(_ object: PostObj) throws {
        try realm.write {
            realm.add(object, update: .modified)
        }
    }

    func addItem(_ object: Item) throws {
        try realm.write {
            realm.add(object, update: .modified)
        }
    }

    func deleteAll() throws {
        try realm.write {
            realm.deleteAll()
        }
    }

    func delete(_ object: Item) throws {
        try realm.write {
            realm.delete(object)
        }
    }

    // MARK: - Batch Operations

    func savePosts(_ posts: [Post]) throws {
        try realm.write {
            for post in posts {
                let realmPost = PostObj()

                realmPost.title = post.title

                if let mainImage = post.mainImage?.localUrl {
                    realmPost.mainImage = mainImage.absoluteString
                }

                realmPost.html = post.postHTML
                realmPost.author = post.postAuthor

                for image in post.postImages {
                    guard let imgurl = image.localUrl?.absoluteString else { continue }
                    let imageObj = ImagesObj()
                    imageObj.imgUrl = imgurl
                    realmPost.postImages.append(imageObj)
                }

                realm.add(realmPost, update: .modified)
            }
        }
    }
}

// MARK: - Sendable Conformance

// Note: Realm objects are NOT Sendable, so we need to extract data before crossing actor boundaries
extension DatabaseActor {

    /// Returns thread-safe post data that can be used across actor boundaries
    func getPostData(query: String? = nil) async -> [PostData] {
        let posts = getPosts(query: query)
        return posts.map { PostData(from: $0) }
    }
}

/// Thread-safe representation of a post
struct PostData: Sendable, Identifiable {
    let id: String
    let title: String
    let author: String
    let mainImage: String
    let html: String

    init(from post: PostObj) {
        self.id = post.idPost
        self.title = post.title
        self.author = post.author
        self.mainImage = post.mainImage
        self.html = post.html
    }
}
