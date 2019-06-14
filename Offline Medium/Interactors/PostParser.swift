//
//  PostParser.swift
//  Offline Medium
//
//  Created by Cristian Cosneanu on 9/19/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation
import Kanna

class PostParser {

    private var myPosts = [Post]()
    
    init (posts: [Post]) {
        self.myPosts = posts
    }
    
    func parse () {
        var mutatedPosts = [Post]()
        for var post in self.myPosts {
            guard let myKannaPost = HTML(html: post.postHTML, encoding: .utf8) else { continue }
            guard let json = myKannaPost.at_xpath("//script[@type='application/ld+json']")?.text else { continue }
            guard let title = myKannaPost.title else { continue }
            post.title = title
            guard let additional = self.getPostDataFromJSON(json: json) else { continue }
            let lastpath = NSString(string: additional.mainImage)
            var mainImageFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            mainImageFilePath.appendPathComponent(lastpath.lastPathComponent)
            post.mainImage = Image(external: additional.mainImage, localUrl: mainImageFilePath)
            post.postAuthor = additional.authorName
            let iFrames = myKannaPost.css("iframe")
            for iFrame in iFrames {
                guard let iFrameSrc = iFrame["src"] else { continue }
                post.postHTML = post.postHTML.replacingOccurrences(of: iFrameSrc, with: "")
            }
            // getting images from html DOM (Kanna generated)
            let images = myKannaPost.css("img")
            for var img in images
            {
                guard let imgsrc = img["src"] else { continue }
                // determine the local path for image
                let lastpath = NSString(string: imgsrc)
                var filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                filePath.appendPathComponent(lastpath.lastPathComponent)
                let newImage = Image(external: imgsrc, localUrl: filePath)
                post.postImages.append(newImage)
                post.postHTML = post.postHTML.replacingOccurrences(of: img["src"]!, with: lastpath.lastPathComponent)
            }
            mutatedPosts.append(post)
        }
        self.myPosts = mutatedPosts
    }
       
    func getPostDataFromJSON( json: String ) -> PostAdditionalData? {
        do {
            guard let jsonDataObj = json.data(using: .utf8) else { return nil }
            guard let jsonData = try JSONSerialization.jsonObject(with: jsonDataObj, options: []) as? Dictionary<String, Any> else { return nil }
            guard let image = jsonData["image"] as? Dictionary<String, Any>, let imageUrl = image["url"] as? String else { return nil }
            guard let author = jsonData["author"] as? Dictionary<String, Any>, let authorName = author["name"] as? String else { return nil }
            return PostAdditionalData(authorName: authorName, mainImage: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getPosts() -> [Post] {
        return self.myPosts
    }

}
