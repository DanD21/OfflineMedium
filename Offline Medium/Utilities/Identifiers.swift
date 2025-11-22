//
//  Identifiers.swift
//  Offline Medium
//
//  Type-safe identifiers for cells, segues, and other string-based references
//

import Foundation

// MARK: - Cell Identifiers

enum CellIdentifier: String {
    case postCell = "Cell"
    case homeTableViewCell = "HomeTableViewCell"

    var identifier: String {
        return rawValue
    }
}

// MARK: - Segue Identifiers

enum SegueIdentifier: String {
    case showPost = "showPostSegue"
    case showPostViewController = "showPostViewController"

    var identifier: String {
        return rawValue
    }
}

// MARK: - Storyboard Identifiers

enum StoryboardIdentifier: String {
    case main = "Main"
    case login = "Login"

    var identifier: String {
        return rawValue
    }
}

// MARK: - View Controller Identifiers

enum ViewControllerIdentifier: String {
    case home = "HomeTableViewController"
    case post = "PostViewController"
    case login = "LoginViewController"

    var identifier: String {
        return rawValue
    }
}

// MARK: - Asset Identifiers

enum AssetIdentifier: String {
    case appIcon = "AppIcon"
    case launchImage = "LaunchImage"

    var identifier: String {
        return rawValue
    }
}

// MARK: - User Defaults Keys

enum UserDefaultsKey: String {
    case hasCompletedLogin = "hasCompletedLogin"
    case lastSyncDate = "lastSyncDate"
    case userName = "userName"

    var key: String {
        return rawValue
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let postsDidUpdate = Notification.Name("postsDidUpdate")
    static let syncDidComplete = Notification.Name("syncDidComplete")
    static let syncDidFail = Notification.Name("syncDidFail")
}
