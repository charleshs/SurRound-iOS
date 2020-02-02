//
//  FollowingListViewController.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/31.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit

class FollowingListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet { setupTableView() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
    }
    
    private func setupTableView() {
        
        tableView.registerCellWithNib(withCellClass: ImagePostListCell.self)
        
        tableView.separatorStyle = .none
    }
}

extension FollowingListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagePostListCell.identifier,
            for: indexPath)
        
        return cell
    }
}

extension FollowingListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 400
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let postDetailVC = UIStoryboard.post.instantiateInitialViewController() as? PostContentViewController else { return }
        
        self.present(postDetailVC, animated: true, completion: nil)
    }
}
