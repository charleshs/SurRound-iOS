//
//  HomeViewController.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/1/25.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit
import GoogleMaps
import MobileCoreServices

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = .white
            
            collectionView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            collectionView.layer.cornerRadius = 8
            
            collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
            collectionView.layer.shadowOpacity = 0.6
            collectionView.layer.shadowColor = UIColor.lightGray.cgColor
            collectionView.layer.shadowRadius = 4
            
            collectionView.contentInset = UIEdgeInsets(top: cellHeightInset / 4,
                                                       left: cellLeadingInset,
                                                       bottom: 0,
                                                       right: 0)
        }
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private var mapPostViewModels: [MapPostViewModel] = [] {
        didSet {
            mapPostViewModels.forEach {
                $0.displayMarker(onMap: mapView)
            }
        }
    }
        
    private var storyEntities = [StoryCollection]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    private let cellHeightInset: CGFloat = 10
    private let cellLeadingInset: CGFloat = 8
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleNagivationLeftTitle()
        updateLocation()
        configureMap()
        
        if AuthManager.shared.currentUser != nil {
            AuthManager.shared.updateProfile(completion: { [weak self] profile in
                self?.fetchPosts(blockingUsers: profile.blocking)
                self?.fetchStories()
            })
        } else {
            fetchPosts()
            fetchStories()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(newPostHandler),
                                               name: Constant.NotificationId.newPost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchStories),
                                               name: Constant.NotificationId.newStory, object: nil)
    }
    
    // MARK: - User Actions
    @IBAction func showVideoRecording(_ sender: UIBarButtonItem) {
        
        displayNewStoryActionSheet()
    }
    
    @objc func newPostHandler(_ sender: Any) {
        guard let profile = AuthManager.shared.userProfile else {
            return
        }
        fetchPosts(blockingUsers: profile.blocking)
    }
    
    // MARK: - Fetching Data
    @objc func fetchStories() {
        
        storyEntities.removeAll()
        
        StoryManager().fetchStoryCollection { [weak self] result in
            
            switch result {
            case .success(let entities):
                self?.storyEntities.append(contentsOf: entities)
                
            case .failure(let error):
                SRProgressHUD.showFailure(text: error.localizedDescription)
            }
        }
    }
    
    @objc func fetchPosts(blockingUsers: [String] = []) {
        
        mapPostViewModels.removeAll()
        
        PostManager.shared.fetchAllPost { [weak self] result in
            
            switch result {
            case .success(let posts):
                
                let viewModels = posts.map { post in
                    MapPostViewModel(post: post)
                }
                
                DispatchQueue.main.async {
                    self?.mapPostViewModels = viewModels
                }
                
            case .failure(let error):
                SRProgressHUD.showFailure(text: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Methods
    private func styleNagivationLeftTitle() {
        
        let label = UILabel()
        label.textColor = UIColor.themeColor
        label.text = "SurRound"
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 32)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    private func updateLocation() {
        
        do {
            try PlaceManager.current.updateLocation()
            
        } catch PlaceManagerError.accessDenied {
            let alert = UIAlertController(title: "Location Services disabled",
                                          message: "Please enable Location Services in Settings",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
            
        } catch {
            print(error)
        }
    }
    
    private func configureMap() {
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        if let mapStyleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: mapStyleURL)
        }
        
        if let location = PlaceManager.current.location {
            mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 18.0)
        }
    }
    
    private func sendStory(_ url: URL?) {
        
        guard let url = url else { return }
        guard let place = PlaceManager.current.place else {
            return
        }
        
        SRProgressHUD.showLoading()
        do {
            try StoryManager().createStory(url, at: place) { result in
                
                SRProgressHUD.dismiss()
                switch result {
                case .success:
                    SRProgressHUD.showSuccess()
                    NotificationCenter.default.post(name: Constant.NotificationId.newStory, object: nil)
                    
                case .failure(let error):
                    SRProgressHUD.showFailure(text: error.localizedDescription)
                }
            }
        } catch {
            SRProgressHUD.showFailure(text: "Unable to convert file to Data")
        }
    }
    
    private func displayNewStoryActionSheet() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        let imagePickerAlert = UIAlertController(title: "Post Video Story",
                                                 message: "Select video source from",
                                                 preferredStyle: .actionSheet)
        imagePickerAlert.addAction(
            UIAlertAction(title: "Library", style: .default) { [weak self] _ in
                
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.mediaTypes = [kUTTypeMovie as String]
                    self?.present(imagePicker, animated: true, completion: nil)
                }
        })
        imagePickerAlert.addAction(
            UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePicker.sourceType = .camera
                    imagePicker.mediaTypes = [kUTTypeMovie as String]
                    imagePicker.videoQuality = .typeHigh
                    self?.present(imagePicker, animated: true, completion: nil)
                }
        })
        imagePickerAlert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in
                
                imagePickerAlert.dismiss(animated: true, completion: nil)
        })
        present(imagePickerAlert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return storyEntities.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StoryPreviewCell.reuseIdentifier, for: indexPath)
        
        guard let storyCell = cell as? StoryPreviewCell else {
            return cell
        }
        
        if indexPath.item == 0 {
            storyCell.showAsNewStoryButton()
            
        } else {
            let storyEntity = storyEntities[indexPath.item - 1]
            storyCell.layoutCell(image: storyEntity.author.avatar,
                                 text: storyEntity.author.username)
        }
        return storyCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellHeight = collectionView.frame.size.height - cellHeightInset
        
        return CGSize(width: cellHeight, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            displayNewStoryActionSheet()
            
        } else {
            guard let storyVC = UIStoryboard.story.instantiateInitialViewController()
                as? StoryViewController else {
                    return
            }
            storyVC.modalPresentationStyle = .overCurrentContext
            storyVC.storyEntities = storyEntities
            storyVC.initialIndexPath = IndexPath(item: 0, section: indexPath.item - 1)
            tabBarController?.present(storyVC, animated: true, completion: nil)
        }
    }
}

// MARK: - GMSMapViewDelegate
extension HomeViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let matches = mapPostViewModels.filter { (mapPost) -> Bool in
            return marker == mapPost.mapMarker
        }
        guard
            let first = matches.first,
            let nav = UIStoryboard.post.instantiateInitialViewController() as? UINavigationController,
            let postVC = nav.topViewController as? PostContentViewController else {
                return false
        }
        postVC.post = first.post
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        return true
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        if let myLocation = mapView.myLocation {
            mapView.animate(to: GMSCameraPosition(target: myLocation.coordinate, zoom: 18))
            return true
        }
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                return
        }
        dismiss(animated: true, completion: { [weak self] in
            self?.sendStory(url)
        })
    }
}

// MARK: - UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate {
    
}
