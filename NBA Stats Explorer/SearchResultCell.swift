//
//  SearchResultCell.swift
//  NBA Stats Explorer
//
//  Created by Andrew Dimperio on 12/18/23.
//

import Foundation
import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var searchResults: [SearchResult] = []
    

    override func awakeFromNib() {
           super.awakeFromNib()
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
       }

       func configure(with searchResult: SearchResult) {
           let fullName = "\(searchResult.first_name) \(searchResult.last_name)"
           fullNameLabel.text = fullName
       }
   }
