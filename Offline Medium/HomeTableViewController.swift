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
    
    // didReceiveMemoryWarning is deprecated and no longer needed in modern iOS
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Type-safe cell dequeuing
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifier.postCell.identifier,
            for: indexPath
        ) as? HomeTableViewCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]

        cell.titleLabel.text = post.title
        cell.authorLabel.text = "By: \(post.author)"

        // Modern FileManager API - no more NSSearchPathForDirectoriesInDomains
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imagePath = (post.mainImage as NSString).lastPathComponent
            let imageURL = documentsDirectory.appendingPathComponent(imagePath)
            cell.mainImage.image = UIImage(contentsOfFile: imageURL.path)
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

// Modern UIImage extension using UIGraphicsImageRenderer (iOS 10+)
public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        guard let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
