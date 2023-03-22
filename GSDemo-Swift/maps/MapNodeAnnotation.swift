//
//  MapNodeAnnotation.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/21/23.
//

import UIKit
import MapKit

class MapNodeAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var mapNode: MapNode!
    weak var annotationView: MapNodeAnnotationView?
    var visited: Bool = false
    
    init(mapNode: MapNode) {
        self.mapNode = mapNode
        self.coordinate = CLLocationCoordinate2D(latitude: mapNode.lat, longitude: mapNode.lon)
    }
}
