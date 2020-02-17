//
//  FirestoreService.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/11.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum FirestoreServiceError: Error {
    
    case fetchingError
    case parsingError
}

class FirestoreService {
    
    struct Collection {
        static let users = "users"
        static let posts = "posts"
        static let stories = "stories"
        static let reviews = "reviews"
        static let userPosts = "user_posts"
        static let userStories = "user_stories"
        static let notifications = "notifications"
    }

    static var users: CollectionReference {
        
        return Firestore.firestore().collection(Collection.users)
    }
    
    static var posts: CollectionReference {
        
        return Firestore.firestore().collection(Collection.posts)
    }
    
    static var stories: CollectionReference {
        
        return Firestore.firestore().collection(Collection.stories)
    }
    
    static func reviews(of postId: String) -> CollectionReference {
        
        return posts.document(postId).collection(Collection.reviews)
    }
    
    static func userPosts(of userId: String) -> CollectionReference {
        
        return users.document(userId).collection(Collection.userPosts)
    }
    
    static func userStories(of userId: String) -> CollectionReference {
        
        return users.document(userId).collection(Collection.userStories)
    }
    
    static func notifications(of userId: String) -> CollectionReference {
        
        return users.document(userId).collection(Collection.notifications)
    }
}
