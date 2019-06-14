//
//  DBManager.swift
//  Offline Medium
//
//  Created by Dan Danilescu on 9/19/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import UIKit
import RealmSwift

class DBManager {
    
    private var database:Realm
    
    static let sharedInstance = DBManager()
    
    private init() {
        database = try! Realm()
    }
    
    func getDataFromDB(query: String? = nil) ->   Results<PostObj> {
        var results: Results<PostObj>
        if query == nil {
            results = database.objects(PostObj.self)
        } else {
            let predicate = NSPredicate(format: "title CONTAINS [c] %@", query!)
            results = database.objects(PostObj.self).filter(predicate)
        }
        return results
    }
    
    func addData(object: Item)   {
        try! database.write {
            database.add(object, update: true)
        }
    }
    
    func deleteAllFromDatabase()  {
        try! database.write {
            database.deleteAll()
        }
    }
    
    func deleteFromDb(object: Item)   {
        try! database.write {
            database.delete(object)
        }
    }
    
    func saveRealmObj (posts : [Post]) {
        try! database.write {
            

            for post in posts {
                let realmPost = PostObj()

                realmPost.title = post.title
                guard let mainImage = post.mainImage?.localUrl else { continue }
                realmPost.mainImage = mainImage.absoluteString
                realmPost.html = post.postHTML
                realmPost.author = post.postAuthor
                
                for image in post.postImages {
                    guard let imgurl = image.localUrl?.absoluteString else { continue }
                    let imageObj = ImagesObj()
                    imageObj.imgUrl = imgurl
                    
                    realmPost.postImages.append(imageObj)
                }
                database.add(realmPost, update: true)
            }
        }
    }
}
