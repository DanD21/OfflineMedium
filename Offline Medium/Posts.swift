//
//  Posts.swift
//  Offline Medium
//
//  Created by Dan Danilescu on 9/14/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation
import RealmSwift

class Post: Object {
    @Persisted(primaryKey: true) var idPost: Int = 1
    @Persisted var author: String = ""
    @Persisted var title: String = ""
    @Persisted var mainImage: Data?
    @Persisted var timestamp: Int = 0
    @Persisted var html: Data?
}


struct PostViewModel {
    
    let creationDate:String
    init(model:Post) {
        creationDate = "\(model.timestamp)"
    }
}
class Images: Object {
    @Persisted(primaryKey: true) var id: Int = 1
    @Persisted var idPost: Int = 1
    @Persisted var imgUrl: String = ""
}
