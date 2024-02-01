//
//  DetailViewController.swift
//  NBA Stats Explorer
//
//  Created by Andrew Dimperio on 12/6/23.
//

import Foundation
import UIKit
import AVFoundation

class DetailViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    var favoritesDelegate: FavoritesDelegate?
    @IBOutlet weak var yourView: UIView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var posLabel: UILabel!
    
    @IBOutlet weak var ppgLabel: UILabel!
    @IBOutlet weak var rpgLabel: UILabel!
    @IBOutlet weak var apgLabel: UILabel!
    @IBOutlet weak var spgLabel: UILabel!
    @IBOutlet weak var bpgLabel: UILabel!
    @IBOutlet weak var pfLabel: UILabel!
    @IBOutlet weak var gpLabel: UILabel!
    
    @IBOutlet weak var mpgLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fgmLabel: UILabel!
    @IBOutlet weak var fgaLabel: UILabel!
    @IBOutlet weak var fgpLabel: UILabel!
    @IBOutlet weak var tgpLabel: UILabel!
    @IBOutlet weak var ftpLabel: UILabel!
    
    
    //var player: SearchResult?
    
    var isFavorited: Bool = false
    var team: Team?
    var teamAbbreviation = ""
    var searchResult: SearchResult?
    var playerStats: PlayerSeasonAverages?
    var favoriteButtonKey: String {
        guard let playerID = searchResult?.id else {
            fatalError("Player ID is missing!")
        }
        return "favoriteButtonState_\(playerID)"
    }

    
    
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        loadButtonState()
        updateUI()
    }
    
    func teamsAbbreviation() {
        teamAbbreviation = team!.abbreviation
    }
    
    func setBackground(){
        teamsAbbreviation()
        let backgroundImage = UIImage(named: "\(teamAbbreviation)Wallpaper")
        let backgroundImageView = UIImageView(frame: yourView.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 1.0 // opacity
        yourView.addSubview(backgroundImageView)
        yourView.sendSubviewToBack(backgroundImageView)
    }
    
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            playSound(named: "favoriteSound")
            if let player = searchResult, let stats = playerStats, let team = team {
                favoritesDelegate?.didFavoritePlayer(player, stats: stats, team: team)
            }
            saveButtonState()
        } else {
            UserDefaults.standard.set(false, forKey: favoriteButtonKey)
            favoritesDelegate?.removeFavoritePlayer(withID: playerStats?.player_id ?? 000)
            
        }
    }


    
    func saveButtonState() {
        UserDefaults.standard.set(favoriteButton.isSelected, forKey: favoriteButtonKey)
    }
    
    func loadButtonState() {
        favoriteButton.isSelected = UserDefaults.standard.bool(forKey: favoriteButtonKey)
    }
    
    func playSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3")
        else {
            print("N/A")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        }
        catch {
            print("Error playing music")
        }
    }
    
    func updateUI() {
        nameLabel.text = searchResult?.fullName
        if searchResult?.fullName == nil {
        nameLabel.text = "Unknown"
    } else {
        nameLabel.text = searchResult?.fullName
      }
        setBackground()
        teamLabel.text = "\(team?.abbreviation ?? "n/a")"
        posLabel.text = "\(searchResult?.position ?? "n/a")"
        
        
        ppgLabel.text = String(format: "%.1f%", (playerStats?.pts ?? 0.0))
        rpgLabel.text = String(format: "%.1f%", (playerStats?.reb ?? 0.0))
        apgLabel.text = String(format: "%.1f%", (playerStats?.ast ?? 0.0))
        spgLabel.text = String(format: "%.1f%", (playerStats?.stl ?? 0.0))
        bpgLabel.text = String(format: "%.1f%", (playerStats?.blk ?? 0.0))
        pfLabel.text  = String(format: "%.1f%", (playerStats?.pf ?? 0.0))
        gpLabel.text  = "\(playerStats?.games_played ?? 0)"

        mpgLabel.text = "\(playerStats?.min ?? "0")"
        toLabel.text  = String(format: "%.1f%", (playerStats?.turnover ?? 0.0))
        fgmLabel.text = String(format: "%.1f%", (playerStats?.fgm ?? 0.0))
        fgaLabel.text = String(format: "%.1f%", (playerStats?.fga ?? 0.0))
        fgpLabel.text = String(format: "%.1f%%", (playerStats?.fg_pct ?? 0.0) * 100)
        tgpLabel.text = String(format: "%.1f%%", (playerStats?.fg3_pct ?? 0.0) * 100)
        ftpLabel.text = String(format: "%.1f%%", (playerStats?.ft_pct ?? 0.0) * 100)
    }
    
    
    
    
}
