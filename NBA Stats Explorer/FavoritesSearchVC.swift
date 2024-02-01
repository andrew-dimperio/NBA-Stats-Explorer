//
//  SearchViewControllerFavorites.swift
//  NBA Stats Explorer
//
//  Created by Andrew Dimperio on 12/5/23.
//
import Foundation
import UIKit

protocol FavoritesDelegate: AnyObject {
    func didFavoritePlayer(_ player: SearchResult, stats: PlayerSeasonAverages, team: Team)
    func saveFavoritePlayers()
    func removeFavoritePlayer(withID playerID: Int)
}



struct FavoritePlayer: Codable {
    let player: SearchResult
    let playerStats: PlayerSeasonAverages
    let team: Team
}



class FavoritesSearchVC: UIViewController, FavoritesDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var animatedView: UIView!
    
    var favoritePlayers: [FavoritePlayer] = []
    var hasSearched = false
    //var searchResults: [SearchResult] = []
    var searchResults: [FavoritePlayer] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoritePlayerCell")
        loadFavoritePlayers()
        searchResults = favoritePlayers
        //tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailFromFavorites",
            let destinationVC = segue.destination as? DetailViewController,
            let selectedPlayer = sender as? FavoritePlayer {
                destinationVC.searchResult = selectedPlayer.player
                destinationVC.playerStats = selectedPlayer.playerStats
                destinationVC.team = selectedPlayer.team
                destinationVC.favoritesDelegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            animateView()
        }

    
    func animateView() {
            self.animatedView.alpha = 0.0
            UIView.animate(withDuration: 1.0, animations: {
                self.animatedView.alpha = 1.0
            })
        }



    func didFavoritePlayer(_ player: SearchResult, stats: PlayerSeasonAverages, team: Team) {
        let favoritePlayer = FavoritePlayer(player: player, playerStats: stats, team: team)
        favoritePlayers.append(favoritePlayer)
        saveFavoritePlayers()
        loadFavoritePlayers()
        
        if let searchText = searchBar?.text, !searchText.isEmpty {
            searchResults = favoritePlayers.filter {
                $0.player.fullName.lowercased().contains(searchText.lowercased())
            }
        } else {
            searchResults = favoritePlayers
        }
        
        if let tableView = tableView {
            tableView.reloadData()
        } else {
            print("tableView is nil")
        }
    }

    
    func removeFavoritePlayer(withID playerID: Int) {
        if let index = favoritePlayers.firstIndex(where: { $0.player.id == playerID }) {
            favoritePlayers.remove(at: index)
            saveFavoritePlayers()
            loadFavoritePlayers()
            if let searchText = searchBar?.text, !searchText.isEmpty {
                searchResults = favoritePlayers.filter {
                $0.player.fullName.lowercased().contains(searchText.lowercased())
                }
            } else {
                searchResults = favoritePlayers
                }
            if let tableView = tableView {
                    tableView.reloadData()
                } else {
                    print("tableView is nil")
                }
            print("Player removed from favorites \(playerID)")
        }
    }
    
    func saveFavoritePlayers() {
        do {
            let encodedData = try JSONEncoder().encode(favoritePlayers)
            UserDefaults.standard.set(encodedData, forKey: "FavoritePlayers")
        } catch {
            print("Error encoding favorite players: \(error.localizedDescription)")
        }
    }

    func loadFavoritePlayers() {
        if let encodedData = UserDefaults.standard.data(forKey: "FavoritePlayers") {
            do {
                let decodedPlayers = try JSONDecoder().decode([FavoritePlayer].self, from: encodedData)
                favoritePlayers = decodedPlayers
                favoritePlayers.sort { (favoritePlayer1, favoritePlayer2) -> Bool in
                    let lastName1 = favoritePlayer1.player.last_name.lowercased()
                    let lastName2 = favoritePlayer2.player.last_name.lowercased()
                    return lastName1 < lastName2
                }
                
                //tableView.reloadData()
            } catch {
                print("Error decoding favorite players: \(error.localizedDescription)")
            }
        }
    }

    
    
    
}




extension FavoritesSearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                searchResults = favoritePlayers
            } else {
                searchResults = favoritePlayers.filter { player in
                    let searchString = searchText.lowercased()
                    let fullName = "\(player.player.first_name) \(player.player.last_name)".lowercased()
                    return fullName.contains(searchString)
                }
            }
            tableView.reloadData()
        }


    
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}


extension FavoritesSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavoritePlayerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let favoritePlayer = searchResults[indexPath.row]
        cell.textLabel?.text = favoritePlayer.player.fullName
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPlayer = favoritePlayers[indexPath.row]
        
        performSegue(withIdentifier: "ShowDetailFromFavorites", sender: selectedPlayer)
        
        
        }
}
    


    

    
