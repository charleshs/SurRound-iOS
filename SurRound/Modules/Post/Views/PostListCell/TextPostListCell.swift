//
//  TextPostListCell.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/6.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

class TextPostListCell: PostListCell {
    
    @IBOutlet weak var substrateView: UIView!
    
    // Top Section
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    // Middle Section
    @IBOutlet weak var largeTextLabel: UILabel!
    
    // Bottom Section
    @IBOutlet weak var likedButton: UIButton!
    @IBOutlet weak var likedCountLabel: UILabel!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var reviewCountLabel: UILabel!
    
    var viewModel: TextPostListCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.onRequestUserProfile = nil
        viewModel.isLiked.removeObserver()
        viewModel.likeCount.removeObserver()
        viewModel.replyCount.removeObserver()
    }
    
    override func configure(with viewModel: PostListCellViewModel) {
        
        guard let viewModel = viewModel as? TextPostListCellViewModel else { return }
        
        // Top Section
        avatarImageView.loadImage(viewModel.userImageUrlString,
                                  placeholder: UIImage.asset(.Icons_Avatar))
        usernameLabel.text = viewModel.username
        placeNameLabel.text = viewModel.placeName
        datetimeLabel.text = viewModel.datetime
        
        // Middle Section
        largeTextLabel.text = viewModel.text
        likedCountLabel.text = String(viewModel.likeCount.value)
        reviewCountLabel.text = String(viewModel.replyCount.value)
        
        self.viewModel = viewModel
        self.viewModel.isLiked.addObserver { [weak self] status in
            guard let self = self else { return }
            self.likedButton.isSelected = status
            self.likedButton.tintColor = status ? .red : .darkGray
        }
        self.viewModel.likeCount.addObserver { [weak self] value in
            guard let self = self else { return }
            self.likedCountLabel.text = String(value)
        }
        self.viewModel.replyCount.addObserver { [weak self] value in
            guard let self = self else { return }
            self.reviewCountLabel.text = String(value)
        }
    }
    
    // MARK: - User Actions
    @IBAction func didTapLikedButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapReviewButton(_ sender: UIButton) {
        
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        
        avatarImageView.roundToHalfHeight()
        let tapOnUser = UITapGestureRecognizer(target: self, action: #selector(onTappingUser(_:)))
        avatarImageView.addGestureRecognizer(tapOnUser)
        usernameLabel.addGestureRecognizer(tapOnUser)
        styleSubstrateView()
    }
    
    private func styleSubstrateView() {
        
        substrateView.layer.cornerRadius = 8
        substrateView.layer.shadowColor = UIColor.lightGray.cgColor
        substrateView.layer.shadowOpacity = 0.7
        substrateView.layer.shadowRadius = 4
        substrateView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    @objc private func onTappingUser(_ sender: UITapGestureRecognizer) {
        
        let srUser = SRUser(uid: viewModel.authorId,
                            email: "",
                            username: viewModel.username,
                            avatar: viewModel.userImageUrlString)
        viewModel.onRequestUserProfile?(srUser)
    }
}
