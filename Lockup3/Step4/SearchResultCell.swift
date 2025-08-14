//
//  SearchResultCell.swift
//  Lockup
//

import UIKit

class SearchResultCell: UITableViewCell {
    static let reuseID = "SearchResultCell"

    func configure(with result: SearchResult) {
        textLabel?.text = result.title
        detailTextLabel?.text = result.subtitle
        accessoryType = .disclosureIndicator
    }
}
