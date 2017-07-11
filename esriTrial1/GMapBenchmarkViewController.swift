//
//  GMapBenchmarkViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/10/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit

import GoogleMaps

class GMapBenchmarkViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeGoogleMapApi()

        let camera = GMSCameraPosition.camera(withLatitude: 34.057, longitude: -117.196, zoom: 10.0)
        
        self.mapView.camera = camera
    }
    
    func initializeGoogleMapApi() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist"), let keys = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            GMSServices.provideAPIKey(keys["gmapApiKey"] as! String)
        }
    }
    
    @IBAction func startTestPressed(_ sender: Any) {
        runBenchmark(iterations: 100, actionCount: 10000) { ()  in
            self.addGraphic()
        }
    }

    func addGraphic() {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 34.057, longitude: -117.196)
        marker.map = self.mapView
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
            self.mapView.clear()
            iter -= 1
        }
        
        print("Average time taken to do operation \(actionCount) times = \(averageOf(observations)), with sd = \(standardDeviationOf(observations))")
    }
}
