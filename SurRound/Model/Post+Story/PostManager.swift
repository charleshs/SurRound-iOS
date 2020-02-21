//
//  PostManager.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/31.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

typealias PostsResult = (Result<[Post], FirestoreServiceError>) -> Void

class PostManager {
    
    private let dataFetcher: DataFetching
    
    init(dataFetcher: DataFetching = GenericFetcher()) {
        
        self.dataFetcher = dataFetcher
    }
    
    func likePost(postId: String, uid: String, completion: @escaping () -> Void) {
        
        let docRef = FirestoreDB.posts.document(postId)
        
        docRef.setData([
            "likedBy": FieldValue.arrayUnion([uid]),
            Post.CodingKeys.likeCount.rawValue: FieldValue.increment(Int64(1))
        ], merge: true) { (error) in
            
            guard error == nil else { return }
            completion()
        }
    }
    
    func dislikePost(postId: String, uid: String, completion: @escaping () -> Void) {
        
        let docRef = FirestoreDB.posts.document(postId)
        
        docRef.setData([
            "likedBy": FieldValue.arrayRemove([uid]),
            Post.CodingKeys.likeCount.rawValue: FieldValue.increment(Int64(-1))
        ], merge: true) { (error) in
            
            guard error == nil else { return }
            completion()
        }
    }
    
    func fetchNearestPost(coordinate: Coordinate, completion: @escaping PostsResult) {
        
        let query = FirestoreDB.posts
            .whereField(Post.CodingKeys.latitude.rawValue, isGreaterThanOrEqualTo: coordinate.latitude - 1)
            .whereField(Post.CodingKeys.latitude.rawValue, isLessThanOrEqualTo: coordinate.latitude + 1)
        
        _fetch(from: query) { (result) in
            switch result {
            case .success(let posts):
                let sortedPosts = PostManager.sortByDistance(reference: coordinate, posts: posts)
                completion(.success(sortedPosts))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTrendingPost(completion: @escaping PostsResult) {
        
        let query = FirestoreDB.posts
            .order(by: Post.CodingKeys.likeCount.rawValue, descending: true)
        
        _fetch(from: query) { (result) in
            
            switch result {
            case .success(let posts):
                let filteredPosts = posts.filter { (post) -> Bool in
                    return post.mediaLink != nil
                }
                completion(.success(filteredPosts))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPostOfUsers(uids: [String], completion: @escaping PostsResult) {
        
        let query = FirestoreDB.posts
            .whereField(Post.CodingKeys.authorId.rawValue, in: uids)
            .order(by: Post.CodingKeys.createdTime.rawValue, descending: true)
        
        _fetch(from: query, completion: completion)
    }
    
    func fetchAllPost(completion: @escaping PostsResult) {
        
        let query = FirestoreDB.posts
            .order(by: Post.CodingKeys.createdTime.rawValue, descending: true)
        
        _fetch(from: query, completion: completion)
    }
    
    // MARK: - Private Methods
    private func _fetch(from query: Query, completion: @escaping PostsResult) {
        
        dataFetcher.fetch(from: query) { (result) in
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            case .success(let documents):
                guard let posts = GenericParser.parse(documents, of: Post.self) else {
                    DispatchQueue.main.async {
                        completion(.failure(.parsingError))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            }
        }
    }
    
    private func attachImage(to documentRef: DocumentReference, image: UIImage, completion: @escaping () -> Void) {
        
        StorageManager().uploadImage(image, filename: NSUUID().uuidString) { url in
            guard let url = url else { return }
            
            documentRef.setData([
                "media_type": "image",
                "media_link": url.absoluteString
            ], merge: true) { (_) in
                completion()
            }
        }
    }
}

// MARK: - Create
extension PostManager {
    
    func createPost(_ post: Post, image: UIImage? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let user = AuthManager.shared.currentUser else { return }
        
        let documentRef = FirestoreDB.posts.document(post.id)
        let group = DispatchGroup()
        
        do {
            try documentRef.setData(from: post, merge: true, encoder: Firestore.Encoder()) { error in
                
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                UserDBService.attachPost(user: user, postRef: documentRef)
                
                if let imageToAttach = image {
                    group.enter()
                    self.attachImage(to: documentRef, image: imageToAttach) {
                        group.leave()
                    }
                }
                group.wait()
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Static Functions
extension PostManager {
    
    static func documentID() -> String {
        
        return FirestoreDB.posts.document().documentID
    }
    
    static func sortByDistance(reference: Coordinate, posts: [Post]) -> [Post] {
        
        var distanceMap: [Post: Double] = [:]
        posts.forEach { post in
            let distance = PlaceManager.calculateDistance(post.place.coordinate, reference: reference)
            distanceMap[post] = distance
        }
        let sortedMap = distanceMap.sorted { (lhs, rls) -> Bool in
            return lhs.value <= rls.value
        }
        let sortedPosts = sortedMap.map { $0.key }
        
        return sortedPosts
    }
}
