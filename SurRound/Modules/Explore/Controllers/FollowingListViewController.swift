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
        didSet {
            tableView.registerCellWithNib(withCellClass: TextPostListCell.self)
            tableView.registerCellWithNib(withCellClass: ImagePostListCell.self)
            tableView.registerCellWithNib(withCellClass: VideoPostListCell.self)
            
            tableView.separatorStyle = .none
            
            tableView.addHeaderRefreshing { [weak self] in
                self?.refreshPosts()
            }
        }
    }
    
    private var posts: [Post] = []
    
    private var viewModels: [PostListCellViewModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshPosts()
    }
    
    // MARK: - Private Methods
    private func refreshPosts() {
        
        posts.removeAll()
        viewModels.removeAll()
        
        PostManager.shared.fetchAllPost { [weak self] result in
            
            self?.tableView.endHeaderRefreshing()
            
            switch result {
            case .success(let posts):
                self?.posts.append(contentsOf: posts)
                self?.viewModels.append(contentsOf: ViewModelFactory.viewModelFromPosts(posts))
                
            case .failure(let error):
                print(error)
                SRProgressHUD.showFailure(text: error.localizedDescription)
            }
        }
    }
}

extension FollowingListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = viewModels[indexPath.row]
        
        let cell = viewModel.cellType.makeCell(tableView, at: indexPath)
        guard let postListCell = cell as? PostListCell else {
            return cell
        }
        viewModel.onRequestUserProfile = { [weak self] user in
            if let profileVC = ProfileViewController.storyInstance() {
                profileVC.userToDisplay = user
                self?.show(profileVC, sender: nil)
            }
        }
        postListCell.layoutCell(with: viewModel)
        return postListCell
    }
}

extension FollowingListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard
            let nav = UIStoryboard.post.instantiateInitialViewController() as? UINavigationController,
            let postDetailVC = nav.topViewController as? PostContentViewController else { return }
        postDetailVC.post = posts[indexPath.row]
        nav.modalPresentationStyle = .overCurrentContext
        present(nav, animated: true, completion: nil)
    }
}