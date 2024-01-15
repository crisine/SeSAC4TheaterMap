//
//  TheaterMapViewController.swift
//  SeSAC4TheaterMap
//
//  Created by Minho on 1/15/24.
//

import UIKit
import MapKit

class TheaterMapViewController: UIViewController {

    @IBOutlet weak var theaterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var theaterMapView: MKMapView!
    
    var theaterAnnotationList = TheaterList.mapAnnotations {
        willSet {
            theaterMapView.removeAnnotations(theaterMapView.annotations)
        }
        didSet {
            setAnnotations()
            setReigon()
            theaterMapView.reloadInputViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setAnnotations()
        setReigon()
    }
    
    func setAnnotations() {
        for annotation in theaterAnnotationList {
            let coordinate = CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = coordinate
            pointAnnotation.title = annotation.location
            
            theaterMapView.addAnnotation(pointAnnotation)
        }
    }
    
    func setReigon() {
        guard theaterAnnotationList.first != nil else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: theaterAnnotationList.first!.latitude , longitude: theaterAnnotationList.first!.longitude)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        theaterMapView.setRegion(region, animated: true)
    }
    
    @IBAction func didTheaterSegmentValueChanged(_ sender: UISegmentedControl) {
        
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        
        if title == "전체보기" {
            theaterAnnotationList = TheaterList.mapAnnotations
        } else {
            theaterAnnotationList = TheaterList.mapAnnotations.filter { $0.type == title }
        }
    }
}
