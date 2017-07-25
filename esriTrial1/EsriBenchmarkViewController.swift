//
//  BenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class EsriBenchmarkViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var objectCountTextField: UITextField!
    @IBOutlet weak var batchModeSwitch: UISwitch!
    @IBOutlet weak var graphicSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rendererSwitch: UISwitch!
    @IBOutlet weak var startButton: UIButton!
    
    private let mapCenterPoint = AGSPoint(x: -117.196, y: 34.057, spatialReference: AGSSpatialReference.wgs84())
    private let ausPoint = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: 19.7968689, longitude: -0.5310485))
    
    private let pointGraphicOverlay = AGSGraphicsOverlay()
    private let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10)
    
    private let lineGraphicOverlay = AGSGraphicsOverlay()
    private let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 1)
    
    private let polygonGraphicOverlay = AGSGraphicsOverlay()
    private let fillSymbol = AGSSimpleFillSymbol(style: .cross, color: .green, outline: nil)
    
    private let renderingMode = AGSGraphicsRenderingMode.dynamic

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.map = AGSMap(basemapType: .streetsVector, latitude: mapCenterPoint.y, longitude: mapCenterPoint.x, levelOfDetail: 3)
        self.startButton.isEnabled = false
        self.objectCountTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }


    @IBAction func graphicSegmentDidChange(_ sender: Any) {
        self.startButton.isEnabled = true
        
        switch self.graphicSegmentedControl.selectedSegmentIndex {
        case 0:
            self.setupGraphicOverlay(overlay: self.pointGraphicOverlay, symbol: self.pointSymbol)
        case 1:
            self.setupGraphicOverlay(overlay: self.lineGraphicOverlay, symbol: self.lineSymbol)
        case 2:
            self.setupGraphicOverlay(overlay: self.polygonGraphicOverlay, symbol: self.fillSymbol)
        default:
            self.setupGraphicOverlay(overlay: self.pointGraphicOverlay, symbol: self.pointSymbol)
        }
    }
    
    func setupGraphicOverlay(overlay:AGSGraphicsOverlay, symbol:AGSSymbol) {
        self.mapView.graphicsOverlays.removeAllObjects()
        
        if(self.rendererSwitch.isOn) {
            overlay.renderer = AGSSimpleRenderer(symbol: symbol)
            overlay.renderingMode = self.renderingMode
        }
        self.mapView.graphicsOverlays.add(overlay)
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
        
        switch self.graphicSegmentedControl.selectedSegmentIndex {
        case 0:
            self.batchModeSwitch.isOn ? self.testAddPointBatch() : self.testAddPoint()
        case 1:
            self.batchModeSwitch.isOn ? self.testAddPolylineBatch() : self.testAddPolyline()
        case 2:
            self.batchModeSwitch.isOn ? self.testAddPolygonBatch() : self.testAddPolygon()
        default:
            self.batchModeSwitch.isOn ? self.testAddPointBatch() : self.testAddPoint()
        }
        
        self.oscillateViewpoints(toggle: true)
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        self.pointGraphicOverlay.graphics.removeAllObjects()
        self.lineGraphicOverlay.graphics.removeAllObjects()
        self.polygonGraphicOverlay.graphics.removeAllObjects()
    }
    
    func testAddPoint() {
        let symbol = self.rendererSwitch.isOn ? nil : self.pointSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        self.testAddGraphic(withActionCount: objectCount) { [unowned self] in
            let graphic = AGSGraphic(geometry: self.mapCenterPoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPointBatch() {
        let symbol = self.rendererSwitch.isOn ? nil : self.pointSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        
        let points = self.generateRandomPoints(num: objectCount)
        
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for p in points {
                let graphic = AGSGraphic(geometry: p, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            self.pointGraphicOverlay.graphics.addObjects(from: graphics)
        }
        
//        self.goToViewPoint(points: points, index: 0)
    }
    
    func goToViewPoint(points:[AGSPoint],index:Int) {
        
        if index >= points.count {
            return;
        }
        
//        self.mapView.setViewpointCenter(points[index]) { (finished) in
//            let newIndex = index + 1
//            self.goToViewPoint(points: points, index: newIndex)
//        }
        let vp = AGSViewpoint(center: points[index], scale: 5000000)
        self.mapView.setViewpoint(vp, duration: 1) { (finished) in
            let newIndex = index + 1
            self.goToViewPoint(points: points, index: newIndex)
        }
    }
    
    func oscillateViewpoints(toggle:Bool) {
        var point:AGSPoint!
        
        if(toggle) {
            point = self.mapCenterPoint
        }
        else {
            point = self.ausPoint
        }
        
//        let vp = AGSViewpoint(center: point, scale: 5000000)
//        self.mapView.setViewpoint(vp, duration: 1) { (finished) in
//            self.oscillateViewpoints(toggle: !toggle)
//        }
        
        self.mapView.setViewpointCenter(point) { (finished) in
            self.oscillateViewpoints(toggle: !toggle)
        }
    }
    
    func testAddMultiPointBuilder() {
        let symbol = self.rendererSwitch.isOn ? nil : self.pointSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            let multipointBuilder = AGSMultipointBuilder(spatialReference: AGSSpatialReference.wgs84())
            for _ in 1...objectCount {
                multipointBuilder.points.add(self.mapCenterPoint)
            }
            let graphic = AGSGraphic(geometry: multipointBuilder.toGeometry(), symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddMultiPoint() {
        let symbol = self.rendererSwitch.isOn ? nil : self.pointSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var points = [AGSPoint]()
            for _ in 1...objectCount {
                points.append(self.mapCenterPoint)
            }
            let multipoint = AGSMultipoint(points: points)
            let graphic = AGSGraphic(geometry: multipoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolyline() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.rendererSwitch.isOn ? nil : self.lineSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        self.testAddGraphic(withActionCount: objectCount) { [unowned self] in
            let polyline = AGSPolyline(points: points)
            let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
            self.lineGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolylineBatch() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.rendererSwitch.isOn ? nil : self.lineSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...objectCount {
                let polyline = AGSPolyline(points: points)
                let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            
            self.lineGraphicOverlay.graphics.addObjects(from: graphics)
        }
        
//        self.goToViewPoint(points: points, index: 0)
    }
    
    func testAddPolygon() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.rendererSwitch.isOn ? nil : self.fillSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        self.testAddGraphic(withActionCount: objectCount) { [unowned self] in
            let polygon = AGSPolygon(points: points)
            let graphic = AGSGraphic(geometry: polygon, symbol: symbol, attributes: nil)
            self.polygonGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolygonBatch() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.rendererSwitch.isOn ? nil : self.fillSymbol
        let objectCount = Int(self.objectCountTextField.text!)!
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...objectCount {
                let polygon = AGSPolygon(points: points)
                let graphic = AGSGraphic(geometry: polygon, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            self.polygonGraphicOverlay.graphics.addObjects(from: graphics)
        }
    }

    
    
    func testAddGraphic(withActionCount actionCount:Int, actionBlock:(()->())) {
        let b = BenchmarkHelper()
        let resetBlock = { [unowned self] in
            self.pointGraphicOverlay.graphics.removeAllObjects()
            self.lineGraphicOverlay.graphics.removeAllObjects()
            self.polygonGraphicOverlay.graphics.removeAllObjects()
        }
        b.runBenchmark(iterations: 1, actionCount: actionCount, actionBlock: actionBlock, resetBlock: nil)
    }
    
    func generateRandomPoints(num:Int) -> [AGSPoint] {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: num)
        var points = [AGSPoint]()
        for c in coordinates {
            points.append(AGSPoint(clLocationCoordinate2D: c))
        }
        return points
    }
}
