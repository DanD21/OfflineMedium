//
//  Structs.swift
//  Offline Medium
//
//  Created by Cristian Cosneanu on 9/19/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation

// Swift 6: Sendable conformance for thread-safe data sharing
struct PostAdditionalData: Sendable {
    var authorName = ""
    var mainImage = ""
}

struct Image: Sendable {
    var externalPath = ""
    var localUrl: URL?

    init(external: String, localUrl: URL?) {
        self.externalPath = external
        self.localUrl = localUrl
    }
}

struct Post: Sendable {
    var title = ""
    var mainImage: Image?
    var postHTML = ""
    var postAuthor = ""
    var postImages = [Image]()

    init(postHtml: String) {
        self.postHTML = postHtml
    }
}
