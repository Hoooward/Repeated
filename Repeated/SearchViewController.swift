//
//  FirstViewController.swift
//  Repeated
//
//  Created by Howard on 1/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    //可能存在很多个不一样的 cell 标识符.
    struct TableViewCellIdentifiers  {
        static let searchResultCell = "SearchResultCell"
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResult = [SearchResult]()
    
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView 上面有搜索栏和状态栏,分别是44高和20高
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        
        tableView.rowHeight = 60
        
        let cellNib = UINib(nibName:TableViewCellIdentifiers.searchResultCell , bundle: nil)
        
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //更改 statusbar 的颜色
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func urlWithSearchText(searchText: String) -> NSURL {
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format: "http://fanyi.youdao.com/openapi.do?keyfrom=Repeated&key=372137062&type=data&doctype=json&version=1.1&q=%@", escapedSearchText)
        
        let url = NSURL(string: urlString)
        
        return url!
    }
    
    func performStoreRequestWithURL(url: NSURL) -> String? {
        
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }

    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult]? {
        //1
//        guard let array
        return nil
    }

    
    func parseSearchResult(dictionary : [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.translation = dictionary["translation"] as! [String]
        print("searchResult.translation  =  \(searchResult.translation)")
        searchResult.query = dictionary["query"] as! String
//        searchResult.web = dictionary["web"] as! [String]
        
        if let dict = dictionary["basic"] as? [String: AnyObject] {
            for (key, value) in dict {
                switch key {
                case "us-phonetic": searchResult.US_phonetic = value as! String
                case "uk-phonetic": searchResult.UK_phonetic = value as! String
                case "phonetic" : searchResult.phonetic = value as! String
                case "explains" : searchResult.explains = value as! [String]
                default: break
                }
            }
        }
        
        if let dictArray = dictionary["web"] as? [NSDictionary] {
            searchResult.web = dictArray
            
            for dict in dictArray {
                for (key, value) in dict {
                    print("key = \(key) value = \(value)")
                }
            }
        }
        print("searchResult.US \(searchResult.US_phonetic)")
        print("searchResult.UK \(searchResult.UK_phonetic)")
        print("searchResult.phonetic \(searchResult.phonetic)")
        print("searchResult.explains \(searchResult.explains)")
        print("searchResult.web \(searchResult.web)")
        
        
        return searchResult
    }
}



extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            hasSearched = true
            searchResult = [SearchResult]()
            
            let url = urlWithSearchText(searchBar.text!)
            
            let session = NSURLSession.sharedSession()
            
            let dataTask = session.dataTaskWithURL(url, completionHandler: {
            
                data, response, error in
                
                if let error = error {
                    print("Failure! \(error)")
                    
                } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200{
                   
                    if let data = data, dictionary = self.parseJSON(data) {
                        self.parseSearchResult(dictionary)
                    }
                }
            })
            
            dataTask.resume()
        }
        

        
        
        
        
        
        self.tableView.reloadData()
        
    }
    
    //让搜索栏和状态栏合并在一起的内置方法.
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell: SearchResultCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        
        
        
//        cell.wordLabel.text = searchResult[indexPath.row]
//        
//        cell.resultLabel.text = searchResult[indexPath.row]
      
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
}