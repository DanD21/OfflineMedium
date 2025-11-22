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
class PostObj: Item {
    @Persisted(primaryKey: true) var idPost: String = UUID().uuidString
    @Persisted var author: String = ""
    @Persisted var title: String = ""
    @Persisted var mainImage: String = ""
    @Persisted var html: String = ""
    @Persisted var postImages = List<ImagesObj>()
}

class ImagesObj: Item {
    @Persisted var imgUrl: String = ""
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
