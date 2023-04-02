//
//  DemoUtility.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/6/23.
//

import UIKit
import DJISDK

class DemoUtility: NSObject {
    class func fetchFlightController() -> DJIFlightController? {
        if DJISDKManager.product() == nil {
            return nil
        }
        
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            return aircraft.flightController
        }
        
        return nil
    }
}
