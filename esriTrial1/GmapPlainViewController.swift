//
//  GmapPlainViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 8/2/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import GoogleMaps
class GmapPlainViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 0)
        self.mapView.camera = camera
    }
}
