//
//  Posts.swift
//  Offline Medium
//
//  Created by Dan Danilescu on 9/14/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation
import RealmSwift

class Post: Object{
    dynamic var idPost: Int = 1
    dynamic var author: String = ""
    dynamic var title: String = ""
    dynamic var mainImage: Data?
    dynamic var timestamp = 0
    dynamic var html: Data?
    
    override static func primaryKey() -> String? {
        return "idPost"
    }
}


struct PostViewModel {
    
    let creationDate:String
    init(model:Post) {
        creationDate = "\(model.timestamp)"
    }
}
class Images: Object{
    dynamic var id = 1
    dynamic var idPost = 1
    dynamic var imgUrl: String = ""
}
