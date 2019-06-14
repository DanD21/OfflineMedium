//
//  ImageDownloader.swift
//  Offline Medium
//
//  Created by Cristian Cosneanu on 9/19/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader {
    
    var myPosts = [Post]()
    
    init (posts: [Post]) {
        self.myPosts = posts
    }
    
    func startDownloadingWithComplition ( complition: @escaping () -> Void ) {
        let imgGroup = DispatchGroup()
        
        for post in self.myPosts {
            var postImagesArray = post.postImages
            guard let mainImage = post.mainImage else { continue }
            postImagesArray.append(mainImage)
            
            for postImage in postImagesArray {
                imgGroup.enter()
                guard let externalUrl = URL(string: postImage.externalPath) else { continue }
                self.downloadImageWithURL(url: externalUrl, complition: { image in
                    
                    // saving the downloaded image to previously determined local path
                    
                    guard let myLocalUrl = postImage.localUrl else { return }
                    // print(myLocalUrl)
                    try? image.write(to: myLocalUrl)

                    
//                    let strBase64 = image.base64EncodedString(options: .lineLength64Characters)
//                    print("base64 img: " + strBase64)
//                    try? strBase64.write(to: myLocalUrl, atomically: true, encoding: String.Encoding.utf8)
//
//                    if let data = UIImagePNGRepresentation(image) {
//                        guard let myLocalUrl = postImage.localUrl else { return }
////                        print(myLocalUrl)
//                        try? data.write(to: myLocalUrl)
//                    }
                    
                    imgGroup.leave()
                })
            }
        }
        imgGroup.wait()
        // after all images were downloaded
        complition()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImageWithURL(url: URL?, complition: @escaping (_ image: NSData) -> Void) {
        guard let url = url else { return }
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            complition( data as NSData )
        }
    }
    
}
