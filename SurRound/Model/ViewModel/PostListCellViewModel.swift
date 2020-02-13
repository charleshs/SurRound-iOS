//
//  PostListCellViewModel.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/6.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

protocol PostListCellViewModel {
    
    var cellType: PostListCellType { get }
    
    var isFollowing: Bool { get }
}

class ImagePostListCellViewModel: PostListCellViewModel {
    
    var cellType: PostListCellType {
        return PostListCellType.image
    }
    
    var authorId: String
    var username: String
    var userImageUrlString: String?
    var placeName: String?
    var datetime: String
    var postImageUrlString: String?
    var text: String
    
    var isFollowing: Bool {
        
        guard let userProfile = AuthManager.shared.userProfile else {
            return false
        }
        return userProfile.following.contains(authorId)
    }
    
    init(_ post: Post) {
        
        self.authorId = post.authorId
        self.username = post.author.username
        self.userImageUrlString = post.author.avatar
        self.placeName = post.place.name
        self.datetime = post.datetimeString
        self.postImageUrlString = post.mediaLink
        self.text = post.text
    }
}

class TextPostListCellViewModel: PostListCellViewModel {
    
    var isFollowing: Bool {
        
        guard let userProfile = AuthManager.shared.userProfile else {
            return false
        }
        return userProfile.following.contains(authorId)
    }

    var cellType: PostListCellType {
        return PostListCellType.text
    }
    
    var authorId: String
    var username: String
    var userImageUrlString: String?
    var placeName: String?
    var datetime: String
    var text: String
    
    init(_ post: Post) {
        
        self.authorId = post.authorId
        self.username = post.author.username
        self.userImageUrlString = post.author.avatar
        self.placeName = post.place.name
        self.datetime = post.datetimeString
        self.text = post.text
    }
}

class VideoPostListCellViewModel: PostListCellViewModel {
    
    var isFollowing: Bool = false
    
    var cellType: PostListCellType {
        return PostListCellType.video
    }
    
    init(_ post: Post) {
        
    }
}
