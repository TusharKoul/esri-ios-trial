//
//  CustomCalloutView.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/3/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import Foundation
import UIKit

class CustomCalloutView : UIView {
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var placeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var getFlightPathsButton: UIButton!
    
    var onSave: ((_ selectedIndex:Int) -> Void)?
    var onGetFlightPaths: (() -> ())?

    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    

    @IBAction func segmentSelectionChanged(_ sender: Any) {
        let isEnabled = (placeSegmentedControl.selectedSegmentIndex >= 0)
        self.saveButton.isEnabled = isEnabled
        self.getFlightPathsButton.isEnabled = isEnabled
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        onSave?(placeSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func getFlightPathsClicked(_ sender: Any) {
        onGetFlightPaths?()
    }
}
