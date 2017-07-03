//
//  Place.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/3/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import Foundation
import RealmSwift
import ArcGIS
class Place:Object {
    dynamic var placeName = ""
    dynamic var isVisited = false
    dynamic var isWishlist = false
    dynamic var locationX:Double = 0.0
    dynamic var locationY:Double = 0.0
}
