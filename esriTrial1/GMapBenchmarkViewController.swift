//
//  GMapBenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit

import GoogleMaps

class GMapBenchmarkViewController: UIViewController,BenchmarkSettingsDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    private let mapCenterPoint = CLLocationCoordinate2D(latitude: 34.057, longitude: -117.196)
    private let africaPoint = CLLocationCoordinate2D(latitude: 19.7968689, longitude: -0.5310485)
    private let ausPoint = CLLocationCoordinate2D(latitude: -21.182631, longitude: 121.5026582)
    
    //initializing benchmarking variables with defaults
    private var objectCount = 10000
    private var objectKind = GraphicObjectKind.Point
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupVariables()
        let camera = GMSCameraPosition.camera(withLatitude: mapCenterPoint.latitude, longitude: mapCenterPoint.longitude, zoom: 4)
        self.mapView.camera = camera
    }
    
    func setupVariables() {
        self.objectCount = BenchmarkHelper.getObjectCount()
        self.objectKind = BenchmarkHelper.getObjectKind()
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
        
        switch self.objectKind {
        case .Point:
            self.testAddPoint()
        case .Polyline:
            self.testAddPolyline()
        case .Polygon:
            self.testAddPolygon()
        }
        
//        self.oscillateViewpoints(toggle: true)
    }
    
    
    @IBAction func clearPressed(_ sender: Any) {
        self.mapView.clear()
    }
    
    
    func oscillateViewpoints(toggle:Bool) {
        var point:CLLocationCoordinate2D
        
        if(toggle) {
            point = self.ausPoint
        }
        else {
            point = self.mapCenterPoint
        }
        
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.oscillateViewpoints(toggle: !toggle)
        })
        
        //animation 
        self.mapView.animate(toLocation: point)
        
        CATransaction.commit()
    }
    
    func testAddPoint() {
        self.testAddGraphic(withActionCount: self.objectCount, actionBlock: { [unowned self] in
            let marker = GMSMarker()
            marker.position = self.mapCenterPoint
            marker.map = self.mapView
        })
    }

    func testAddPolyline() {
        let path = GMSMutablePath()
        
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        for c in coordinates {
            path.add(c)
        }
        
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polyline = GMSPolyline(path: path)
            polyline.map = self.mapView
        }
    }
    
    func testAddPolygon() {
        let path = GMSMutablePath()
        
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        for c in coordinates {
            path.add(c)
        }
        
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polygon = GMSPolygon(path: path)
            polygon.map = self.mapView
        }
    }
    
    func testAddGraphic(withActionCount actionCount:Int, actionBlock:(()->())) {
        let b = BenchmarkHelper()
        let resetBlock = { [unowned self] in
            self.mapView.clear()
        }
        b.runBenchmark(iterations: 1, actionCount: actionCount, actionBlock: actionBlock, resetBlock: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentSettings" {
            let settingsVC = segue.destination as! BenchmarkSettingsViewController
            settingsVC.settingsDelegate = self
        }
    }
    
    func settingsDidSave() {
        self.setupVariables()
    }

}
