//
//  MapNode.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/21/23.
//

import Foundation
import MapKit
import CoreLocation

struct MapNode: Decodable {
    var id: Int64
    var lat: Double
    var lon: Double
    var elevation: Double
    var x: Double
    var y: Double
}

struct MapData: Decodable {
    var start: Int64
    var end: Int64
    var nodes: [MapNode]
    var edges: [[Int64]]
}

class MapModel: NSObject {
    var mapData: MapData!
    var nodeDict: [Int64: MapNode] = [:]
    var edgeDict: [Int64: Set<Int64>] = [:]
    
    init(mapData: MapData) {
        self.mapData = mapData
        
        for node in mapData.nodes {
            self.nodeDict[node.id] = node
        }
        
        for edge in mapData.edges {
            for i in 0...1 {
                let firstId = edge[i]
                let lastId = edge[1-i]
                
                if (!edgeDict.keys.contains(firstId)) {
                    edgeDict[firstId] = []
                }
                edgeDict[firstId]?.insert(lastId)
            }
        }
    }
    
    func findDistance(_ a: MapNode,_ b: MapNode) -> Double {
        return sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y))
    }
    
    func findBestRoute(minElevation: Double, minDistance: Double = 25.0) -> [MapNode] {
        var distance : [Int64: Double] = [:]
        var trace: [Int64: Int64] = [:]
        var visited: Set<Int64> = []
        
        trace[mapData.start] = -1
        distance[mapData.start] = 0
        
        while true {
            // Find next node
            var minDistance = Double.infinity
            var firstId: Int64 = 0
            for nodeId in distance.keys {
                if let d = distance[nodeId] {
                    if !visited.contains(nodeId) && (d < minDistance) {
                        minDistance = d
                        firstId = nodeId
                    }
                }
            }
            // Set visited
            if firstId == 0 || firstId == mapData.end {
                break
            } else {
                visited.insert(firstId)
            }
            // Update distance
            for edge in mapData.edges {
                if (edge[0] == firstId) || (edge[1] == firstId) {
                    let lastId = edge[0] + edge[1] - firstId
                    let firstNode = self.nodeDict[firstId]!
                    let lastNode = self.nodeDict[lastId]!
                    
                    if lastNode.elevation < minElevation {
                        continue
                    }
                    
                    if (!distance.keys.contains(lastId)) || (distance[lastId]! > distance[firstId]! + findDistance(firstNode, lastNode)) {
                        distance[lastId] = distance[firstId]! + findDistance(firstNode, lastNode)
                        trace[lastId] = firstId
                    }
                }
            }
        }
        
        // Print route
        if !trace.keys.contains(mapData.end) {
            return []
        }
        
        
        var lastId = mapData.end
        var routes: [MapNode] = [nodeDict[lastId]!]
        
        
        while trace[lastId] != -1 {
            lastId = trace[lastId]!
            
            let lastLocation = CLLocation(latitude: routes.first!.lat, longitude: routes.first!.lon)
            var nodeLocation = CLLocation(latitude: nodeDict[lastId]!.lat, longitude: nodeDict[lastId]!.lon)
            while (lastLocation.distance(from: nodeLocation) < minDistance && trace[lastId]! != -1) {
                lastId = trace[lastId]!
                nodeLocation = CLLocation(latitude: nodeDict[lastId]!.lat, longitude: nodeDict[lastId]!.lon)
            }
            
            if trace[lastId]! == -1 {
                break
            }
            routes.insert(nodeDict[lastId]!, at: 0)
        }
        
        return routes
    }
    
    func findNearElevation(_ loc: CLLocationCoordinate2D) -> Double {
        let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        var minValue = Double.infinity
        var elevation: Double = 0.0
        
        for node in self.mapData.nodes {
            let nodeLocation = CLLocation(latitude: node.lat, longitude: node.lon)
            let distance = location.distance(from: nodeLocation)
            if distance < minValue {
                minValue = distance
                elevation = node.elevation
            }
        }
        
        return elevation
    }
}
