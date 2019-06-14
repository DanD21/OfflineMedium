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
        let filteredLiks = parsedDoc.css("a").filter({ $0.text != nil && $0.text!.contains("Read more") }).map({ $0["href"] }).flatMap({ $0 })
        self.links = filteredLiks
    }
    
    func getPostLinks() -> [String] {
        return self.links
    }
    
}
