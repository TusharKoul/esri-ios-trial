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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.map = AGSMap(basemapType: .imagery, latitude: mapCenterPoint.y, longitude: mapCenterPoint.x, levelOfDetail: 1)
        self.mapView.graphicsOverlays.add(self.pointGraphicOverlay)

    }

    @IBAction func startTestPressed(_ sender: Any) {
        let b = Benchmarker()
        let actionBlock = {
            self.addGraphic()
        }
        let resetBlock = {
            self.pointGraphicOverlay.graphics.removeAllObjects()
        }
        b.runBenchmark(iterations: 100, actionCount: 10000, actionBlock: actionBlock, resetBlock: resetBlock)
    }
    
    func addGraphic() {
        let graphic = AGSGraphic(geometry: self.mapCenterPoint, symbol: self.pointSymbol, attributes: nil)
        self.pointGraphicOverlay.graphics.add(graphic)
    }
}
