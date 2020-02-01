//
//  PlacePostCollectionCell.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/2.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

class PlacePostCollectionCell: UICollectionViewCell {

    static var identifier: String {
        return String(describing: PlacePostCollectionCell.self)
    }
    
    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
