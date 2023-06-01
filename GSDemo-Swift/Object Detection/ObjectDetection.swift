//
//  ObjectDetection.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/31/23.
//

import AVFoundation
import Vision
import CoreImage

class ObjectDetection {
    let maxBoudings = YOLO.maxBoundingBoxes
    var detectionRequest:VNCoreMLRequest!
    var ready = false
    
    init() {
        self.initDetection()
    }
    
    func initDetection() {
        do {
            let model = try VNCoreMLModel(for: yolov7(configuration: MLModelConfiguration()).model)
            
            self.detectionRequest = VNCoreMLRequest(model: model)
            
            self.ready = true
            
        } catch let error {
            fatalError("failed to setup model: \(error)")
        }
    }
    
    func detectAndProcess(image:CIImage,_ viewSize: CGSize = CGSize(width: 256, height: 144))-> [ProcessedObservation] {
        
        let observations = self.detect(image: image)
        
        let processedObservations = self.processObservation(observations: observations, viewSize: viewSize)
        
        return processedObservations
    }
    
    
    func detect(image:CIImage) -> [VNObservation] {
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([self.detectionRequest])
            let observations = self.detectionRequest.results!
            
            return observations
            
        } catch let error {
            fatalError("failed to detect: \(error)")
        }
    }
    
    
    func processObservation(observations:[VNObservation], viewSize:CGSize) -> [ProcessedObservation]{
       
        var processedObservations:[ProcessedObservation] = []
        
        var count = 0
        for observation in observations where observation is VNRecognizedObjectObservation {
            count += 1
            if count > self.maxBoudings {
                break
            }
            
            let objectObservation = observation as! VNRecognizedObjectObservation
            
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(viewSize.width), Int(viewSize.height))
            
            let flippedBox = CGRect(x: objectBounds.minX, y: viewSize.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
            
            let label = objectObservation.labels.first!.identifier
            
            let processedOD = ProcessedObservation(label: label, confidence: objectObservation.confidence, boundingBox: flippedBox)
            
            processedObservations.append(processedOD)
        }
        
        return processedObservations
        
    }
    
}

struct ProcessedObservation{
    var label: String
    var confidence: Float
    var boundingBox: CGRect
}
