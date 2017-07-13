//
//  MapboxBenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/12/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import Mapbox

class MapboxBenchmarkViewController: UIViewController {
    
    private let mapCenterPoint = CLLocationCoordinate2D(latitude: 34.057, longitude: -117.196)

    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.styleURL = URL(string: "mapbox://styles/mapbox/streets-v10")
        mapView.setCenter(mapCenterPoint, zoomLevel: 12, animated: false)
    
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
        let b = Benchmarker()
        let actionBlock = {
            self.addGraphic()
        }
        let resetBlock = {
            guard let annotations = self.mapView.annotations else {
                return
            }
            
            self.mapView.removeAnnotations(annotations)
        }
        b.runBenchmark(iterations: 100, actionCount: 10000, actionBlock: actionBlock, resetBlock: resetBlock)
    }
    
    func addGraphic() {
        let hello = MGLPointAnnotation()
        hello.coordinate = mapCenterPoint
//        hello.title = "Hello world!"
//        hello.subtitle = "Welcome to my marker"
        //Average time taken to do operation 10000 times = 0.00368870777998382, with sd = 0.0367018964863967

        // Add marker `hello` to the map.
        mapView.addAnnotation(hello)

    }

}
