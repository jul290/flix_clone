//
//  NowPlayingViewController.swift
//  flix_clone
//
//  Created by Justin Lee on 1/29/18.
//  Copyright © 2018 Justin Lee. All rights reserved.
//

import UIKit
import AlamofireImage
import Reachability

class NowPlayingViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    var boolean = false
    
   

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        activityIndicator.startAnimating()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        tableView.dataSource = self
        fetchMovies()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.activityIndicator.stopAnimating()
            let reachability = Reachability()!
            
            if(reachability.connection == .none){
                print("yo")
                self.tableView.isHidden = false
                let alertController = UIAlertController(title: "Cannot get movies", message: "The Internet connection appears to be offline", preferredStyle: .actionSheet)
                let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { (action) in
                    //if(self.reachabilityChanged()==1){
                      //  print("hello")
                    let reachabilityAgain = Reachability()
                    if(reachabilityAgain?.connection != .none){
                        self.viewDidLoad()
                        //self.fetchMovies()
                        //self.boolean = true
                    }
                    
                }
                alertController.addAction(tryAgainAction)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true){
                    
                }
                
            }
            else {
                print("yes")
                self.tableView.isHidden = false
            }
        })
        }
 
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        //activityIndicator.startAnimating()
        //JJHUD.showLoading()
        fetchMovies()
        //JJHUD.hide()
        //activityIndicator.stopAnimating()
        
    }
    
    func reachabilityChanged() -> intmax_t {
        
        let reachability = Reachability()
        
        
        if(reachability?.connection != .none){
            return 1
        }
        else{
            return 2
        }
        
        
        
    }
    
   
        
        
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error{
                print(error.localizedDescription)
            } else if let data = data{
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterURL)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell){
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
            
        }
        
    }
    

        
        
        

        


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
    

  


