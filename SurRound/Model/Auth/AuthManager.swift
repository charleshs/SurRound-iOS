//
//  AuthManager.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/25.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias UserIDResult = (Result<String, Error>) -> Void

class AuthManager {
  
  static let shared = AuthManager()
  
  var currentUserID: String? {
    get {
      UserDefaults.standard.string(forKey: "SRUserID")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "SRUserID")
    }
  }
  
  private init() { }
  
  func signIn(email: String, password: String, completion: @escaping UserIDResult) {
    Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
      guard let user = authResult?.user, error == nil else {
        completion(.failure(error!))
        return
      }
      self.currentUserID = user.uid
      completion(.success(user.uid))
    }
  }
  
  func signUp(email: String, password: String, completion: @escaping UserIDResult) {
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      guard let user = authResult?.user, error == nil else {
        completion(.failure(error!))
        return
      }
      completion(.success(user.uid))
    }
  }
}
