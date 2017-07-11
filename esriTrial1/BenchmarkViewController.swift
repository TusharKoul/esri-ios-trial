//
//  BenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class BenchmarkViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    
    private let mapCenterPoint = AGSPoint(x: -117.196, y: 34.057, spatialReference: AGSSpatialReference.wgs84())
    private let pointGraphicOverlay = AGSGraphicsOverlay()
    private let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.map = AGSMap(basemapType: .darkGrayCanvasVector, latitude: mapCenterPoint.y, longitude: mapCenterPoint.x, levelOfDetail: 1)
        self.mapView.graphicsOverlays.add(self.pointGraphicOverlay)

    }

    @IBAction func startTestPressed(_ sender: Any) {
        runBenchmark(iterations: 100, actionCount: 10000) { ()  in
            self.addGraphic()
        }
    }
    
    func addGraphic() {
        let graphic = AGSGraphic(geometry: self.mapCenterPoint, symbol: self.pointSymbol, attributes: nil)
        self.pointGraphicOverlay.graphics.add(graphic)
    }
    
    
    func averageOf(_ inputArray:[Double]) -> Double {
        let length = Double(inputArray.count)
        let avg = inputArray.reduce(0, {$0 + $1}) / length
        return avg
    }
    
    func standardDeviationOf(_ inputArray : [Double]) -> Double
    {
        let avg = averageOf(inputArray)
        let length = Double(inputArray.count)
        let sumOfSquaredAvgDiff = inputArray.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    func runBenchmark(iterations:Int, actionCount:Int, block:() -> Void) {
        var iter = iterations
        var c = actionCount
        var observations = [CFTimeInterval]()
        while(iter > 0) {
            
            //measuring time for adding n objects
            let startTime = CACurrentMediaTime();
            while(c > 0) {
                block()
                c -= 1
            }
            let endTime = CACurrentMediaTime();
            
            //logging observations in array
            let time = endTime - startTime
            observations.append(time)
            
            //clearing overlay and setting up next iteration
            self.pointGraphicOverlay.graphics.removeAllObjects()
            iter -= 1
        }
        
        print("Average time taken to do operation \(actionCount) times = \(averageOf(observations)), with sd = \(standardDeviationOf(observations))")

    }
}
