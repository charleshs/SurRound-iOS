//
//  UserModel.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/25.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SRUser: Codable {
    
    let uid: String
    let email: String
    let username: String
    var avatar: String?
    
    enum CodingKeys: String, CodingKey {
        
        case uid
        case email
        case username
        case avatar
    }
}
