//
//  Constant.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 4/28/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import Foundation
import UIKit

let SHADOW_COLOR: CGFloat = 157.0 / 255.0

let INVALID_EMAIL = -5
let INVALID_PASSWORD = -6
let INVALID_USER = -8
let EMAIL_TAKEN = -9

let FIREBASE_REF = "https://mapkit-simple-2.firebaseio.com"

let EMAIL = "email"
let PERSON_PROFILE_PHOTO = "person_profile_photo"
let LOCATION_COORDINATE = "location_coordinate"
let LATITUDE = "latitude"
let LONGTITUDE = "longtitude"
let PERSON_UID = "person_uid"


var members_UID: [String]!

let GROUP_NAME = "group_name"
let GROUP_DESTINATION = "group_destination"
let GROUP_DESTINATION_LATITUDE = "group_destination_latitude"
let GROUP_DESTINATION_LONGTITUDE = "group_destination_longtitude"
let GROUP_DESCRIPTION = "group_description"
let GROUP_PROFILE_PHOTO = "group_profile_photo"
let GROUP_MEMBERS_UIDS = "member_UIDs"