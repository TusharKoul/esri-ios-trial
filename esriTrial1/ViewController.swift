//
//  ViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 6/26/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

import RealmSwift
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AGSGeoViewTouchDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var pointGraphicOverlay = AGSGraphicsOverlay()
    private var lineGraphicOverlay = AGSGraphicsOverlay()
    
    private var searchResults:Array = [String]()
    private var suggestResults:[AGSSuggestResult]!
    private var locatorTask = AGSLocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
    private var suggestRequestOperation:AGSCancelable!

    private var timer:Timer?
    
    private var mapCenterPoint = AGSPoint(x: -117.196, y: 34.057, spatialReference: AGSSpatialReference.wgs84())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearch()
        configureMap()
        loadAllPlacesOnMap()
    }
    
    func configureSearch(){
        self.searchBar.delegate = self
        self.searchResultsTableView.delegate = self
        self.searchResultsTableView.dataSource = self
        self.searchResultsTableView.isHidden = true
    }
    
    
    
    //MARK: - Map related
    
    private func configureMap() {
        self.mapView.map = AGSMap(basemapType: .darkGrayCanvasVector, latitude: mapCenterPoint.y, longitude: mapCenterPoint.x, levelOfDetail: 1)
        self.mapView.graphicsOverlays.add(pointGraphicOverlay)
        self.mapView.graphicsOverlays.add(lineGraphicOverlay)
        self.mapView.touchDelegate = self
    }
    
    private func loadAllPlacesOnMap() {
        let places = getAllPlaces()
        for place in places {
            self.addPlaceOnMap(place)
        }
    }
    
    private func addPlaceOnMap(_ place:Place) {
        var symbol:AGSSimpleMarkerSymbol!
        if place.isVisited {
            symbol = AGSSimpleMarkerSymbol(style: .diamond, color: .green, size: 10)
        }
        else if place.isWishlist {
            symbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10)
        }
        let graphic = AGSGraphic()
        graphic.geometry = place.location
        graphic.symbol = symbol
        graphic.attributes["place"] = place
        
        self.pointGraphicOverlay.graphics.add(graphic)
    }
    
    
    private func addLineOnMap(startPoint:AGSPoint,endPoint:AGSPoint, isGeodesic:Bool=false) {
        //building line's geometry
        let polylineBuilder = AGSPolylineBuilder(spatialReference: AGSSpatialReference.wgs84())
        polylineBuilder.addPointWith(x: startPoint.x, y: startPoint.y)
        polylineBuilder.addPointWith(x: endPoint.x, y: endPoint.y)
        
        let geometry:AGSGeometry!
        
        if(isGeodesic) {
            geometry = AGSGeometryEngine.geodeticDensifyGeometry(polylineBuilder.toGeometry(), maxSegmentLength: 100, lengthUnit: AGSLinearUnit(unitID: .kilometers)!, curveType: .geodesic)
        }
        else {
            geometry = polylineBuilder.toGeometry()
        }
        
        //what symbol to build line with
        let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.blue, width: 3)
        
        //actually building the line graphic
        let graphic = AGSGraphic(geometry: geometry, symbol: lineSymbol, attributes: nil)
        
        //adding line graphic to map
        self.lineGraphicOverlay.graphics.add(graphic)
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
        self.geocodeSuggestion(selectedSuggestion)
    }
    
    
    
    //MARK: - Search bar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.fetchSuggestions), userInfo: searchText, repeats: false)
    }
    
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
    
    
    func geocodeSuggestion(_ selectedSuggestion:AGSSuggestResult) {
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
    
    
    func handleGeocodeResults(_ results:[AGSGeocodeResult]?) {
        guard let results = results  else { return }
        if(results.count == 0) { return }
        
        let result = results[0]
        
        //center the map at the place chosen, then show callout on completion
        self.mapView.setViewpointCenter(result.displayLocation!) { (finished) in
            self.showCallout(mapPoint: result.displayLocation!,labelText: result.label)
        }
        
    }
    
    
    
    //MARK: - AGSGeoViewTouchDelegate
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        //use the following method to identify graphics in a specific graphics overlay
        //otherwise if you need to identify on all the graphics overlay present in the map view
        //use `identifyGraphicsOverlaysAtScreenCoordinate:tolerance:maximumGraphics:completion:` method provided on map view
        let tolerance:Double = 12
        
        self.mapView.callout.dismiss()
        
        self.mapView.identify(self.pointGraphicOverlay, screenPoint: screenPoint, tolerance: tolerance, returnPopupsOnly: false, maximumResults: 10) { (result: AGSIdentifyGraphicsOverlayResult) -> Void in
            if let error = result.error {
                print("error while identifying :: \(error.localizedDescription)")
            }
            else {
                //if a graphics is found, and its of type "point", then show an alert
                for x in result.graphics {
                    if x.geometry?.geometryType == AGSGeometryType.point {
                        let place = result.graphics[0].attributes["place"] as! Place
                        self.showCalloutFromPlace(place)
                        break
                    }
                }
            }
        }
    }
    
    
    //MARK: - Callout related
    
    func showCallout(mapPoint: AGSPoint, labelText:String?) {
        if self.mapView.callout.isHidden {
            let calloutView = CustomCalloutView.instanceFromNib() as! CustomCalloutView
            calloutView.onSave = {(selectedIndex) -> Void in
                let place = self.savePlace(placeName: labelText, isVisited: (selectedIndex == 0), isWishlist: (selectedIndex == 1), location: mapPoint)
                self.addPlaceOnMap(place)
                self.mapView.callout.dismiss()
            }
            calloutView.placeLabel.text = labelText
            calloutView.getFlightPathsButton.isHidden = true
            self.mapView.callout.customView = calloutView
            self.mapView.callout.show(at: mapPoint, screenOffset: CGPoint.zero, rotateOffsetWithMap: false, animated: true)
        }
    }
    
    func showCalloutFromPlace(_ place:Place) {
        if (self.mapView.callout.isHidden == false) { return }
        
        let calloutView = CustomCalloutView.instanceFromNib() as! CustomCalloutView
        calloutView.onSave = {(selectedIndex) -> Void in
//            updatePlace(isVisited: (selectedIndex == 0), isWishlist: (selectedIndex == 1))
            self.mapView.callout.dismiss()
        }
        calloutView.onGetFlightPaths = {() -> () in
            self.lineGraphicOverlay.graphics.removeAllObjects()
            for p in self.getAllPlaces() {
                self.addLineOnMap(startPoint: p.location, endPoint: place.location, isGeodesic: true)
            }
            self.mapView.callout.dismiss()
        }
        calloutView.placeLabel.text = place.placeName
        var selectedIndex = -1
        if place.isVisited {
            selectedIndex = 0
        }
        else if place.isWishlist {
            selectedIndex = 1
        }
        calloutView.placeSegmentedControl.selectedSegmentIndex = selectedIndex
        self.mapView.callout.customView = calloutView
        self.mapView.callout.show(at: place.location, screenOffset: CGPoint.zero, rotateOffsetWithMap: false, animated: true)
    }
    
    
    
    //MARK: - Model DB related
    
    func getAllPlaces() -> Results<Place> {
        let realm = try! Realm()
        let places = realm.objects(Place.self)
        return places
    }
    
    
    func savePlace(placeName:String?, isVisited:Bool, isWishlist:Bool, location:AGSPoint) -> Place {
        let place = Place()
        place.locationX = location.x
        place.locationY = location.y
        place.isVisited = isVisited
        place.isWishlist = isWishlist
        if let placeName = placeName {
            place.placeName = placeName
        }
        else {
            place.placeName = ""
        }
        
        let realm = try! Realm()
        // You only need to do this once (per thread)
        
        // Add to the Realm inside a transaction
        try! realm.write {
            realm.add(place)
        }
        
        return place
    }
}
