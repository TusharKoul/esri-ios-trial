//
//  EsriMemoryViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 8/1/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS
class EsriMemoryViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.map = AGSMap(basemapType: .streetsVector, latitude: 0.0, longitude: 0.0, levelOfDetail: 0)
        let graphicOverlay = AGSGraphicsOverlay()

        self.mapView.graphicsOverlays.add(graphicOverlay)
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        
        for _ in 1...BenchmarkHelper.getPointCount() {
            let coordinate = BenchmarkHelper.generateRandomCoordinate()
            let point = AGSPoint(clLocationCoordinate2D: coordinate)
            
        }
        
    }
}
