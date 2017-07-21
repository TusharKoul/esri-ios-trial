//
//  EsriRoutingBenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/17/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class EsriRoutingBenchmarkViewController: UIViewController {
    @IBOutlet weak var mapView: AGSMapView!
    
    private var routeTask:AGSRouteTask!
    private var params:AGSRouteParameters!
    private var routeTaskOperation:AGSCancelable!
    private var routeGraphicsOverlay:AGSGraphicsOverlay!
    private var pointGraphicOverlay:AGSGraphicsOverlay!
    private let mapCenter = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: 32.7648951, longitude: -117.0778066))
    private var mapCenterStop:AGSStop!
    private var randomStops:[AGSStop]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMap()
        self.setupOverlays()
        self.setupRouting()
    }
    
    private func setupMap() {
        //using a tpk to create a local tiled layer
        //which will be visible in case of no network connection
        let path = Bundle.main.path(forResource: "streetmap_SD", ofType: "tpk")!
        let localTiledLayer = AGSArcGISTiledLayer(tileCache: AGSTileCache(fileURL: URL(fileURLWithPath: path)))
        
        //initialize the map using the local tiled layer as baselayer
        //assign the map to the map view
        self.mapView.map = AGSMap(basemap: AGSBasemap(baseLayer: localTiledLayer))
        self.mapView.setViewpointCenter(self.mapCenter, scale:2e4 ,completion: nil)
    }
    
    private func setupOverlays() {
        //creating overlay for routing
        self.routeGraphicsOverlay = AGSGraphicsOverlay()
        self.routeGraphicsOverlay.renderer = AGSSimpleRenderer(symbol: AGSSimpleLineSymbol(style: .solid, color: .yellow, width: 5))
        self.mapView.graphicsOverlays.add(self.routeGraphicsOverlay)
        
        //creating overlay for start and end points
        self.pointGraphicOverlay = AGSGraphicsOverlay()
        self.pointGraphicOverlay.renderer = AGSSimpleRenderer(symbol: AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10))
        self.mapView.graphicsOverlays.add(self.pointGraphicOverlay)
    }
    
    private func setupRouting() {
        //get the path for the geodatabase in the bundle
        let dbPath = Bundle.main.path(forResource: "sandiego", ofType: "geodatabase", inDirectory: "san-diego")!
        
        //initialize the route task using the path and the network name
        self.routeTask = AGSRouteTask(fileURLToDatabase: URL(fileURLWithPath: dbPath), networkName: "Streets_ND")
        
        //get default route parameters
        self.getDefaultParameters()
    }
    
    private func generateRandomStops() -> [AGSStop] {
        var res = [AGSStop]()
        let viewPoint = self.mapView.currentViewpoint(with: .boundingGeometry)
        let envelope = viewPoint?.targetGeometry.extent
        
        for _ in 1...10 {
            let pt = self.randomPointInEnvelope(envelope: envelope!)
            let stop = AGSStop(point: pt)
            res.append(stop)
        }
        
        return res
    }
    
    @IBAction func startPressed(_ sender: Any) {
        
        //cancel previous requests
        self.routeTaskOperation?.cancel()
        self.routeTaskOperation = nil
    
        self.mapCenterStop = AGSStop(point:mapCenter)
        self.randomStops = generateRandomStops()
        self.params.travelMode = self.routeTask.routeTaskInfo().travelModes[0]

        var observations = [CFTimeInterval]()
        
        for i in 0...10 {
            let stops:[AGSStop] = [self.mapCenterStop,self.randomStops[i]]
            
            //clear the previous stops
            self.params.clearStops()
            //add the new stops
            self.params.setStops(stops)
            
            
            let startTime = CACurrentMediaTime();
            self.routeTask.solveRoute(with: params) { [weak self] (routeResult:AGSRouteResult?, error:Error?) -> Void in
                observations.append(CACurrentMediaTime() - startTime)
//                if let error = error as NSError? , error.code != 3072 {
//                    //3072 is `User canceled error`
//                    print(error)
//                }
//                else {
//                    //handle the route result
//                    if let routeResult = routeResult {
//                        //show the resulting route on the map
//                        let generatedRoute = routeResult.routes[0]
//                        let routeGraphic = AGSGraphic(geometry: generatedRoute.routeGeometry, symbol: nil)
//                        self?.routeGraphicsOverlay.graphics.add(routeGraphic)
//                        //explore the array of AGSDirectionManeuvers to get turn ny turn directions
//                        let maneuvers = generatedRoute.directionManeuvers
//                        for maneuver in maneuvers {
//                            print(maneuver.directionText)
//                        }
//                    }
//                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { 
            print(observations)
        }
    }
    
    func randomPointInEnvelope(envelope : AGSEnvelope) -> AGSPoint {
        let xDomain: UInt32 = (UInt32)(envelope.xMax - envelope.xMin)
        var dx: Double = 0
        if (xDomain != 0) {
            let x: UInt32 = arc4random() % xDomain
            dx = envelope.xMin + Double(x)
        }
        
        let yDomain: UInt32 = (UInt32)(envelope.yMax - envelope.yMin)
        var dy: Double = 0
        if (yDomain != 0) {
            let y: UInt32 = arc4random() % xDomain
            dy = envelope.yMin + Double(y)
        }
        
        return AGSPoint(x: dx, y: dy, spatialReference: envelope.spatialReference)
    }
    
    private func getDefaultParameters() {
        //get the default parameters
        self.routeTask.defaultRouteParameters { [weak self] (params: AGSRouteParameters?, error: Error?) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self?.params = params
            }
        }
    }


    
}
