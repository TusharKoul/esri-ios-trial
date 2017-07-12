//
//  GMapBenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit

import GoogleMaps

class GMapBenchmarkViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeGoogleMapApi()

        let camera = GMSCameraPosition.camera(withLatitude: 34.057, longitude: -117.196, zoom: 10.0)
        
        self.mapView.camera = camera
    }
    
    func initializeGoogleMapApi() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist"), let keys = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            GMSServices.provideAPIKey(keys["gmapApiKey"] as! String)
        }
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
        let b = Benchmarker()
        let actionBlock = {
            self.addGraphic()
        }
        let resetBlock = {
            self.mapView.clear()
        }
        b.runBenchmark(iterations: 100, actionCount: 10000, actionBlock: actionBlock, resetBlock: resetBlock)
    }

    func addGraphic() {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 34.057, longitude: -117.196)
        marker.map = self.mapView
    }
}
