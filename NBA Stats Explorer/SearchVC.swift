//
//  ViewController.swift
//  NBA Stats Explorer
//
//  Created by Andrew Dimperio on 11/27/23.
//

import UIKit

class SearchVC: UIViewController{
    
    struct TableView {
        struct CellIdentifiers {
            static let loadingCell = "loadingCell"
            static let searchResultCell = "searchResultCell"
            static let nothingFoundCell = "nothingFoundCell"
            
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var searchResults: [SearchResult] = []
    var playerResults: [PlayerSeasonAverages] = []
    var hasSearched = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail", let destinationVC = segue.destination as? DetailViewController {
            if let data = sender as? (SearchResult, PlayerSeasonAverages, Team) {
                destinationVC.searchResult = data.0
                destinationVC.playerStats = data.1
                destinationVC.team = data.2
                if let favoritesSearchVC = tabBarController?.viewControllers?.first(where: { $0 is FavoritesSearchVC }) as? FavoritesSearchVC {
                    destinationVC.favoritesDelegate = favoritesSearchVC
                }
            }
        }
    }
    
    
    func fetchCurrentSeasonStats(for player: SearchResult, completion: @escaping (PlayerSeasonAverages?) -> Void) {
        let playerID = player.id
        let statsURLString = "https://www.balldontlie.io/api/v1/season_averages?player_ids[]=\(playerID)"
        
        guard let statsURL = URL(string: statsURLString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: statsURL) { [weak self] (data, response, error) in
            guard self != nil else { return }
            
            if let error = error {
                print("Error fetching data: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let statsResponse = try decoder.decode(PlayerSeasonAveragesResponse.self, from: data)
                
                if let playerStats = statsResponse.data.first {
                    completion(playerStats)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
    func ballDontLieURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(
            format: "https://www.balldontlie.io/api/v1/players?search=%@&per_page=100&seasons[]=2018&start_date=2018-01-01",
            encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    
    func performStoreRequest(with url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("Download Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            completion(data)
        }
        task.resume()
    }

        func parse(data: Data) {
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ResponseData.self, from: data)
    
                var filteredResults: [SearchResult] = []
    
                for player in response.data {
                    fetchCurrentSeasonStats(for: player) { playerStats in
                        if let playerStats = playerStats, let gamesPlayed = playerStats.games_played, gamesPlayed > 0 {
                            filteredResults.append(player)
                        }
    
                        DispatchQueue.main.async {
                            self.searchResults = filteredResults
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                    }
                }
            } catch {
                print("JSON Error: \(error)")
            }
        }
    }
    



    
    
    
    extension SearchVC: UISearchBarDelegate {
       
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            if let searchText = searchBar.text, !searchText.isEmpty {
                searchBar.resignFirstResponder()
                isLoading = true
                tableView.reloadData()
                hasSearched = true
                searchResults.removeAll()
                
                let url = ballDontLieURL(searchText: searchBar.text!)
                print("URL: '\(url)'")
                
                performStoreRequest(with: url) { [weak self] data in
                    guard let self = self else { return }
                    
                    if let data = data {
                        self.parse(data: data)
                    }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        func filterResults(for searchText: String) -> [SearchResult] {
            return searchResults.filter { result in
                let fullName = "\(result.first_name.lowercased()) \(result.last_name.lowercased())"
                let searchTerm = searchText.lowercased()
                return fullName.contains(searchTerm)
            }
        }
        
        
        
        func updateSearchResults(_ filteredResults: [SearchResult]) {
            searchResults = filteredResults
        }
        
        func position(for bar: UIBarPositioning) -> UIBarPosition {
            return .topAttached
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = nil
            searchBar.resignFirstResponder()
            hasSearched = false
            tableView.reloadData()
        }
        
    }
    
    extension SearchVC: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if isLoading {
                let loadingCell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
                let spinner = loadingCell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return loadingCell
            } else if searchResults.isEmpty {
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
                let result = searchResults[indexPath.row]
                cell.configure(with: result)
                return cell
            }
        }




           

        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if isLoading {
                return 1
            } else if !hasSearched {
                return 0
            } else if searchResults.count == 0 {
                return 1
            } else {
                return searchResults.count
            }
        }
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let selectedPlayer = searchResults[indexPath.row]

            fetchCurrentSeasonStats(for: selectedPlayer) { [weak self, selectedPlayer] playerStats in
                guard let self = self else { return }
                guard let playerStats = playerStats else { return }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ShowDetail", sender: (selectedPlayer, playerStats, selectedPlayer.team))
                }
            }
        }

        
        
        func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
            if searchResults.count == 0 || isLoading {
                return nil
            } else {
                return indexPath
            }
        }
        
    }
