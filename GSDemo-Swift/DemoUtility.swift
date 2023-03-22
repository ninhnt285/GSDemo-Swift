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

func ShowMessage(title: String, message: String?, target: Any?, cancelBtnTitle: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .cancel)
    alertController.addAction(okAction)
    
    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
}
