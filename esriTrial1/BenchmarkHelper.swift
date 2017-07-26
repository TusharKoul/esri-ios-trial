//
//  BenchmarkHelper.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/12/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import Foundation

//for CACurrentMediaTime
import QuartzCore
import CoreLocation

class BenchmarkHelper {
 
    func runBenchmark(iterations:Int, actionCount:Int, actionBlock:() -> (), resetBlock:(() -> ())? ) {
        var iter = iterations
        var c = actionCount
        var observations = [CFTimeInterval]()
        while(iter > 0) {
            
            //measuring time for adding n objects
            let startTime = CACurrentMediaTime();
            while(c > 0) {
                actionBlock()
                c -= 1
            }
            let endTime = CACurrentMediaTime();
            
            //logging observations in array
            let time = endTime - startTime
            observations.append(time)
            
            //resetting experiment and setting up next iteration
            resetBlock?()
            iter -= 1
        }
//        print(observations)
        print(observations[0] * 1000.0)
//        print("Average time taken to do operation \(actionCount) times = \(averageOf(observations)), with sd = \(standardDeviationOf(observations))")
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
    
    class func generateRandomCoordinates(num:Int) -> [CLLocationCoordinate2D] {
        var points = [CLLocationCoordinate2D]()
        for _ in 1...num {
            points.append(generateRandomCoordinate())
        }
        return points
    }
    
    class func generateRandomCoordinate() -> CLLocationCoordinate2D{
        let latitude = self.randomNumberBetween(firstNum: -90.0, secondNum: 90.0)
        let longitude = self.randomNumberBetween(firstNum: -180.0, secondNum: 180.0)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    class func randomNumberBetween(firstNum: Double, secondNum: Double) -> Double{
        return Double(arc4random()) / Double(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    class func isFirstLaunch()->Bool{
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "isAppAlreadyLaunchedOnce"){
            return false
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return true
        }
    }

    
    class func setObjectCount(count:Int) {
        UserDefaults.standard.set(count, forKey: "Settings_ObjectCount")
    }
    
    class func getObjectCount() -> Int {
        return UserDefaults.standard.integer(forKey:"Settings_ObjectCount")
    }

    class func setObjectKind(kind:GraphicObjectKind) {
        UserDefaults.standard.set(kind.rawValue, forKey: "Settings_ObjectKind")
    }
    
    class func getObjectKind() -> GraphicObjectKind {
        return GraphicObjectKind(rawValue:UserDefaults.standard.integer(forKey: "Settings_ObjectKind"))!
    }
    
    class func setBatchMode(isBatchMode:Bool) {
        UserDefaults.standard.set(isBatchMode, forKey: "Settings_BatchMode")
    }
    
    class func getBatchMode() -> Bool {
        return UserDefaults.standard.bool(forKey:"Settings_BatchMode")
    }
    
    class func setRendererEnabled(isRendererEnabled:Bool) {
        UserDefaults.standard.set(isRendererEnabled, forKey: "Settings_RendererEnabled")
    }
    
    class func getRendererEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey:"Settings_RendererEnabled")
    }
    
    class func setRenderingMode(renderingModeVal:Int) {
        UserDefaults.standard.set(renderingModeVal, forKey: "Settings_RenderingMode")
    }
    
    class func getRenderingMode() -> Int {
        return UserDefaults.standard.integer(forKey: "Settings_RenderingMode")
    }
    
}
