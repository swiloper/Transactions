//
//  SubtitleTableViewCell.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 17.03.2024.
//

import UIKit

final class SubtitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
