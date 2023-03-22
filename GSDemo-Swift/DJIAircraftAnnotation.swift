//
//  DJIAircraftAnnotation.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/6/23.
//

import UIKit
import MapKit

class DJIAircraftAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    weak var annotationView: DJIAircraftAnnotationView?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }
    
    func updateHeading(_ heading: CGFloat) {
        if let _ = self.annotationView {
            self.annotationView?.updateHeading(heading)
        }
    }
}
