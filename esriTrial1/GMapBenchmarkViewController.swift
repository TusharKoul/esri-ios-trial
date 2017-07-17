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
    
    private let mapCenterPoint = CLLocationCoordinate2D(latitude: 34.057, longitude: -117.196)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: mapCenterPoint.latitude, longitude: mapCenterPoint.longitude, zoom: 10.0)
        
        self.mapView.camera = camera
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
        let b = Benchmarker()
        let actionBlock = { [unowned self] in
            self.addGraphic()
        }
        let resetBlock = { [unowned self] in
            self.mapView.clear()
        }
        b.runBenchmark(iterations: 10, actionCount: 10000, actionBlock: actionBlock, resetBlock: resetBlock)
    }

    func addGraphic() {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = self.mapCenterPoint
        marker.map = self.mapView
    }
}
