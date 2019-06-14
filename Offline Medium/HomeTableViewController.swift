//
//  HomeTableViewController.swift
//  Offline Medium
//
//  Created by Dan Danilescu on 9/13/17.
//  Copyright © 2017 Dan Danilescu. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class HomeTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var posts : Results<PostObj>!
    let mediumGreen = UIColor(red: 0.125490196078431, green: 0.701960784313725, blue: 0.576470588235294, alpha: 1.0)
    
    // MARK: EnumSegueable
    enum SegueIdentifier: String {
        case showPostViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.posts = DBManager.sharedInstance.getDataFromDB(query: nil)
        self.reloadFetchedData()
        self.tableView.tableFooterView = UIView()
        self.searchBar.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()
        searchBar.backgroundImage = UIImage(color: mediumGreen, size: searchBar.bounds.size)
        searchBar.barTintColor = mediumGreen
        
        if posts.count == 0 {
            loginButton.title = "Login"
        } else {
            loginButton.title = "Refresh"
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadFetchedData()

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if self.posts.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "You have no posts"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.posts = DBManager.sharedInstance.getDataFromDB(query: searchBar.text)
        self.reloadFetchedData()
    }
    
    func reloadFetchedData(){
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeTableViewCell
        
        let index = Int(indexPath.row)
        let post = self.posts[index]
        
        cell.titleLabel.text = post.title
        cell.authorLabel.text = "By: \(post.author)"
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let adding = NSString(string: post.mainImage)
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(adding.lastPathComponent)
            let image    = UIImage(contentsOfFile: imageURL.path)
            // Do whatever you want with the image
//            let dataDecoded : Data = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!
            
            cell.mainImage.image = image
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if( indexPath.row > -1) {

            let index = Int(indexPath.row)
            let post = DBManager.sharedInstance.getDataFromDB()[index]
            
            
            let postViewController = PostViewController()
            postViewController.currentPost = post
            navigationController?.pushViewController(postViewController, animated: true)
//            
//            vc?.currentPost = post
//            self.performSegue(withIdentifier: "showPostSegue", sender: self)
        }
        
        print("You selected cell number: \(indexPath.row)!")
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
