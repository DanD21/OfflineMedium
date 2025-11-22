//
//  BookmarksParser.swift
//  Offline Medium
//
//  Created by Cristian Cosneanu on 9/19/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation
import Kanna

protocol Parser {
    var HTMLString: String { get set }
}

class BookmarksParser : Parser {

    var HTMLString = ""
    var links = [String]()

    init (html: String){
        self.HTMLString = html
        guard let parsedDoc = HTML(html: self.HTMLString, encoding: .utf8) else { return }

        // Modern Medium uses different link structures
        // Try multiple selectors to find article links
        var articleLinks = [String]()

        // Look for article links in various Medium structures
        // 1. Direct article links (h2/h3 inside article tags)
        let articleTitles = parsedDoc.css("article h2 a, article h3 a")
        articleLinks.append(contentsOf: articleTitles.compactMap { $0["href"] })

        // 2. Links with data-post-id attribute (older structure)
        let dataPostLinks = parsedDoc.css("a[data-post-id]")
        articleLinks.append(contentsOf: dataPostLinks.compactMap { $0["href"] })

        // 3. Fallback: Look for Medium article URL pattern
        let allLinks = parsedDoc.css("a")
        let mediumArticleLinks = allLinks.compactMap { $0["href"] }.filter { link in
            link.contains("medium.com") && !link.contains("/tag/") && !link.contains("/search") && !link.contains("/@")
        }
        articleLinks.append(contentsOf: mediumArticleLinks)

        // Remove duplicates and filter valid URLs
        self.links = Array(Set(articleLinks)).filter { $0.hasPrefix("http") }
    }

    func getPostLinks() -> [String] {
        return self.links
    }

}
