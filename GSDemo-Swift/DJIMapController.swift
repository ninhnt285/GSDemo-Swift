//
//  DJIMapController.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/6/23.
//

import UIKit
import MapKit
import CoreLocation

class DJIMapController: NSObject {
    var editPoints: [CLLocation] = []
    var aircraftAnnotation: DJIAircraftAnnotation?
    
    override init() {
        super.init()
        
        self.editPoints = [CLLocation]()
    }
    
    func addLocationFromRoute(_ node: MapNode, withMapView mapView: MKMapView) {
        let location = CLLocation(latitude: node.lat, longitude: node.lon)
        
        self.editPoints.append(location)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func addPoint(_ point: CGPoint, withMapView mapView: MKMapView) {
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        self.editPoints.append(location)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func cleanAllPointsWithMapView(mapView: MKMapView) {
        self.editPoints.removeAll()
        
        let annos = mapView.annotations
        for anno in annos {
            if !anno.isEqual(self.aircraftAnnotation) {
                mapView.removeAnnotation(anno)
            }
        }
    }
    
    func wayPoints() -> [CLLocation] {
        return self.editPoints
    }
    
    func updateAircraftLocation(location: CLLocationCoordinate2D, with mapView: MKMapView) {
        if self.aircraftAnnotation == nil {
            self.aircraftAnnotation = DJIAircraftAnnotation(coordinate: location)
            mapView.addAnnotation(self.aircraftAnnotation!)
        }
        self.aircraftAnnotation?.setCoordinate(location)
    }
    
    func updateAircraftHeading(heading: CGFloat) {
        self.aircraftAnnotation?.updateHeading(heading)
    }
}
