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
    
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        
        loadMap()
        addPoint()
        
        searchResults = ["abc","def","ghi"]
        
        self.searchResultsTableView.delegate = self
        self.searchResultsTableView.dataSource = self
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell")!
        let data = searchResults[indexPath.row]
        cell.textLabel?.text = data
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell pressed at " + String(indexPath.row))
    }

    
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
    
    
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // called when text starts editing
        print("searchBarTextDidBeginEditing")
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // called when text ends editing
        print("searchBarTextDidEndEditing")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("after every text gets changed")
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.output), userInfo: searchText, repeats: false)
    }
    
    func output(){
        print("hello ")
        if let timer = timer {
            print(timer.userInfo)
            timer.invalidate()
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // called when keyboard search button pressed
        print("searchBarSearchButtonClicked")
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // called when cancel button pressed
        print("searchBarCancelButtonClicked")
    }

}
