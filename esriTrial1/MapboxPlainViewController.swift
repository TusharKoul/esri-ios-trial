//
//  MapboxPlainViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 8/2/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import Mapbox
class MapboxPlainViewController: UIViewController {

    @IBOutlet weak var mapView: MGLMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.styleURL = URL(string: "mapbox://styles/mapbox/streets-v10")
    }

}
