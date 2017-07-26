//
//  BenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class EsriBenchmarkViewController: UIViewController,BenchmarkSettingsDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    
    private let mapCenterPoint = AGSPoint(x: -117.196, y: 34.057, spatialReference: AGSSpatialReference.wgs84())
    private let ausPoint = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: 19.7968689, longitude: -0.5310485))
    
    private let pointGraphicOverlay = AGSGraphicsOverlay()
    private let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10)
    
    private let lineGraphicOverlay = AGSGraphicsOverlay()
    private let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 1)
    
    private let polygonGraphicOverlay = AGSGraphicsOverlay()
    private let fillSymbol = AGSSimpleFillSymbol(style: .cross, color: .green, outline: nil)

    
    //initializing benchmarking variables with defaults
    private var objectCount = 10000
    private var objectKind = GraphicObjectKind.Point
    private var batchMode = false
    private var renderingEnabled = false
    private var renderingMode = AGSGraphicsRenderingMode.dynamic
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.map = AGSMap(basemapType: .streetsVector, latitude: mapCenterPoint.y, longitude: mapCenterPoint.x, levelOfDetail: 3)
        self.setupVariables()
        self.setupGraphicOverlays()
    }
    
    func setupVariables() {
        self.objectCount = BenchmarkHelper.getObjectCount()
        self.objectKind = BenchmarkHelper.getObjectKind()
        self.batchMode = BenchmarkHelper.getBatchMode()
        self.renderingEnabled = BenchmarkHelper.getRendererEnabled()
        self.renderingMode = AGSGraphicsRenderingMode(rawValue: BenchmarkHelper.getRenderingMode())!
    }
    
    func setupGraphicOverlays() {
        
        switch self.objectKind {
        case .Point:
            self.setupGraphicOverlay(overlay: self.pointGraphicOverlay, symbol: self.pointSymbol)
        case .Polyline:
            self.setupGraphicOverlay(overlay: self.lineGraphicOverlay, symbol: self.lineSymbol)
        case .Polygon:
            self.setupGraphicOverlay(overlay: self.polygonGraphicOverlay, symbol: self.fillSymbol)
        }
    }
    
    func setupGraphicOverlay(overlay:AGSGraphicsOverlay, symbol:AGSSymbol) {
        self.mapView.graphicsOverlays.removeAllObjects()
        
        if(self.renderingEnabled) {
            overlay.renderer = AGSSimpleRenderer(symbol: symbol)
            overlay.renderingMode = self.renderingMode
        }
        self.mapView.graphicsOverlays.add(overlay)
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
        
        switch self.objectKind {
        case .Point:
            self.batchMode ? self.testAddPointBatch() : self.testAddPoint()
        case .Polyline:
            self.batchMode ? self.testAddPolylineBatch() : self.testAddPolyline()
        case .Polygon:
            self.batchMode ? self.testAddPolygonBatch() : self.testAddPolygon()
        }
        
//        self.oscillateViewpoints(toggle: true)
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        self.pointGraphicOverlay.graphics.removeAllObjects()
        self.lineGraphicOverlay.graphics.removeAllObjects()
        self.polygonGraphicOverlay.graphics.removeAllObjects()
    }
    
    func testAddPoint() {
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let graphic = AGSGraphic(geometry: self.mapCenterPoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPointBatch() {
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        let points = self.generateRandomPoints(num: self.objectCount)
        
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for p in points {
                let graphic = AGSGraphic(geometry: p, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            self.pointGraphicOverlay.graphics.addObjects(from: graphics)
        }
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
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            let multipointBuilder = AGSMultipointBuilder(spatialReference: AGSSpatialReference.wgs84())
            for _ in 1...self.objectCount {
                multipointBuilder.points.add(self.mapCenterPoint)
            }
            let graphic = AGSGraphic(geometry: multipointBuilder.toGeometry(), symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddMultiPoint() {
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var points = [AGSPoint]()
            for _ in 1...self.objectCount {
                points.append(self.mapCenterPoint)
            }
            let multipoint = AGSMultipoint(points: points)
            let graphic = AGSGraphic(geometry: multipoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolyline() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.renderingEnabled ? nil : self.lineSymbol
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polyline = AGSPolyline(points: points)
            let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
            self.lineGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolylineBatch() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.renderingEnabled ? nil : self.lineSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...self.objectCount {
                let polyline = AGSPolyline(points: points)
                let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            
            self.lineGraphicOverlay.graphics.addObjects(from: graphics)
        }
    }
    
    func testAddPolygon() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.renderingEnabled ? nil : self.fillSymbol
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polygon = AGSPolygon(points: points)
            let graphic = AGSGraphic(geometry: polygon, symbol: symbol, attributes: nil)
            self.polygonGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolygonBatch() {
        let points = self.generateRandomPoints(num: 50)
        
        let symbol = self.renderingEnabled ? nil : self.fillSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...self.objectCount {
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentSettings" {
            let settingsVC = segue.destination as! BenchmarkSettingsViewController
            settingsVC.settingsDelegate = self
        }
    }
    
    func settingsDidSave() {
        self.setupVariables()
        self.setupGraphicOverlays()
    }
}
