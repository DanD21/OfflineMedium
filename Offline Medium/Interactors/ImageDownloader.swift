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

    init(posts: [Post]) {
        self.myPosts = posts
    }
    
    // Modern async/await version - backwards compatible wrapper
    func startDownloadingWithComplition(complition: @escaping () -> Void) {
        Task {
            await downloadAllImages()
            complition()
        }
    }

    // Modern Swift Concurrency approach
    func downloadAllImages() async {
        await withTaskGroup(of: Void.self) { group in
            for post in myPosts {
                var postImagesArray = post.postImages
                if let mainImage = post.mainImage {
                    postImagesArray.append(mainImage)
                }

                for postImage in postImagesArray {
                    group.addTask {
                        await self.downloadAndSaveImage(postImage)
                    }
                }
            }
        }
    }

    private func downloadAndSaveImage(_ postImage: Image) async {
        guard let externalUrl = URL(string: postImage.externalPath),
              let localUrl = postImage.localUrl else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: externalUrl)
            try data.write(to: localUrl)
        } catch {
            print("Failed to download image: \(error.localizedDescription)")
        }
    }
    
    // Legacy methods kept for backwards compatibility
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }

    func downloadImageWithURL(url: URL?, complition: @escaping (_ image: NSData) -> Void) {
        guard let url = url else { return }
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            complition(data as NSData)
        }
    }
}
