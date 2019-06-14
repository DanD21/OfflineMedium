//
//  PostDownloader.swift
//  Offline Medium
//
//  Created by Cristian Cosneanu on 9/19/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation

class PostDownloader {
    var postLinks = [String]()
    var posts = [Post]()
    
    init (links: [String]) {
        self.postLinks = links
    }
    
    func getMyPosts () -> [Post] {
        for link in self.postLinks {
            if let postUrl = URL(string: link) {
                guard let myHTMLString = try? String(contentsOf: postUrl) else { continue }
                self.posts.append(Post(postHtml: myHTMLString))
            }
        }
        return self.posts
    }
}
