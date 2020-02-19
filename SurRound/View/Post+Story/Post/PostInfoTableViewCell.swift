//
//  LocationTableViewCell.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/25.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

class PostInfoTableViewCell: SRBaseTableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var datetimeLabel: UILabel!
    
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        styleCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.roundToHalfHeight()
    }
    
    func setupCell(with post: Post) {
        
        userImageView.loadImage(post.author.avatar, placeholder: UIImage.asset(.Icons_Avatar))
        usernameLabel.text = post.author.username
        datetimeLabel.text = post.datetimeString
        placeLabel.text = post.place.name
    }
    
    @IBAction func didTapFollowBtn(_ sender: UIButton) {
        
    }
    
    private func styleCell() {
        
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16
    }
}
