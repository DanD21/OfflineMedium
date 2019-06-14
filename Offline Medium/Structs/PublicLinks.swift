//
//  PublicLinks.swift
//  Offline Medium
//
//  Created by Cristian Cosneanu on 9/14/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation

public struct PublicLinks {
    static let state = "myRandomState"
    static let redirect_uri = "https://medium.com"
    static let client_id = "63181925182e"
    static let client_secret = "24b876f35ff369a1f550b219669661b3f3073828"
    static let mediumBookmarks = "https://medium.com/browse/bookmarks"
    
    public static func getLoginUrl() -> URL {
        return URL(string: "https://medium.com/m/oauth/authorize?client_id=\(self.client_id)&scope=basicProfile,publishPost&state=\(PublicLinks.state)&response_type=code&redirect_uri=\(PublicLinks.redirect_uri)")!
    }
    
    public static func getResponseURI(code: String) -> URL {
        return URL(string: "api.medium.com?code=\(code)&client_id=\(self.client_id)&client_secret=\(self.client_secret)&grant_type=authorization_code&redirect_uri=\(self.redirect_uri)")!
    }
    
    
}
