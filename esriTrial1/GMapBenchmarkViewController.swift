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
    @IBOutlet weak var testDescriptionLabel: UILabel!
    
    private let esriPoint = CLLocationCoordinate2D(latitude: 34.057, longitude: -117.196)
    private let redlandsPoint1 = CLLocationCoordinate2D(latitude: 34.0770623, longitude: -117.1805055)
    private let redlandsPoint2 = CLLocationCoordinate2D(latitude: 34.0483518, longitude: -117.2330623)
    
    private var bottomLeftPoint:CLLocationCoordinate2D!
    private var topRightPoint:CLLocationCoordinate2D!
    
    private let quebecPoint = CLLocationCoordinate2D(latitude: 53.4647877, longitude: -77.388195)
    private let africaPoint = CLLocationCoordinate2D(latitude: 19.7968689, longitude: -0.5310485)
    private let ausPoint = CLLocationCoordinate2D(latitude: -21.182631, longitude: 121.5026582)
    
    //initializing benchmarking variables with defaults
    private var objectCount = 10000
    private var pointCount = 500
    private var objectKind = GraphicObjectKind.Point
    
    private var isCleared = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupVariables()
        self.setupTestDescriptionLabel()
        
        self.bottomLeftPoint = self.esriPoint
        self.topRightPoint = self.quebecPoint
        let camera = GMSCameraPosition.camera(withLatitude: esriPoint.latitude, longitude: esriPoint.longitude, zoom: 2)
//        self.bottomLeftPoint = self.redlandsPoint1
//        self.topRightPoint = self.redlandsPoint2
//        let camera = GMSCameraPosition.camera(withLatitude: esriPoint.latitude, longitude: esriPoint.longitude, zoom: 13)
        
        self.mapView.camera = camera
        
    }
    
    func setupVariables() {
        self.objectCount = BenchmarkHelper.getObjectCount()
        self.pointCount = BenchmarkHelper.getPointCount()
        self.objectKind = BenchmarkHelper.getObjectKind()
    }
    
    
    func setupTestDescriptionLabel() {
        var str = "Testing \(self.objectCount) \(self.objectKind.description),"
        if self.objectKind != .Point {
            str += " each with \(self.pointCount) points,"
        }
        self.testDescriptionLabel.text = str
    }

    
    @IBAction func startTimeTestPressed() {
        switch self.objectKind {
        case .Point:
            self.testAddPoint()
        case .Polyline:
            self.testAddPolyline()
        case .Polygon:
            self.testAddPolygon()
        }
    }
    
    @IBAction func startFpsTestPressed(_ sender: Any) {
        switch self.objectKind {
        case .Point:
            self.testPointFPS()
        case .Polyline:
            self.testPolylineFPS()
        case .Polygon:
            self.testPolylgonFPS()
        }
    }
    
    
    @IBAction func clearPressed(_ sender: Any) {
        self.isCleared = true
        self.mapView.clear()
    }
    
    
    func oscillateViewpoints(toggle:Bool) {
        if self.isCleared {
            return
        }
        
        var point:CLLocationCoordinate2D
        if(toggle) {
            point = self.bottomLeftPoint
        }
        else {
            point = self.topRightPoint
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
            marker.position = self.esriPoint
            marker.map = self.mapView
        })
    }

    func testAddPolyline() {
        let path = GMSMutablePath()
        
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
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
        
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
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
    
    
    //MARK: - Testing FPS
    
    func testPointFPS() {
        let coordinates = BenchmarkHelper.generateRandomCoordinatesWithinBounds(num: self.objectCount,
                                                                           bottomLeftCoordinate: self.bottomLeftPoint,
                                                                           topRightCoordinate: self.topRightPoint)
        for c in coordinates {
            let marker = GMSMarker()
            marker.position = c
            marker.map = self.mapView
        }
        
        self.isCleared = false
        self.oscillateViewpoints(toggle: true)
    }
    
    func testPolylineFPS() {
        let path = self.getRandomPathWithinBounds(num: self.pointCount,
                                                  bottomLeftCoordinate: self.bottomLeftPoint,
                                                  topRightCoordinate: self.topRightPoint)
        for _ in 1...self.objectCount {
            let polygon = GMSPolyline(path: path)
            polygon.map = self.mapView
        }
        
        self.isCleared = false
        self.oscillateViewpoints(toggle: true)
    }
    
    func testPolylgonFPS() {
        let path = self.getRandomPathWithinBounds(num: self.pointCount,
                                                  bottomLeftCoordinate: self.bottomLeftPoint,
                                                  topRightCoordinate: self.topRightPoint)
        for _ in 1...self.objectCount {
            let polygon = GMSPolygon(path: path)
            polygon.map = self.mapView
        }
        
        self.isCleared = false
        self.oscillateViewpoints(toggle: true)
    }
    
    
    func getRandomPath(num:Int) -> GMSPath {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: num)
        let path = GMSMutablePath()
        for c in coordinates {
            path.add(c)
        }
        return path
    }
    
    func getRandomPathWithinBounds(num:Int, bottomLeftCoordinate:CLLocationCoordinate2D, topRightCoordinate:CLLocationCoordinate2D) -> GMSPath {
        let coordinates = BenchmarkHelper.generateRandomCoordinatesWithinBounds(num: num,
                                                                                bottomLeftCoordinate: bottomLeftCoordinate,
                                                                                topRightCoordinate: topRightCoordinate)
        let path = GMSMutablePath()
        for c in coordinates {
            path.add(c)
        }
        return path
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentSettings" {
            let settingsVC = segue.destination as! BenchmarkSettingsViewController
            settingsVC.settingsDelegate = self
        }
    }
    
    func settingsDidSave() {
        self.setupVariables()
        self.setupTestDescriptionLabel()
    }

}
