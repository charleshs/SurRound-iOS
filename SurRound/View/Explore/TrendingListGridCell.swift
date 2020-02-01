//
//  TrendingListGridCell.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/1.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

class TrendingListGridCell: UICollectionViewCell {

    static var identifier: String {
        return String(describing: TrendingListGridCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .gray
    }
}
