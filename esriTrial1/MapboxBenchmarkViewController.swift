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
        mapView.setCenter(mapCenterPoint, zoomLevel: 0, animated: false)
    
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
//        self.testAddPoint()
//        self.testAddPointBatch()
//        self.testAddPolyline()
//        self.testAddPolylineBatch()
//        self.testAddPolygon()
        self.testAddPolygonBatch()
    }
    
    func testAddPoint() {
        self.testAddGraphic(withActionCount: 10000, actionBlock: { [unowned self] in
            let graphic = MGLPointAnnotation()
            graphic.coordinate = self.mapCenterPoint
            self.mapView.addAnnotation(graphic)
        })
    }
    
    func testAddPointBatch() {
        self.testAddGraphic(withActionCount: 1, actionBlock: { [unowned self] in
            var graphics = [MGLPointAnnotation]()
            for _ in 1...10000 {
                let graphic = MGLPointAnnotation()
                graphic.coordinate = self.mapCenterPoint
                graphics.append(graphic)
            }
            self.mapView.addAnnotations(graphics)
        })
    }
    
    func testAddPolyline() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        self.testAddGraphic(withActionCount: 10000) { [unowned self] in
            let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
            self.mapView.addAnnotation(polyline)
        }
    }
    
    func testAddPolylineBatch() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [MGLPolyline]()
            for _ in 1...10000 {
                let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
                graphics.append(polyline)
            }
            self.mapView.addAnnotations(graphics)
        }
    }
    
    func testAddPolygon() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        self.testAddGraphic(withActionCount: 10000) { [unowned self] in
            let polygon = MGLPolygon(coordinates: coordinates, count: UInt(coordinates.count))
            self.mapView.addAnnotation(polygon)
        }
    }
    
    func testAddPolygonBatch() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [MGLPolygon]()
            for _ in 1...10000 {
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
        b.runBenchmark(iterations: 10, actionCount: actionCount, actionBlock: actionBlock, resetBlock: resetBlock)
    }
    
}
