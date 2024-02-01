//
//  SearchResults.swift
//  NBA Stats Explorer
//
//  Created by Andrew Dimperio on 12/1/23.
//

import Foundation

struct ResponseData: Codable {
    let data: [SearchResult]
    let meta: Meta
}

struct Meta: Codable {
    let total_count: Int
}

struct SearchResult: Codable {
    let id: Int
    let first_name: String
    let height_feet: Int?
    let height_inches: Int?
    let last_name: String
    let position: String
    let team: Team
    let weight_pounds: Int?
    
    var fullName: String {
           return "\(first_name) \(last_name)"
       }
}

struct Team: Codable {
    let id: Int
    let abbreviation: String
    let city: String
    let conference: String
    let division: String
    let full_name: String
    let name: String
}

struct PlayerSeasonAveragesResponse: Codable {
    let data: [PlayerSeasonAverages]
}

struct PlayerSeasonAverages: Codable {
    let games_played: Int?
    let player_id: Int
    let season: Int
    let min: String?
    let fgm: Double?
    let fga: Double?
    let fg3m: Double?
    let fg3a: Double?
    let ftm: Double?
    let fta: Double?
    let oreb: Double?
    let dreb: Double?
    let reb: Double?
    let ast: Double?
    let stl: Double?
    let blk: Double?
    let turnover: Double?
    let pf: Double?
    var pts: Double?
    let fg_pct: Double?
    let fg3_pct: Double?
    let ft_pct: Double?
}
