//
//  BenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class EsriBenchmarkViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    
    private let mapCenterPoint = AGSPoint(x: -117.196, y: 34.057, spatialReference: AGSSpatialReference.wgs84())
    private let pointGraphicOverlay = AGSGraphicsOverlay()
    private let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10)
    
    private let lineGraphicOverlay = AGSGraphicsOverlay()
    private let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 1)
    
    private let polygonGraphicOverlay = AGSGraphicsOverlay()
    private let fillSymbol = AGSSimpleFillSymbol(style: .cross, color: .green, outline: nil)
    
    private let rendererEnabled = false
    private let renderingMode = AGSGraphicsRenderingMode.dynamic

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.map = AGSMap(basemapType: .streetsVector, latitude: mapCenterPoint.y, longitude: mapCenterPoint.x, levelOfDetail: 0)
        
        if(self.rendererEnabled) {
            self.pointGraphicOverlay.renderer = AGSSimpleRenderer(symbol: self.pointSymbol)
            self.pointGraphicOverlay.renderingMode = self.renderingMode
            
            self.lineGraphicOverlay.renderer = AGSSimpleRenderer(symbol: self.lineSymbol)
            self.lineGraphicOverlay.renderingMode = self.renderingMode
            
            self.polygonGraphicOverlay.renderer = AGSSimpleRenderer(symbol: self.fillSymbol)
            self.polygonGraphicOverlay.renderingMode = self.renderingMode
        }
        
//        self.mapView.graphicsOverlays.add(self.pointGraphicOverlay)
//        self.mapView.graphicsOverlays.add(self.lineGraphicOverlay)
        self.mapView.graphicsOverlays.add(self.polygonGraphicOverlay)
    }

    @IBAction func startTestPressed(_ sender: Any) {
//        self.testAddPoint()
//        self.testAddPointBatch()
//        self.testAddMultiPoint()
//        self.testAddMultiPointBuilder()
//        self.testAddPolyline()
//        self.testAddPolylineBatch()
//        self.testAddPolygon()
        self.testAddPolygonBatch()
    }
    
    func testAddPoint() {
        let symbol = self.rendererEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 10000) { [unowned self] in
            let graphic = AGSGraphic(geometry: self.mapCenterPoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPointBatch() {
        
        let symbol = self.rendererEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...10000 {
                let graphic = AGSGraphic(geometry: self.mapCenterPoint, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            self.pointGraphicOverlay.graphics.addObjects(from: graphics)
        }
    
//        EXCEPTION
//        for _ in 1...10 {
//            for _ in 1...10000 {
//                let graphic = AGSGraphic(geometry: self.mapCenterPoint, symbol: self.pointSymbol, attributes: nil)
//                graphics.append(graphic)
//            }
//            self.pointGraphicOverlay.graphics.addObjects(from: graphics)
//        }
    }
    
    func testAddMultiPointBuilder() {
        let symbol = self.rendererEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            let multipointBuilder = AGSMultipointBuilder(spatialReference: AGSSpatialReference.wgs84())
            for _ in 1...10000 {
                multipointBuilder.points.add(self.mapCenterPoint)
            }
            let graphic = AGSGraphic(geometry: multipointBuilder.toGeometry(), symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddMultiPoint() {
        let symbol = self.rendererEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var points = [AGSPoint]()
            for _ in 1...10000 {
                points.append(self.mapCenterPoint)
            }
            let multipoint = AGSMultipoint(points: points)
            let graphic = AGSGraphic(geometry: multipoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolyline() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        var points = [AGSPoint]()
        for c in coordinates {
           points.append(AGSPoint(clLocationCoordinate2D: c))
        }
        
        let symbol = self.rendererEnabled ? nil : self.lineSymbol
        self.testAddGraphic(withActionCount: 10000) { [unowned self] in
            let polyline = AGSPolyline(points: points)
            let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
            self.lineGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolylineBatch() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        var points = [AGSPoint]()
        for c in coordinates {
            points.append(AGSPoint(clLocationCoordinate2D: c))
        }
        
        let symbol = self.rendererEnabled ? nil : self.lineSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...10000 {
                let polyline = AGSPolyline(points: points)
                let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            
            self.lineGraphicOverlay.graphics.addObjects(from: graphics)
        }
    }
    
    func testAddPolygon() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        var points = [AGSPoint]()
        for c in coordinates {
            points.append(AGSPoint(clLocationCoordinate2D: c))
        }
        
        let symbol = self.rendererEnabled ? nil : self.fillSymbol
        self.testAddGraphic(withActionCount: 10000) { [unowned self] in
            let polygon = AGSPolygon(points: points)
            let graphic = AGSGraphic(geometry: polygon, symbol: symbol, attributes: nil)
            self.polygonGraphicOverlay.graphics.add(graphic)
        }
    }
    
    func testAddPolygonBatch() {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: 50)
        var points = [AGSPoint]()
        for c in coordinates {
            points.append(AGSPoint(clLocationCoordinate2D: c))
        }
        
        let symbol = self.rendererEnabled ? nil : self.fillSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...10000 {
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
        b.runBenchmark(iterations: 10, actionCount: actionCount, actionBlock: actionBlock, resetBlock: resetBlock)
    }
}
