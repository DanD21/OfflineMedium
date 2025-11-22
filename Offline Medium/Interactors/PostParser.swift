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

            // Try to get title from multiple sources (modern Medium structure)
            var title: String? = myKannaPost.title

            // Fallback: try og:title meta tag
            if title == nil || title!.isEmpty {
                title = myKannaPost.at_xpath("//meta[@property='og:title']")?["content"]
            }

            // Fallback: try h1 tag
            if title == nil || title!.isEmpty {
                title = myKannaPost.at_css("h1")?.text
            }

            guard let finalTitle = title, !finalTitle.isEmpty else { continue }
            post.title = finalTitle

            // Try modern meta tag approach first
            var authorName: String?
            var mainImageUrl: String?

            // Get author from meta tags
            authorName = myKannaPost.at_xpath("//meta[@name='author']")?["content"]
            if authorName == nil {
                authorName = myKannaPost.at_xpath("//meta[@property='article:author']")?["content"]
            }

            // Get main image from og:image meta tag
            mainImageUrl = myKannaPost.at_xpath("//meta[@property='og:image']")?["content"]

            // Fallback: try JSON-LD if meta tags don't work
            if authorName == nil || mainImageUrl == nil {
                if let json = myKannaPost.at_xpath("//script[@type='application/ld+json']")?.text,
                   let additional = self.getPostDataFromJSON(json: json) {
                    if authorName == nil {
                        authorName = additional.authorName
                    }
                    if mainImageUrl == nil {
                        mainImageUrl = additional.mainImage
                    }
                }
            }

            // Set author
            post.postAuthor = authorName ?? "Unknown Author"

            // Set main image if found
            if let imageUrl = mainImageUrl, !imageUrl.isEmpty {
                let lastpath = NSString(string: imageUrl)
                var mainImageFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                mainImageFilePath.appendPathComponent(lastpath.lastPathComponent)
                post.mainImage = Image(external: imageUrl, localUrl: mainImageFilePath)
            }

            // Remove iframes
            let iFrames = myKannaPost.css("iframe")
            for iFrame in iFrames {
                guard let iFrameSrc = iFrame["src"] else { continue }
                post.postHTML = post.postHTML.replacingOccurrences(of: iFrameSrc, with: "")
            }

            // Process images in the article
            let images = myKannaPost.css("img")
            for img in images {
                // Try different image URL attributes (Medium uses various ones)
                var imgsrc = img["src"]
                if imgsrc == nil || imgsrc!.isEmpty {
                    imgsrc = img["data-src"]
                }
                if imgsrc == nil || imgsrc!.isEmpty {
                    imgsrc = img["srcset"]?.components(separatedBy: " ").first
                }

                guard let imageSource = imgsrc, !imageSource.isEmpty else { continue }

                // Determine the local path for image
                let lastpath = NSString(string: imageSource)
                var filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                filePath.appendPathComponent(lastpath.lastPathComponent)
                let newImage = Image(external: imageSource, localUrl: filePath)
                post.postImages.append(newImage)

                // Replace image URL with local filename
                if let originalSrc = img["src"] {
                    post.postHTML = post.postHTML.replacingOccurrences(of: originalSrc, with: lastpath.lastPathComponent)
                }
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
