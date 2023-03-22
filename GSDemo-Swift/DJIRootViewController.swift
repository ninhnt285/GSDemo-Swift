//
//  DJIRootViewController.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/6/23.
//

import UIKit
import DJISDK
import MapKit

class DJIRootViewController: UIViewController {
    
    var isEditingPoints: Bool = false
    var gsButtonVC: DJIGSButtonViewController!
    var waypointConfigVC: DJIWaypointConfigViewController!
    var mapController: DJIMapController!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var droneLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    var waypointMission = DJIMutableWaypointMission()
    var mapModel: MapModel!
    var minElevation: Double = 0.0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startUpdateLocation()
        self.registerApp()
        
        self.initUI()
        self.initData()
    }
    
    func initData() {
        self.mapController = DJIMapController()
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addWayPoint(_:)))
        self.mapView.addGestureRecognizer(self.tapGesture)
    }
    
    func initUI() {
        self.gsButtonVC = DJIGSButtonViewController(nibName: "DJIGSButtonViewController", bundle: Bundle.main)
        self.gsButtonVC.delegate = self
        self.gsButtonVC.view.frame = CGRect(x: 12, y: self.topBarView.frame.origin.y + self.topBarView.frame.size.height, width: self.gsButtonVC.view.frame.size.width, height: self.gsButtonVC.view.frame.size.height)
        self.view.addSubview(self.gsButtonVC.view)
        
        self.waypointConfigVC = DJIWaypointConfigViewController(nibName: "DJIWaypointConfigViewController", bundle: Bundle.main)
        self.waypointConfigVC.view.alpha = 0
        self.waypointConfigVC.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        self.waypointConfigVC.view.center = self.view.center
        self.waypointConfigVC.delegate = self
        self.view.addSubview(self.waypointConfigVC.view)
    }
    
    func registerApp() {
        DispatchQueue.global(qos: .background).async {
            DJISDKManager.registerApp(with: self)
        }
    }
    
    var missionOperator: DJIWaypointMissionOperator? {
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }
    
    func focusMap() {
        var focusLocation = kCLLocationCoordinate2DInvalid
        #if targetEnvironment(simulator)
        focusLocation = CLLocationCoordinate2D(latitude: 35.307100, longitude: -80.734733)
        #else
        if CLLocationCoordinate2DIsValid(self.userLocation) {
            focusLocation = self.userLocation
        }
        if CLLocationCoordinate2DIsValid(self.droneLocation) {
            focusLocation = self.droneLocation
        }
        #endif
        
        if CLLocationCoordinate2DIsValid(focusLocation) {
            var region = MKCoordinateRegion()
            region.center = focusLocation
            region.span.latitudeDelta = 0.001
            region.span.longitudeDelta = 0.001
            
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    // CLLocation Methods
    func startUpdateLocation() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 0.1
        self.locationManager.requestAlwaysAuthorization()
    }
    
    @objc func addWayPoint(_ tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: self.mapView)
        
        if tapGesture.state == .ended {
            if (self.isEditingPoints) {
                self.mapController.addPoint(point, withMapView: self.mapView)
            }
        }
    }
    
    @IBAction func loadMapBtnAction(_ sender: Any) {
        let mapFile = "map1"
        
        if let url = Bundle.main.url(forResource: mapFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(MapData.self, from: data)
                self.mapModel = MapModel(mapData: jsonData)
                // Display all nodes on map
//                let routes = self.mapModel.findBestRoute(minElevation: self.minElevation)
                
                for node in jsonData.nodes {
                    let point = MapNodeAnnotation(mapNode: node)
                    self.mapView.addAnnotation(point)
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func floodedBtnAction(_ sender: Any) {
        if CLLocationCoordinate2DIsValid(self.droneLocation) {
            self.minElevation = self.mapModel.findNearElevation(self.droneLocation)
        }
    }
}



extension DJIRootViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            print("Denied")
            let alert = UIAlertController(title: "Location Service is not available", message: "", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true)
        } else if (status == .authorizedWhenInUse || status == .authorizedAlways) {
            print("Accepted")
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pinAnnotation = annotation as? MKPointAnnotation {
            let pinView = MKMarkerAnnotationView(annotation: pinAnnotation, reuseIdentifier: "Pin_Annotation")
            pinView.tintColor = .cyan
            return pinView
        } else if let mapNodeAnnotation = annotation as? MapNodeAnnotation {
            let annoView = MKMarkerAnnotationView(annotation: mapNodeAnnotation, reuseIdentifier: "MapNode_Annotation")
            annoView.glyphText = String(mapNodeAnnotation.mapNode.elevation)
            annoView.markerTintColor = .green
            annoView.glyphTintColor = .black
//            MapNodeAnnotationView(annotation: mapNodeAnnotation, reuseIdentifier: "MapNode_Annotation")
//            mapNodeAnnotation.annotationView = annoView
            return annoView
        } else if let aircraftAnnotation = annotation as? DJIAircraftAnnotation {
            let annoView = DJIAircraftAnnotationView(annotation: aircraftAnnotation, reuseIdentifier: "Aircraft_Annotation")
            aircraftAnnotation.annotationView = annoView
            return annoView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let mapNodeAnnotation = annotation as? MapNodeAnnotation {
            print(mapNodeAnnotation.mapNode.id)
        }
    }
}



extension DJIRootViewController: DJISDKManagerDelegate, DJIFlightControllerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        if error != nil {
            let registerResult = "Registration Error, \(error!.localizedDescription)"
            ShowMessage(title: "Registration Result", message: registerResult, target: nil, cancelBtnTitle: "OK")
        } else {
            print("Registered Successfully! Connecting to product...")
            DJISDKManager.startConnectionToProduct()
        }
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if product != nil {
            if let flightController = DemoUtility.fetchFlightController() {
                flightController.delegate = self
            }
        } else {
            ShowMessage(title: "Product Disconnected", message: nil, target: nil, cancelBtnTitle: "OK")
        }
    }
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        self.droneLocation = state.aircraftLocation?.coordinate ?? kCLLocationCoordinate2DInvalid
        
        self.modeLabel.text = state.flightModeString
        self.gpsLabel.text = "\(state.satelliteCount)"
        self.vsLabel.text = "\(state.velocityZ)"
        self.hsLabel.text = "\(sqrt(state.velocityX * state.velocityX + state.velocityY * state.velocityY))"
        self.altitudeLabel.text = "\(state.altitude)"
        
        self.mapController.updateAircraftLocation(location: self.droneLocation, with: self.mapView)
        let radianYaw = state.attitude.yaw / 180.0 * Double.pi
        self.mapController.updateAircraftHeading(heading: radianYaw)
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        
    }
}



extension DJIRootViewController: DJIGSButtonViewControllerDelegate {
    func addBtnActionInGSButtonVC(addBtn: UIButton, GSBtnVC: DJIGSButtonViewController) {
        if self.isEditingPoints {
            self.isEditingPoints = false
            addBtn.setTitle("Add", for: .normal)
        } else {
            self.isEditingPoints = true
            addBtn.setTitle("Finished", for: .normal)
        }
    }
    
    func stopBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController) {
        self.missionOperator?.stopMission() { error in
            print(error?.localizedDescription ?? "Stop Mission Finished")
        }
    }
    
    func clearBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController) {
        self.mapController.cleanAllPointsWithMapView(mapView: self.mapView)
    }
    
    func focusBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController) {
        self.focusMap()
    }
    
    func startBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController) {
        // TODO: Find best route
        let routes = self.mapModel.findBestRoute(minElevation: self.minElevation)
        var waypoints = [CLLocation]()
        for node in routes {
            waypoints.append(CLLocation(latitude: node.lat, longitude: node.lon))
        }
        
        if waypoints.count < 2 {
            ShowMessage(title: "No or not enough waypoints for mission", message: nil, target: nil, cancelBtnTitle: "OK")
            return
        }
        
        self.waypointMission.removeAllWaypoints()
        
        for location in waypoints {
            if CLLocationCoordinate2DIsValid(location.coordinate) {
                let waypoint = DJIWaypoint(coordinate: location.coordinate)
                self.waypointMission.add(waypoint)
            }
        }
        
        
        self.missionOperator?.startMission() { error in
            print(error?.localizedDescription ?? "Mission Started")
//            ShowMessage(title: "Mission Started", message: nil, target: nil, cancelBtnTitle: "OK")
        }
    }
    
    func configBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController) {
        UIView.animate(withDuration: 0.25) {[weak self] in
            self?.waypointConfigVC.view.alpha = 1.0
        }
    }
    
    func switchToMode(_ mode: DJIGSViewMode, inGSButtonVC GSBtnVC: DJIGSButtonViewController) {
        if (mode == .edit) {
            self.focusMap()
        }
    }
}



extension DJIRootViewController: DJIWaypointConfigViewControllerDelegate {
    func cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController) {
        UIView.animate(withDuration: 0.25) {
            waypointConfigVC.view.alpha = 0;
        }
    }
    
    func finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController) {
        UIView.animate(withDuration: 0.25) {
            waypointConfigVC.view.alpha = 0;
        }
        
        for i in 0..<self.waypointMission.waypointCount {
            let waypoint = self.waypointMission.waypoint(at: i)
            waypoint?.altitude = Float(self.waypointConfigVC.altitudeTextField.text ?? "20.0") ?? 20.0
        }
        
        self.waypointMission.maxFlightSpeed = Float(self.waypointConfigVC.maxFlightSpeedTextField.text ?? "10.0") ?? 10.0
        self.waypointMission.autoFlightSpeed = Float(self.waypointConfigVC.autoFlightSpeedTextField.text ?? "5.0") ?? 5.0
        self.waypointMission.headingMode = DJIWaypointMissionHeadingMode(rawValue: UInt(self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex)) ?? .auto
        self.waypointMission.finishedAction = DJIWaypointMissionFinishedAction(rawValue: UInt8(self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex)) ?? .goHome
        
        self.missionOperator?.load(self.waypointMission)
        
        self.missionOperator?.addListener(toFinished: self, with: DispatchQueue.main) {error in
            print(error?.localizedDescription ?? "Mission Execution Finished")
        }
        
        self.missionOperator?.addListener(toExecutionEvent: self, with: DispatchQueue.main, andBlock: { event in
            print(event)
        })
        
        self.missionOperator?.uploadMission() { error in
            print(error?.localizedDescription ?? "Upload Mission Finished")
        }
    }
    
    func showAlertView(title: String, withMessage message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
