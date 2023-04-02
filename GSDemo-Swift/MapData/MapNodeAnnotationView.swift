//
//  MapNodeAnnotationView.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/21/23.
//

import UIKit
import MapKit

class MapNodeAnnotationView: MKAnnotationView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.isEnabled = false
        self.isDraggable = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("AAA")
    }

}
