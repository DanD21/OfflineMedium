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
    
    @IBOutlet weak var webView2: UIWebView!
    var webView: WKWebView!
    var currentPost: PostObj?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let conf = WKWebViewConfiguration()
        conf.preferences = preferences
        webView = WKWebView(frame: self.view.bounds, configuration: conf)
        // Do any additional setup after loading the view, typically from a nib.
        guard let myPostString = self.currentPost?.html else { return }
        var replacedHTML = myPostString.replacingOccurrences(of: "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>", with: "")

        // delete menu bar and footer
        guard let startMenuBarIndex = replacedHTML.range(of: "<div class=\"metabar")?.lowerBound  else { print("startMenuBarIndex"); return }
        guard let endMenuBarIndex = replacedHTML.range(of: "><main")?.lowerBound else { print("endMenuBarIndex"); return }
        guard let startFooterIndex = replacedHTML.range(of: "<footer")?.lowerBound  else { print("startFooterIndex"); return }
        guard let endFooterIndex = replacedHTML.range(of: "</footer>")?.upperBound else { print("endFooterIndex"); return }
        
        if let startPopUpIndex = replacedHTML.range(of: "</main>")?.upperBound {
            if let endPopUpIndex = replacedHTML.range(of: "<style class=\"js-collectionStyle\"")?.lowerBound {
                replacedHTML.removeSubrange(startPopUpIndex...endPopUpIndex)
            }
        }
        
        replacedHTML.removeSubrange(startMenuBarIndex...endMenuBarIndex)
        replacedHTML.removeSubrange(startFooterIndex...endFooterIndex)
        
        // save html to file
        guard let postTitle = self.currentPost?.title else { return }
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let realPath = dir.appendingPathComponent("\(postTitle).html")
        self.savePageToHTMLFile(htmlString: replacedHTML, path: realPath)

        webView.loadFileURL(realPath, allowingReadAccessTo: dir)
        self.view.addSubview(webView)
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    func savePageToHTMLFile(htmlString: String, path: URL) {
        //writing
        do {
            try htmlString.write(to: path, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            print("failed to save html file")
        }
    }
}

extension UIView
{
    func copyView() -> UIView?
    {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? UIView
    }
}
