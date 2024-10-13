//
//  ViewController.swift
//  Project16 - Capital Cities
//
//  Created by Stefan Storm on 2024/10/01.
//
import MapKit
import UIKit


class ViewController: UIViewController, MKMapViewDelegate{
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsCompass = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change Map", style: .plain, target: self, action: #selector(mapTypeTapped))
       
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        let pretoria = Capital(title: "Pretoria", coordinate: CLLocationCoordinate2D(latitude: -25.731340, longitude: 28.218370), info: "Jakaranda city.")
        let johannesburg = Capital(title: "Johannesburg", coordinate: CLLocationCoordinate2D(latitude: -26.195246, longitude: 28.034088), info: "City of gold.")
        let capeTown = Capital(title: "Cape Town", coordinate: CLLocationCoordinate2D(latitude: -33.918861, longitude: 18.406263), info: "The Mother City.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington, pretoria, johannesburg, capeTown ])
    }
    
    
    @objc func mapTypeTapped(){
        let ac = UIAlertController(title: "Choose map type:", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: setMapType))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: setMapType))
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: setMapType))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(ac, animated: true)
        
    }
    
    
    func setMapType(_ action: UIAlertAction){
        
        switch action.title {
        case "Hybrid":
            if #available(iOS 16.0, *) {
                mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
            } else {
                mapView.mapType = .hybrid
            }
        case "Satellite":
            if #available(iOS 16.0, *) {
                mapView.preferredConfiguration = MKImageryMapConfiguration(elevationStyle: .realistic)
            } else {
                mapView.mapType = .satellite
            }
        default:
            if #available(iOS 16.0, *) {
                mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
            } else {
                mapView.mapType = .standard
            }
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else {return nil}
        let identifier = "Capital"
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        annotationView.markerTintColor = .blue
        annotationView.glyphImage = .strokedCheckmark
        annotationView.canShowCallout = true
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = btn
        
        annotationView.annotation = annotation
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else {return}
        
        let ac = DetailsViewController()
        ac.capital = capital
        self.navigationController?.pushViewController(ac, animated: true)
        
        
       
//        let title = capital.title
//        let info = capital.info
//        
//        
//        let ac = UIAlertController(title: title, message: info, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "Okay", style: .default))
//        present(ac, animated:  true)
        
    }


}

