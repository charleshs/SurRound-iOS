//
//  SelectLocationViewController.swift
//  SurRound
//
//  Created by Kai-Ta Hsieh on 2020/2/6.
//  Copyright © 2020 Kai-Ta Hsieh. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol SelectLocationViewControllerDelegate: AnyObject {
    
    func didSelectLocation(_ controller: SelectLocationViewController, with place: SRPlace)
}

class SelectLocationViewController: UIViewController {
    
    deinit {
        debugPrint("$ deinit: SelectLocationViewController")
    }
    
    static func storyboardInstance() -> SelectLocationViewController? {
        return UIStoryboard.newPost.instantiateViewController(
            identifier: String(describing: SelectLocationViewController.self)
            ) as? SelectLocationViewController
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    
    weak var delegate: SelectLocationViewControllerDelegate?
    
    var place: SRPlace?
    
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var resultView: UITextView?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAutocompleteController()
        
        configureMap()
    }
    
    // MARK: - User Actions
    @IBAction func didSelectLocation(_ sender: UIButton) {
        
        guard let place = self.place else { return }
        
        delegate?.didSelectLocation(self, with: place)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    private func configureAutocompleteController() {
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    private func configureMap() {
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.rotateGestures = false
        
        if let mapStyleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: mapStyleURL)
        }
        
        if let location = PlaceManager.current.location {
            mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 18.0)
            self.place = SRPlace(coordinate: location.coordinate)
        }
    }
    
    private func moveMapCamera(to place: SRPlace) {
        
        let coordinate = CLLocationCoordinate2D(latitude: place.coordinate.latitude,
                                                longitude: place.coordinate.latitude)
        
        mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 18.0))
    }
}

extension SelectLocationViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        self.place = SRPlace(coordinate: position.targets)
    }
}

// MARK: - GMSAutocompleteResultsViewControllerDelegate
extension SelectLocationViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        searchController?.isActive = false
        
        print("Place name: \(String(describing: place.name))")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        
        mapView.camera = GMSCameraPosition(latitude: place.coordinate.latitude,
                                           longitude: place.coordinate.longitude,
                                           zoom: 18)
        self.place = SRPlace(place: place)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
        
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
