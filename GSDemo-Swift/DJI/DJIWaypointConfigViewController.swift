//
//  DJIWaypointConfigViewController.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/9/23.
//

import UIKit

protocol DJIWaypointConfigViewControllerDelegate: NSObject {
    func cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController)
    func finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController)
}

class DJIWaypointConfigViewController: UIViewController {
    @IBOutlet weak var altitudeTextField: UITextField!
    @IBOutlet weak var autoFlightSpeedTextField: UITextField!
    @IBOutlet weak var maxFlightSpeedTextField: UITextField!
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headingSegmentedControl: UISegmentedControl!
    
    var delegate: DJIWaypointConfigViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    func initUI() {
        self.altitudeTextField.text = "20"
        self.autoFlightSpeedTextField.text = "8"
        self.maxFlightSpeedTextField.text = "10"
        self.actionSegmentedControl.selectedSegmentIndex = 1
        self.headingSegmentedControl.selectedSegmentIndex = 0
    }

    @IBAction func cancelBtnAction(_ sender: Any) {
        self.delegate?.cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: self)
    }
    
    
    @IBAction func finishBtnAction(_ sender: Any) {
        self.delegate?.finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: self)
    }
}
