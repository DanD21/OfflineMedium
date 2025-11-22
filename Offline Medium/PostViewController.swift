//
//  PostViewController.swift
//  Offline Medium
//
//  Created by Dan Danilescu on 9/13/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class PostViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // UIWebView is deprecated - removed in favor of WKWebView
    var webView: WKWebView!
    var currentPost: PostObj?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Modern WKWebView setup (JavaScript enabled by default in modern iOS)
        let conf = WKWebViewConfiguration()
        webView = WKWebView(frame: self.view.bounds, configuration: conf)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.view.addSubview(webView)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        loadPostContent()
    }

    private func loadPostContent() {
        guard let myPostString = currentPost?.html else { return }
        var replacedHTML = myPostString.replacingOccurrences(
            of: "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>",
            with: ""
        )

        // Clean up Medium's HTML structure by removing unnecessary elements
        replacedHTML = cleanHTML(replacedHTML)

        // Save and load the cleaned HTML
        guard let postTitle = currentPost?.title,
              let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        // Sanitize filename
        let sanitizedTitle = postTitle.components(separatedBy: .init(charactersIn: "/\\:*?\"<>|")).joined()
        let realPath = dir.appendingPathComponent("\(sanitizedTitle).html")

        savePageToHTMLFile(htmlString: replacedHTML, path: realPath)
        webView.loadFileURL(realPath, allowingReadAccessTo: dir)
    }

    private func cleanHTML(_ html: String) -> String {
        var cleaned = html

        // Remove menu bar
        if let startMenuBarIndex = cleaned.range(of: "<div class=\"metabar")?.lowerBound,
           let endMenuBarIndex = cleaned.range(of: "><main")?.lowerBound {
            cleaned.removeSubrange(startMenuBarIndex...endMenuBarIndex)
        }

        // Remove footer
        if let startFooterIndex = cleaned.range(of: "<footer")?.lowerBound,
           let endFooterIndex = cleaned.range(of: "</footer>")?.upperBound {
            cleaned.removeSubrange(startFooterIndex...endFooterIndex)
        }

        // Remove popup elements
        if let startPopUpIndex = cleaned.range(of: "</main>")?.upperBound,
           let endPopUpIndex = cleaned.range(of: "<style class=\"js-collectionStyle\"")?.lowerBound {
            cleaned.removeSubrange(startPopUpIndex...endPopUpIndex)
        }

        return cleaned
    }
    
    private func savePageToHTMLFile(htmlString: String, path: URL) {
        do {
            try htmlString.write(to: path, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save HTML file: \(error.localizedDescription)")
        }
    }
}

// Modern UIView extension using Codable instead of deprecated NSKeyedArchiver
extension UIView {
    func copyView() -> UIView? {
        // Note: For simple view copying, consider using snapshotView(afterScreenUpdates:) instead
        // NSKeyedArchiver.archivedData is deprecated - this is a placeholder for modern approach
        return snapshotView(afterScreenUpdates: false)
    }
}
