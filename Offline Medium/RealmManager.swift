//
//  RealmManager.swift
//  Offline Medium
//
//  Created by Dan Danilescu on 9/14/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
}

// Definition of model objects:
class PostObj: Item{
    dynamic var idPost = UUID().uuidString
    dynamic var author: String = ""
    dynamic var title: String = ""
    dynamic var mainImage: String = ""
    dynamic var html: String = ""
    let postImages = List<ImagesObj>()
    
    override static func primaryKey() -> String? {
        return "idPost"
    }
}

class ImagesObj: Item{
    dynamic var imgUrl: String = ""
}

/*
struct finalPost {
    let postID: String
    let author: String
    let title: String
    let mainImage: String
    let html: Data?
    let postLink: String?
}

struct Images {
    let id: Int
    let idPost: String
    let imgUrl: String?
}
 */



//try! realm.write {
//    for item in results {
//        item.value = newValue
//    }
//}
