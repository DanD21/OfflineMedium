//
//  FirstViewController.swift
//  Offline Medium
//
//  Created by Dan Danilescu on 9/13/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import UIKit
import Kanna
import WebKit
import RealmSwift

class LoginViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    static var loadingProgressLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var theWebView: UIView!
    var webView: WKWebView!
    let postItem = PostObj()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        LoginViewController.loadingProgressLabel = self.progressLabel
        // Setting the WKWebView:
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let conf = WKWebViewConfiguration()
        conf.preferences = preferences
        webView = WKWebView(frame: self.view.bounds, configuration: conf)
        self.theWebView.addSubview(webView)
        
        // Do any additional setup after loading the view, typically from a nib.
        webView.load(URLRequest(url: PublicLinks.getLoginUrl()))
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let webViewLoadedURL = webView.url else { return }
        self.loadingView.isHidden = true
//        print(webViewLoadedURL.absoluteString)
        if (webViewLoadedURL.absoluteString.contains("\(PublicLinks.state)"))
        {
            self.loadingView.isHidden = false
//            print("\n\n \(String(describing: webViewLoadedURL.valueOf(queryParamaterName: "code")))")
            webView.load(URLRequest(url: URL(string: PublicLinks.mediumBookmarks)!))
        }

        if (webViewLoadedURL.absoluteString == PublicLinks.mediumBookmarks)
        {
            self.loadingView.isHidden = false
            self.setProgressLabel(string: "Getting bookmarks...")
            var i = 10000
            while  i >= 0 {
                let scrollPoint = CGPoint(x: 0, y: webView.scrollView.contentSize.height)
                webView.scrollView.setContentOffset(scrollPoint, animated: false)
                i -= 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                           completionHandler: ({ (html: Any?, error: Error?) in
                                            guard let extractedHTML = html as? String else { return }
                                            DispatchQueue.global(qos: .userInitiated).async {
                                                self.setProgressLabel(string: "Parsing bookmarks...")
                                                let bookmarkparser = BookmarksParser(html: extractedHTML)
                                                let postLinks = bookmarkparser.getPostLinks()
                                                self.setProgressLabel(string: "Getting posts...")
                                                let postDownloader = PostDownloader(links: postLinks)
                                                self.setProgressLabel(string: "Getting posts data...")
                                                let myPostParser = PostParser(posts: postDownloader.getMyPosts())
                                                myPostParser.parse()
                                                
                                                // here is the part were REALM should be integrated
                                                DispatchQueue.main.async {
                                                    DBManager.sharedInstance.deleteAllFromDatabase()
                                                    DBManager.sharedInstance.saveRealmObj(posts: myPostParser.getPosts())
                                                    self.setProgressLabel(string: "Saving...")
                                                }
                                                
                                                self.setProgressLabel(string: "Downloading images...")
                                                let myImageDownloader = ImageDownloader(posts: myPostParser.getPosts())
                                                myImageDownloader.startDownloadingWithComplition {
                                                    self.setProgressLabel(string: "All images were downloaded!")
                                                    DispatchQueue.main.async {
                                                        self.dismiss(animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                           }))
                
            })
        }
    }
    
    func setProgressLabel(string: String) {
        DispatchQueue.main.async {
            self.progressLabel.text = string
        }
    }
    
    func getTokenWithCode(code: String){
        var request = URLRequest.init(url: PublicLinks.getResponseURI(code: code))
        request.httpMethod = "POST"
    }
}

extension URL {
    func valueOf(queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

extension SearchableNode {
    var string:String{
        return self.text ?? ""
    }
}

