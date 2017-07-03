//
//  ViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 6/26/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AGSGeoViewTouchDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var graphicsOverlay = AGSGraphicsOverlay()
    private var searchResults:Array = [String]()
    private var suggestResults:[AGSSuggestResult]!
    private var locatorTask = AGSLocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
    private var suggestRequestOperation:AGSCancelable!

    private var timer:Timer?
    
    private var mapCenterPoint = AGSPoint(x: -117.196, y: 34.057, spatialReference: AGSSpatialReference.wgs84())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearch()
        loadMap()
        addPointOnMap()
    }
    
    func configureSearch(){
        self.searchBar.delegate = self
        self.searchResultsTableView.delegate = self
        self.searchResultsTableView.dataSource = self
        self.searchResultsTableView.isHidden = true
    }
    
    
    
    //MARK: - Map related
    
    private func loadMap() {
        self.mapView.map = AGSMap(basemapType: .darkGrayCanvasVector, latitude: mapCenterPoint.y, longitude: mapCenterPoint.x, levelOfDetail: 1)
        self.mapView.graphicsOverlays.add(graphicsOverlay)
        self.mapView.touchDelegate = self
    }
    
    
    private func addPointOnMap() {
        addPointOnMap(mapCenterPoint)
    }
    

    private func addPointOnMap(_ point:AGSPoint, attributes:[String : Any]? = nil) {
        let symbol = AGSSimpleMarkerSymbol(style: .diamond, color: .red, size: 10)
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: attributes)
        self.graphicsOverlay.graphics.add(graphic)
    }
    
    
    private func addLineOnMap(startPoint:AGSPoint,endPoint:AGSPoint, isGeodesic:Bool=false) {
        //building line's geometry
        let polylineBuilder = AGSPolylineBuilder(spatialReference: AGSSpatialReference.wgs84())
        polylineBuilder.addPointWith(x: startPoint.x, y: startPoint.y)
        polylineBuilder.addPointWith(x: endPoint.x, y: endPoint.y)
        
        let geometry:AGSGeometry!
        
        if(isGeodesic) {
            geometry = AGSGeometryEngine.geodeticDensifyGeometry(polylineBuilder.toGeometry(), maxSegmentLength: 1000, lengthUnit: AGSLinearUnit(unitID: .kilometers)!, curveType: .geodesic)
        }
        else {
            geometry = polylineBuilder.toGeometry()
        }
        
        //what symbol to build line with
        let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.blue, width: 3)
        
        //actually building the line graphic
        let graphic = AGSGraphic(geometry: geometry, symbol: lineSymbol, attributes: nil)
        
        //adding line graphic to map
        self.graphicsOverlay.graphics.add(graphic)
    }
    
    
    
    //MARK: - Search Table UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if suggestResults != nil {
            return suggestResults.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell")!
        let suggestion = suggestResults[indexPath.row]
        cell.textLabel?.text = suggestion.label
        return cell
    }
    
    
    
    //MARK: - Search Table UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = self.suggestResults[indexPath.row]
        
        self.locatorTask.geocode(with: selectedSuggestion) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.searchResultsTableView.isHidden = true
                self.handleGeocodeResults(results)
            }
        }
        
    }
    
    
    
    //MARK: - Search bar delegate
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // called when text starts editing
        print("searchBarTextDidBeginEditing")
    }
    
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // called when text ends editing
        print("searchBarTextDidEndEditing")
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.fetchSuggestions), userInfo: searchText, repeats: false)
    }
    
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // called when keyboard search button pressed
        print("searchBarSearchButtonClicked")
    }

    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // called when cancel button pressed
        print("searchBarCancelButtonClicked")
        self.searchResultsTableView.isHidden = true
    }
    
    
    
    //MARK: - Geocoding related
    
    func fetchSuggestions() {
        
        guard let timer = self.timer else { return }
        let searchText = timer.userInfo as! String
        timer.invalidate()

        //cancel previous requests
        if self.suggestRequestOperation != nil {
            self.suggestRequestOperation.cancel()
        }
        
        // if no search string, no need to process
        if searchText.isEmpty {
            self.searchResultsTableView.isHidden = true
            return
        }
        
        //initialize suggest parameters
        let suggestParameters = AGSSuggestParameters()

        //get suggestions
        print("searching...")
        self.suggestRequestOperation = self.locatorTask.suggest(withSearchText: searchText, parameters: suggestParameters) { (result: [AGSSuggestResult]?, error: Error?) -> Void in
            if searchText == self.searchBar.text { //check if the search string has not changed in the meanwhile
                if let error = error {
                    print(error.localizedDescription)
                    self.searchResultsTableView.isHidden = true
                }
                else {
                    //update the suggest results and reload the table
                    self.suggestResults = result
                    self.searchResultsTableView.isHidden = false
                    self.searchResultsTableView.reloadData()
                }
            }
        }
    }
    
    func handleGeocodeResults(_ results:[AGSGeocodeResult]?) {
        guard let results = results  else { return }
        if(results.count == 0) { return }
        
        let result = results[0]
        let attributes = [
            "label" : result.label
        ]
        addPointOnMap(result.displayLocation!,attributes:attributes)
        addLineOnMap(startPoint: mapCenterPoint, endPoint: result.displayLocation!, isGeodesic: true)
    }
    
    
    
    //MARK: - AGSGeoViewTouchDelegate
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        //use the following method to identify graphics in a specific graphics overlay
        //otherwise if you need to identify on all the graphics overlay present in the map view
        //use `identifyGraphicsOverlaysAtScreenCoordinate:tolerance:maximumGraphics:completion:` method provided on map view
        let tolerance:Double = 12
        
        self.mapView.callout.dismiss()
        
        self.mapView.identify(self.graphicsOverlay, screenPoint: screenPoint, tolerance: tolerance, returnPopupsOnly: false, maximumResults: 10) { (result: AGSIdentifyGraphicsOverlayResult) -> Void in
            if let error = result.error {
                print("error while identifying :: \(error.localizedDescription)")
            }
            else {
                //if a graphics is found then show an alert
                if result.graphics.count > 0 {
                    if self.mapView.callout.isHidden {
                        self.mapView.callout.title = result.graphics[0].attributes["label"] as? String
                        self.mapView.callout.detail = "Location: " + String(format: "x: %.2f, y: %.2f", mapPoint.x, mapPoint.y)
                        self.mapView.callout.isAccessoryButtonHidden = true
                        self.mapView.callout.show(at: mapPoint, screenOffset: CGPoint.zero, rotateOffsetWithMap: false, animated: true)
                    }
                }
            }
        }
    }

    
}
