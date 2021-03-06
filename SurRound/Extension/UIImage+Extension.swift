//
//  UIImage+Extension.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/20.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

enum ImageAsset: String {
    
    // swiftlint:disable identifier_name
    case TabBarIcon_42px_Home
    case TabBarIcon_42px_Explore
    case TabBarIcon_42px_Message
    case TabBarIcon_42px_Profile
    case TabBarIcon_42px_Add
    
    case TabBarIcon_42px_Home_Selected
    case TabBarIcon_42px_Explore_Selected
    case TabBarIcon_42px_Message_Selected
    case TabBarIcon_42px_Profile_Selected
    case TabBarIcon_Bell_Selected
    case TabBarIcon_Bell
    
    case Icons_Add02
    
    case Icons_16px_RestaurantMarker
    case Icons_Avatar
    case Icons_Close
    
    case Image_Placeholder
    case Image_Avatar_Placeholder
    
    case Icons_Category_Ask
    case Icons_Category_Chat
    case Icons_Category_Food
    case Icons_Category_Scenary
    case Icons_Category_Shop
    // swiftlint:enable identifier_name
}

extension UIImage {
    
    static func asset(_ asset: ImageAsset) -> UIImage? {
        
        return UIImage(named: asset.rawValue)
    }
}
