//
//  MapboxBenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/12/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import Mapbox

class MapboxBenchmarkViewController: UIViewController,BenchmarkSettingsDelegate {
    
    private let esriPoint = CLLocationCoordinate2D(latitude: 34.057, longitude: -117.196)
    private let redlandsPoint1 = CLLocationCoordinate2D(latitude: 34.0770623, longitude: -117.1805055)
    private let redlandsPoint2 = CLLocationCoordinate2D(latitude: 34.0483518, longitude: -117.2330623)
    
    private var bottomLeftPoint:CLLocationCoordinate2D!
    private var topRightPoint:CLLocationCoordinate2D!
    private var zoomLevel = 1.0
    
    private let quebecPoint = CLLocationCoordinate2D(latitude: 53.4647877, longitude: -77.388195)
    private let africaPoint = CLLocationCoordinate2D(latitude: 19.7968689, longitude: -0.5310485)
    private let ausPoint = CLLocationCoordinate2D(latitude: -21.182631, longitude: 121.5026582)
    
    //initializing benchmarking variables with defaults
    private var objectCount = 10000
    private var pointCount = 500
    private var objectKind = GraphicObjectKind.Point
    private var batchMode = false
    
    private var isCleared = true

    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var testDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVariables()
        self.setupTestDescriptionLabel()
        self.mapView.styleURL = URL(string: "mapbox://styles/mapbox/streets-v10")
        
        self.bottomLeftPoint = self.esriPoint
        self.topRightPoint = self.quebecPoint
        self.zoomLevel = 1.0
//        self.bottomLeftPoint = self.redlandsPoint1
//        self.topRightPoint = self.redlandsPoint2
//        self.zoomLevel = 12.0
        self.mapView.setCenter(esriPoint, zoomLevel: self.zoomLevel, animated: false)
    }
    
    func setupVariables() {
        self.objectCount = BenchmarkHelper.getObjectCount()
        self.pointCount = BenchmarkHelper.getPointCount()
        self.objectKind = BenchmarkHelper.getObjectKind()
        self.batchMode = BenchmarkHelper.getBatchMode()
    }
    
    
    func setupTestDescriptionLabel() {
        var str = "Testing \(self.objectCount) \(self.objectKind.description),"
        if self.objectKind != .Point {
            str += " each with \(self.pointCount) points,"
        }
        
        if(self.batchMode) {
            str += " in batch mode"
        }
        
        self.testDescriptionLabel.text = str
    }

    
    @IBAction func startTimeTestPressed(_ sender: Any) {
        
        switch self.objectKind {
        case .Point:
            self.batchMode ? self.testAddPointBatch() : self.testAddPoint()
        case .Polyline:
            self.batchMode ? self.testAddPolylineBatch() : self.testAddPolyline()
        case .Polygon:
            self.batchMode ? self.testAddPolygonBatch() : self.testAddPolygon()
        }
        
    }
    
    
    @IBAction func startFpsTestPressed(_ sender: Any) {
        
        switch self.objectKind {
        case .Point:
            self.testPointFPS()
        case .Polyline:
            self.testPolylineFPS()
        case .Polygon:
            self.testPolygonFPS()
        }
        
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        self.isCleared = true
        
        guard let annotations = self.mapView.annotations else {
            return
        }
        
        self.mapView.removeAnnotations(annotations)
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
        
        self.mapView.setCenter(point, zoomLevel: self.zoomLevel, direction: 0, animated: true) {
            self.oscillateViewpoints(toggle: !toggle)
        }
    }
    
    
    func testAddPoint() {
        self.testAddGraphic(withActionCount: self.objectCount, actionBlock: { [unowned self] in
            let graphic = MGLPointAnnotation()
            graphic.coordinate = self.esriPoint
            self.mapView.addAnnotation(graphic)
        })
    }
    
    func testAddPointBatch() {
        
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.objectCount)
        
        self.testAddGraphic(withActionCount: 1, actionBlock: { [unowned self] in
            var graphics = [MGLPointAnnotation]()
            for c in coordinates {
                let graphic = MGLPointAnnotation()
                graphic.coordinate = c
                graphics.append(graphic)
            }
            self.mapView.addAnnotations(graphics)
        })
    }
    
    func testAddPolyline() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
            self.mapView.addAnnotation(polyline)
        }
    }
    
    func testAddPolylineBatch() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [MGLPolyline]()
            for _ in 1...self.objectCount {
                let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
                graphics.append(polyline)
            }
            self.mapView.addAnnotations(graphics)
        }
    }
    
    func testAddPolygon() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polygon = MGLPolygon(coordinates: coordinates, count: UInt(coordinates.count))
            self.mapView.addAnnotation(polygon)
        }
    }
    
    func testAddPolygonBatch() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [MGLPolygon]()
            for _ in 1...self.objectCount {
                let polygon = MGLPolygon(coordinates: coordinates, count: UInt(coordinates.count))
                graphics.append(polygon)
            }
            self.mapView.addAnnotations(graphics)
        }
    }
    
    
    func testAddGraphic(withActionCount actionCount:Int, actionBlock:(()->())) {
        let b = BenchmarkHelper()
        let resetBlock = { [unowned self] in
            guard let annotations = self.mapView.annotations else {
                return
            }
            
            self.mapView.removeAnnotations(annotations)
        }
        b.runBenchmark(iterations: 1, actionCount: actionCount, actionBlock: actionBlock, resetBlock: nil)
    }
    
    
    //MARK: - Test FPS
    
    func testPointFPS() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.objectCount)
//                                                                                bottomLeftCoordinate: self.bottomLeftPoint,
//                                                                                topRightCoordinate: self.topRightPoint)
        var graphics = [MGLPointAnnotation]()
        for c in coordinates {
            let graphic = MGLPointAnnotation()
            graphic.coordinate = c
            graphics.append(graphic)
        }
        self.mapView.addAnnotations(graphics)
      
//        self.isCleared = false
//        self.oscillateViewpoints(toggle: true)
    }
    
    func testPolylineFPS() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
//                                                                                bottomLeftCoordinate: self.bottomLeftPoint,
//                                                                                topRightCoordinate: self.topRightPoint)
        var graphics = [MGLPolyline]()
        for _ in 1...self.objectCount {
            let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
            graphics.append(polyline)
        }
        self.mapView.addAnnotations(graphics)
        
        
//        self.isCleared = false
//        self.oscillateViewpoints(toggle: true)
    }
    
    func testPolygonFPS() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: self.pointCount)
//                                                                                bottomLeftCoordinate: self.bottomLeftPoint,
//                                                                                topRightCoordinate: self.topRightPoint)
        var graphics = [MGLPolygon]()
        for _ in 1...self.objectCount {
            let polyline = MGLPolygon(coordinates: coordinates, count: UInt(coordinates.count))
            graphics.append(polyline)
        }
        self.mapView.addAnnotations(graphics)
        
        
//        self.isCleared = false
//        self.oscillateViewpoints(toggle: true)
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
