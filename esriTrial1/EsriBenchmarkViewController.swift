//
//  BenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

enum BasemapType:Int {
    case ImageryRaster=0
    case StreetVector
    case NavigationVector
    case Topographic
    case LightGrayCanvas
    
    var url:URL {
        switch self {
        case .ImageryRaster:
            return URL(string: "https://www.arcgis.com/home/webmap/viewer.html?webmap=86de95d4e0244cba80f0fa2c9403a7b2")!
            
        case .Topographic:
            return URL(string: "http://www.arcgis.com/home/webmap/viewer.html?webmap=67372ff42cd145319639a99152b15bc3")!
            
        case .LightGrayCanvas:
            return URL(string: "http://www.arcgis.com/home/webmap/viewer.html?webmap=979c6cc89af9449cbeb5342a439c6a76")!
            
        case .StreetVector:
            return URL(string:"https://www.arcgis.com/home/webmap/viewer.html?webmap=55ebf90799fa4a3fa57562700a68c405")!
            
        case .NavigationVector:
            return URL(string:"https://www.arcgis.com/home/webmap/viewer.html?webmap=c50de463235e4161b206d000587af18b")!
        }
    }
    
    var description:String {
        switch self {
        case .ImageryRaster: return "Imagery"
        case .Topographic: return "Topographic"
        case .LightGrayCanvas: return "Light gray canvas"
        case .StreetVector: return "Street vector"
        case .NavigationVector: return "Navigation vector"
        }
    }
}

class EsriBenchmarkViewController: UIViewController,BenchmarkSettingsDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var testDescriptionLabel: UILabel!
    
    private let esriPoint = AGSPoint(x: -117.196, y: 34.057, spatialReference: AGSSpatialReference.wgs84())
    private let redlandsPoint1 = AGSPoint(x: -117.1805055, y: 34.0770623, spatialReference: AGSSpatialReference.wgs84())
    private let redlandsPoint2 = AGSPoint(x: -117.2330623, y: 34.0483518, spatialReference: AGSSpatialReference.wgs84())
    
    private var bottomLeftPoint:AGSPoint!
    private var topRightPoint:AGSPoint!
    
    private let quebecPoint = AGSPoint(x: -77.388195, y: 53.4647877, spatialReference: AGSSpatialReference.wgs84())
    private let ausPoint = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: 19.7968689, longitude: -0.5310485))
    
    private var pointGraphicOverlays = [AGSGraphicsOverlay]()
    private let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10)
    
    private var lineGraphicOverlays = [AGSGraphicsOverlay]()
    private let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 1)
    
    private var polygonGraphicOverlays = [AGSGraphicsOverlay]()
    private let fillSymbol = AGSSimpleFillSymbol(style: .solid, color: .green, outline: nil)
    
    
    //initializing benchmarking variables with defaults
    private var objectCount = 10000
    private var pointCount = 500
    private var objectKind = GraphicObjectKind.Point
    private var batchMode = false
    private var renderingEnabled = false
    private var renderingMode = AGSGraphicsRenderingMode.dynamic
    private var layerCount = 1
    private var basemapType:BasemapType!
    private var zoomLevel:MapZoomLevel = .CountryLevel
    
    private var isCleared = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupVariables()
        self.setupMap()
        self.setupGraphicOverlays()
        self.setupTestDescriptionLabel()
    }
    
    func setupMap() {
        
        self.mapView.map = AGSMap(url: self.basemapType.url)
        
        if self.zoomLevel == .CityLevel {
            self.bottomLeftPoint = redlandsPoint1
            self.topRightPoint = redlandsPoint2
            //self.mapView.map = AGSMap(basemapType: .streetsVector, latitude: esriPoint.y, longitude: esriPoint.x, levelOfDetail: 13)
            self.mapView.setViewpoint(AGSViewpoint(latitude: esriPoint.y, longitude: esriPoint.x, scale: 72223.819286))
        }
        else {
            self.bottomLeftPoint = self.esriPoint
            self.topRightPoint = self.quebecPoint
            //self.mapView.map = AGSMap(basemapType: .streetsVector, latitude: esriPoint.y, longitude: esriPoint.x, levelOfDetail: 2)
            self.mapView.setViewpoint(AGSViewpoint(latitude: esriPoint.y, longitude: esriPoint.x, scale: 147914381.897889))
        }
    }
    
    
    func setupVariables() {
        self.objectCount = BenchmarkHelper.getObjectCount()
        self.pointCount = BenchmarkHelper.getPointCount()
        self.objectKind = BenchmarkHelper.getObjectKind()
        self.batchMode = BenchmarkHelper.getBatchMode()
        self.renderingEnabled = BenchmarkHelper.getRendererEnabled()
        self.renderingMode = AGSGraphicsRenderingMode(rawValue: BenchmarkHelper.getRenderingMode())!
        self.layerCount = BenchmarkHelper.getOverlayCount()
        self.basemapType = BenchmarkHelper.getBasemapType()
        self.zoomLevel = BenchmarkHelper.getZoomLevel()
    }
    
    
    func setupGraphicOverlays() {
        self.mapView.graphicsOverlays.removeAllObjects()
        
        switch self.objectKind {
            
        case .Point:
            self.pointGraphicOverlays = self.createGraphicOverlays(count: self.layerCount, symbol: self.pointSymbol)
            
        case .Polyline:
            self.lineGraphicOverlays = self.createGraphicOverlays(count: self.layerCount, symbol: self.lineSymbol)

        case .Polygon:
            self.polygonGraphicOverlays = self.createGraphicOverlays(count: self.layerCount, symbol: self.fillSymbol)
        }
    }
    
    func createGraphicOverlays(count:Int, symbol:AGSSymbol) -> [AGSGraphicsOverlay]{
        var overlayGroup = [AGSGraphicsOverlay]()
        for _ in 1...count {
            let overlay = AGSGraphicsOverlay()
            overlayGroup.append(overlay)
            self.setupGraphicOverlay(overlay: overlay, symbol: symbol)
        }
        return overlayGroup
    }
    
    func setupGraphicOverlay(overlay:AGSGraphicsOverlay, symbol:AGSSymbol) {
        if(self.renderingEnabled) {
            overlay.renderer = AGSSimpleRenderer(symbol: symbol)
            overlay.renderingMode = self.renderingMode
        }
        self.mapView.graphicsOverlays.add(overlay)
    }
    
    func setupTestDescriptionLabel() {
        var str = "Testing \(self.objectCount) \(self.objectKind.description),"
        if self.objectKind != .Point {
            str += " each with \(self.pointCount) points,"
        }
        str += " on \(self.layerCount) layers,"
        if(self.renderingEnabled) {
            switch self.renderingMode {
            case .dynamic:
                str += " with dynamic rendering"
            case .static:
                str += " with static rendering"
            }
        }
        else {
            str += " without renderer"
        }
        
        if(self.batchMode) {
            str += " in batch mode"
        }
        
        str += " on \(self.basemapType.description) map"
        
        self.testDescriptionLabel.text = str
        
    }
    
    
    @IBAction func startTimeTestPressed() {
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
            self.testFPSPoint()
        case .Polyline:
            self.testFPSPolyline()
        case .Polygon:
            self.testFPSPolygon()
        }
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        self.isCleared = true
        
        for overlay in self.mapView.graphicsOverlays {
            let overlay = overlay as! AGSGraphicsOverlay
            overlay.graphics.removeAllObjects()
        }
    }
    
    func testAddPoint() {
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let graphic = AGSGraphic(geometry: self.esriPoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlays[0].graphics.add(graphic)
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
            self.pointGraphicOverlays[0].graphics.addObjects(from: graphics)
        }
    }
    
    
    func oscillateViewpoints(toggle:Bool) {
        if self.isCleared {
            return
        }
        
        var point:AGSPoint!
        if(toggle) {
            point = self.topRightPoint
        }
        else {
            point = self.bottomLeftPoint
        }
        
        self.mapView.setViewpointCenter(point) { (finished) in
            self.oscillateViewpoints(toggle: !toggle)
        }
    }
    
    func testAddMultiPointBuilder() {
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            let multipointBuilder = AGSMultipointBuilder(spatialReference: AGSSpatialReference.wgs84())
            for _ in 1...self.objectCount {
                multipointBuilder.points.add(self.esriPoint)
            }
            let graphic = AGSGraphic(geometry: multipointBuilder.toGeometry(), symbol: symbol, attributes: nil)
            self.pointGraphicOverlays[0].graphics.add(graphic)
        }
    }
    
    func testAddMultiPoint() {
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var points = [AGSPoint]()
            for _ in 1...self.objectCount {
                points.append(self.esriPoint)
            }
            let multipoint = AGSMultipoint(points: points)
            let graphic = AGSGraphic(geometry: multipoint, symbol: symbol, attributes: nil)
            self.pointGraphicOverlays[0].graphics.add(graphic)
        }
    }
    
    func testAddPolyline() {
        let points = self.generateRandomPoints(num: self.pointCount)
        
        let symbol = self.renderingEnabled ? nil : self.lineSymbol
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polyline = AGSPolyline(points: points)
            let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
            self.lineGraphicOverlays[0].graphics.add(graphic)
        }
    }
    
    func testAddPolylineBatch() {
        let points = self.generateRandomPoints(num: self.pointCount)
        
        let symbol = self.renderingEnabled ? nil : self.lineSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...self.objectCount {
                let polyline = AGSPolyline(points: points)
                let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            
            self.lineGraphicOverlays[0].graphics.addObjects(from: graphics)
        }
    }
    
    func testAddPolygon() {
        let points = self.generateRandomPoints(num: self.pointCount)
        
        let symbol = self.renderingEnabled ? nil : self.fillSymbol
        self.testAddGraphic(withActionCount: self.objectCount) { [unowned self] in
            let polygon = AGSPolygon(points: points)
            let graphic = AGSGraphic(geometry: polygon, symbol: symbol, attributes: nil)
            self.polygonGraphicOverlays[0].graphics.add(graphic)
        }
    }
    
    func testAddPolygonBatch() {
        let points = self.generateRandomPoints(num: self.pointCount)
        
        let symbol = self.renderingEnabled ? nil : self.fillSymbol
        self.testAddGraphic(withActionCount: 1) { [unowned self] in
            var graphics = [AGSGraphic]()
            for _ in 1...self.objectCount {
                let polygon = AGSPolygon(points: points)
                let graphic = AGSGraphic(geometry: polygon, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            self.polygonGraphicOverlays[0].graphics.addObjects(from: graphics)
        }
    }

    
    func testAddGraphic(withActionCount actionCount:Int, actionBlock:(()->())) {
        let b = BenchmarkHelper()
        let resetBlock = { [unowned self] in
            for overlay in self.mapView.graphicsOverlays {
                let overlay = overlay as! AGSGraphicsOverlay
                overlay.graphics.removeAllObjects()
            }
        }
        b.runBenchmark(iterations: 1, actionCount: actionCount, actionBlock: actionBlock, resetBlock: nil)
    }
    
    
    //MARK: - Test FPS
    
    func testFPSPoint() {
        let objectsPerLayer = self.objectCount / self.layerCount
        
        let symbol = self.renderingEnabled ? nil : self.pointSymbol
        
        for overlay in self.pointGraphicOverlays {
            if objectsPerLayer <= 0 { break }
            let points = self.generateRandomPointsBetweenBounds(num: objectsPerLayer,
                                                                bottomLeftCoordinate: self.bottomLeftPoint.toCLLocationCoordinate2D(),
                                                                topRightCoordinate: self.topRightPoint.toCLLocationCoordinate2D())
            
            var graphics = [AGSGraphic]()
            for p in points {
                let graphic = AGSGraphic(geometry: p, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            overlay.graphics.addObjects(from: graphics)
        }
        
        
        self.isCleared = false
        self.oscillateViewpoints(toggle: true)
    }
    
    
    func testFPSPolyline() {
        let objectsPerLayer = self.objectCount / self.layerCount
        let points = self.generateRandomPointsBetweenBounds(num: self.pointCount,
                                                            bottomLeftCoordinate: self.bottomLeftPoint.toCLLocationCoordinate2D(),
                                                            topRightCoordinate: self.topRightPoint.toCLLocationCoordinate2D())
        
        let symbol = self.renderingEnabled ? nil : self.lineSymbol
        
        for overlay in self.lineGraphicOverlays {
            if objectsPerLayer <= 0 { break }
            var graphics = [AGSGraphic]()
            for _ in 1...objectsPerLayer {
                let polyline = AGSPolyline(points: points)
                let graphic = AGSGraphic(geometry: polyline, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            overlay.graphics.addObjects(from: graphics)
        }
        
        self.isCleared = false
        self.oscillateViewpoints(toggle: true)
    }
    
    
    func testFPSPolygon() {
        let objectsPerLayer = self.objectCount / self.layerCount
        let points = self.generateRandomPointsBetweenBounds(num: self.pointCount,
                                                            bottomLeftCoordinate: self.bottomLeftPoint.toCLLocationCoordinate2D(),
                                                            topRightCoordinate: self.topRightPoint.toCLLocationCoordinate2D())
        
        let symbol = self.renderingEnabled ? nil : self.fillSymbol
        
        for overlay in self.polygonGraphicOverlays {
            if objectsPerLayer <= 0 { break }
            var graphics = [AGSGraphic]()
            for _ in 1...objectsPerLayer {
                let polygon = AGSPolygon(points: points)
                let graphic = AGSGraphic(geometry: polygon, symbol: symbol, attributes: nil)
                graphics.append(graphic)
            }
            overlay.graphics.addObjects(from: graphics)
        }
        
        self.isCleared = false
        self.oscillateViewpoints(toggle: true)
    }
    
    
    func generateRandomPoints(num:Int) -> [AGSPoint] {
        let coordinates = BenchmarkHelper.generateRandomCoordinates(num: num)
        var points = [AGSPoint]()
        for c in coordinates {
            points.append(AGSPoint(clLocationCoordinate2D: c))
        }
        return points
    }
    
    func generateRandomPointsBetweenBounds(num:Int, bottomLeftCoordinate:CLLocationCoordinate2D, topRightCoordinate:CLLocationCoordinate2D) -> [AGSPoint] {
        let coordinates = BenchmarkHelper.generateRandomCoordinatesWithinBounds(num: num,
                                                                                bottomLeftCoordinate: bottomLeftCoordinate,
                                                                                topRightCoordinate: topRightCoordinate)
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
        self.setupMap()
        self.setupGraphicOverlays()
        self.setupTestDescriptionLabel()
    }
}
