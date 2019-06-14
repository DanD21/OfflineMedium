//
//  Structs.swift
//  Offline Medium
//
//  Created by Cristian Cosneanu on 9/19/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation

struct PostAdditionalData {
    var authorName = ""
    var mainImage = ""
}

struct Image {
    var externalPath = ""
    var localUrl: URL?
    
    init(external: String, localUrl: URL?) {
        self.externalPath = external
        self.localUrl = localUrl
    }
}

struct Post {
    var title = ""
    var mainImage: Image?
    var postHTML = ""
    var postAuthor = ""
    var postImages = [Image]()
    
    init (postHtml: String) {
        self.postHTML = postHtml
    }
}
