//  Copyright 2022 Digital.ai Software, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import CoreLocation
import MapKit
import SwiftUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var location: CLLocationCoordinate2D?
 
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
}

struct Map: UIViewRepresentable {
    typealias UIViewType = MKMapView
    @Binding var directions: [String]
    @StateObject private var locationManager = LocationManager()
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
      func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        return renderer
      }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        var map = MKMapView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            map = createMapView(map: map)
        }
        map.delegate = context.coordinator
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func createMapView(map: MKMapView) -> MKMapView {
        guard let location = locationManager.location else {
            let region = MKCoordinateRegion(
                center: destinationCoordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            )
            let marker = MKPlacemark(coordinate: destinationCoordinates)
            map.setRegion(region, animated: true)
            map.addAnnotation(marker)
            return map
        }

        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        )
        map.setRegion(region, animated: true)
        
        let m1 = MKPlacemark(coordinate: location)
        let m2 = MKPlacemark(coordinate: destinationCoordinates)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: m1)
        request.destination = MKMapItem(placemark: m2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            map.addAnnotations([m1,m2])
            map.setVisibleMapRect(
                map.visibleMapRect.union(
                  route.polyline.boundingMapRect
                ),
                edgePadding: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8),
                animated: true
            )
            self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
            map.addOverlay(route.polyline)
        }
        
        return map
    }
}
