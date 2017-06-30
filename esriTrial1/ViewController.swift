//
//  ViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 6/26/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var graphicsOverlay = AGSGraphicsOverlay()
    private var searchResults:Array = [String]()
    private var suggestResults:[AGSSuggestResult]!
    private var locatorTask = AGSLocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
    private var suggestRequestOperation:AGSCancelable!
    
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearch()
        loadMap()
        addPoint()
    }
    
    func configureSearch(){
        self.searchBar.delegate = self
        self.searchResultsTableView.delegate = self
        self.searchResultsTableView.dataSource = self
    }
    
    
    
    //MARK: - Map related
    
    private func loadMap() {
        self.mapView.map = AGSMap(basemapType: .darkGrayCanvasVector, latitude: 34.057, longitude: -117.196, levelOfDetail: 17)
        self.mapView.graphicsOverlays.add(graphicsOverlay)
    }
    
    
    private func addPoint() {
        let latitude = 34.057, longitude = -117.196
        let point = AGSPoint(x: longitude, y: latitude, spatialReference: AGSSpatialReference.wgs84())
        let symbol = AGSSimpleMarkerSymbol(style: .diamond, color: .red, size: 10)
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: nil)
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
        print("cell pressed at " + String(indexPath.row))
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.fetchSuggestions), userInfo: searchText, repeats: false)
    }
    
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // called when keyboard search button pressed
        print("searchBarSearchButtonClicked")
    }

    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // called when cancel button pressed
        print("searchBarCancelButtonClicked")
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
                }
                else {
                    //update the suggest results and reload the table
                    self.suggestResults = result
                    self.searchResultsTableView.reloadData()
                }
            }
        }
    }
    
}
