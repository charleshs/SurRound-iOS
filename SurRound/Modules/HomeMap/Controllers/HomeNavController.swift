//
//  HomeNavController.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/22.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

class HomeNavController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.shadowImage = UIImage()
        navigationBar.barStyle = .default
        navigationBar.tintColor = UIColor.themeColor
        navigationBar.barTintColor = .white
    }
}
