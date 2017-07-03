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
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
