//
//  EsriRoutingBenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/17/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class EsriRoutingBenchmarkViewController: UIViewController {
    @IBOutlet weak var mapView: AGSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //using a tpk to create a local tiled layer
        //which will be visible in case of no network connection
        let path = Bundle.main.path(forResource: "streetmap_SD", ofType: "tpk")!
        let localTiledLayer = AGSArcGISTiledLayer(tileCache: AGSTileCache(fileURL: URL(fileURLWithPath: path)))
        
        //initialize the map using the local tiled layer as baselayer
        //assign the map to the map view
        self.mapView.map = AGSMap(basemap: AGSBasemap(baseLayer: localTiledLayer))
        

        // Do any additional setup after loading the view.
    }

    @IBAction func startPressed(_ sender: Any) {
    }
}
