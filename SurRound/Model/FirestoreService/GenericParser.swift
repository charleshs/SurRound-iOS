//
//  PostParser.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/11.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol DataParsing {
    
    associatedtype ParsedType
    
    func parse(_ documents: [QueryDocumentSnapshot]) -> [ParsedType]?
    
    func parse(_ document: DocumentSnapshot) -> ParsedType
}

class GenericParser {
        
    class func parse<T: Decodable>(_ documents: [QueryDocumentSnapshot], of type: T.Type) -> [T]? {
        
        let decoder = Firestore.Decoder()
        
        let parseItems = documents.map { document in
            return try? document.data(as: T.self, decoder: decoder)
        }
        
        if parseItems.count == 0 && documents.count > 0 { return nil }
        
        return parseItems.compactMap { $0 }
    }
}
