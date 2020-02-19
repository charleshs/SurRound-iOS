//
//  ProfileManager.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/12.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class ProfileManager {
    
    var userProfile: SRUserProfile?
    
    private var dataFetcher: DataFetching
    
    init(dataFetcher: DataFetching = GenericFetcher()) {
        self.dataFetcher = dataFetcher
    }
    
    func updateAvatar(_ image: UIImage, uid: String, completion: @escaping (Error?) -> Void) {
        
        let storageManager = StorageManager()
        
        storageManager.uploadAvatar(image, userId: uid) { (url) in
            
            guard let url = url else { return }
            
            UIImageView.clearCache()
            
            let dict: [String: Any] = [SRUser.CodingKeys.avatar.rawValue: url.absoluteString]
            FirestoreDB.users.document(uid).setData(dict, merge: true) { (error) in
                guard error == nil else {
                    completion(error!)
                    return
                }
                completion(nil)
            }
        }
    }
    
    func fetchUserList(uids: [String], completion: @escaping ([SRUser]) -> Void) {
        
        let query = FirestoreDB.users.whereField(SRUser.CodingKeys.uid.rawValue, in: uids)
        
        dataFetcher.fetch(from: query) { result in
            switch result {
            case .success(let documents):
                guard let users = GenericParser.parse(documents, of: SRUser.self) else {
                    completion([])
                    return
                }
                completion(users)
                
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
    
    func fetchProfile(user uid: String, completion: @escaping (SRUserProfile?) -> Void) {
        
        let group = DispatchGroup()
        
        let docRef = FirestoreDB.users.document(uid)
        
        group.enter()
        dataFetcher.fetch(from: docRef) { result in
            
            switch result {
            case .success(let document):
                let profile = GenericParser.parse(document, of: SRUserProfile.self)
                self.userProfile = profile
                group.leave()
                
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
        
        let userPostRef = FirestoreDB.userPosts(of: uid)
        
        group.enter()
        dataFetcher.fetch(from: userPostRef) { result in
            
            switch result {
            case .success(let documents):
                if let userPosts = GenericParser.parse(documents, of: UserPost.self) {
                    self.userProfile?.posts = userPosts
                    group.leave()
                }
                
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
        
        let userStoryRef = FirestoreDB.userStories(of: uid)
        
        group.enter()
        dataFetcher.fetch(from: userStoryRef) { result in
            
            switch result {
            case .success(let documents):
                if let userStories = GenericParser.parse(documents, of: UserStory.self) {
                    self.userProfile?.stories = userStories
                    group.leave()
                }
                
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
        
        group.notify(queue: .main) {
            completion(self.userProfile)
        }
    }
    
    func blockUser(target: SRUser, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let currentUser = AuthManager.shared.currentUser else {
            return
        }
        
        let userRef = FirestoreDB.users.document(currentUser.uid)
        
        userRef.setData(
            ["blocking": FieldValue.arrayUnion([target.uid])],
            merge: true,
            completion: { error in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(()))
        })
    }
    
    func followUser(receiverId: String, current user: SRUser, completion: @escaping (Error?) -> Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        FirestoreDB.users.document(user.uid)
            .setData(["following": FieldValue.arrayUnion([receiverId])], merge: true) { error in
                
                guard error == nil else {
                    completion(error!)
                    return
                }
                group.leave()
        }
        
        group.enter()
        FirestoreDB.users.document(receiverId)
            .setData(["follower": FieldValue.arrayUnion([user.uid])], merge: true) { error in
                
                guard error == nil else {
                    completion(error!)
                    return
                }
                group.leave()
        }
        
        group.enter()
        FirestoreDB.users.document(receiverId).collection("notifications").document()
            .setData([
                "type": "follow",
                "sender_name": user.username,
                "sender_id": user.uid
            ], merge: true) { error in
                
                guard error == nil else {
                    completion(error!)
                    return
                }
                group.leave()
        }
        
        group.notify(queue: .main) {
            completion(nil)
        }
    }
}
