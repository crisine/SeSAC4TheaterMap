//
//  TheaterMapViewController.swift
//  SeSAC4TheaterMap
//
//  Created by Minho on 1/15/24.
//

import UIKit
import MapKit

class TheaterMapViewController: UIViewController {

    
    @IBOutlet weak var theaterMapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var theaterAnnotationList = TheaterList.mapAnnotations {
        willSet {
            theaterMapView.removeAnnotations(theaterMapView.annotations)
        }
        didSet {
            setAnnotations()
//            setReigon()
            theaterMapView.reloadInputViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        checkDeviceLocationAuthorization()
        configureNavigation()
        
        setAnnotations()
        configureButton()
    }
    
    func configureButton() {
        locationButton.setImage(UIImage(systemName: "scope"), for: .normal)
        locationButton.setTitle("", for: .normal)
        locationButton.tintColor = .white
    }
    
    func configureNavigation() {
        navigationItem.title = "SeSAC MAP"
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(didFilterButtonTapped)), animated: true)
    }
    
    @objc func didFilterButtonTapped() {
        // ActionSheet 팝업
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        let lotteCinemaAction = UIAlertAction(title: "롯데시네마", style: .default) { _ in
            self.didActionSheetTapped(title: "롯데시네마")
        }
        
        let megaboxAction = UIAlertAction(title: "메가박스", style: .default) { _ in
            self.didActionSheetTapped(title: "메가박스")
        }
        
        let cgvAction = UIAlertAction(title: "CGV", style: .default) { _ in
            self.didActionSheetTapped(title: "CGV")
        }
        
        let seeAllAction = UIAlertAction(title: "전체보기", style: .default) { _ in
            self.didActionSheetTapped(title: "전체보기")
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            self.didActionSheetTapped(title: "취소")
        }
        
        alert.addAction(megaboxAction)
        alert.addAction(lotteCinemaAction)
        alert.addAction(cgvAction)
        alert.addAction(seeAllAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
        // 여기서 영화관 Filtering 하는 메서드 호출
        
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
    
    func didActionSheetTapped(title: String) {
        
        if title == "전체보기" {
            theaterAnnotationList = TheaterList.mapAnnotations
        } else {
            theaterAnnotationList = TheaterList.mapAnnotations.filter { $0.type == title }
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: theaterAnnotationList.first!.latitude, longitude: theaterAnnotationList.first!.longitude)
        
        setRegionAndAnnotation(center: coordinate, meters: 10000)
    }
    
    @IBAction func didLocationButtonTapped(_ sender: UIButton) {
        
        checkCurrentLocationAuthorization(status: locationManager.authorizationStatus)
    }
}

extension TheaterMapViewController {
    
    func checkDeviceLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                
                self.checkCurrentLocationAuthorization(status: authorization)
            } else {
                print("위치 서비스가 꺼져 있어서, 위치 권한 요청을 할 수 없어요.")
            }
        }
    }
    
    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        
        // 위치 정보 권한과 관련하여 모든 상태
        switch status {
        case .notDetermined:
            print("notDetermined")
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            print("restricted")
            
        case .denied:
            print("denied")
            DispatchQueue.main.async {
                // 청취사 영등포로 맵뷰 중심 이동
                let coordinate = CLLocationCoordinate2D(latitude: 37.517742, longitude: 126.886463)
                self.showLocationSettingAlert()
                self.setRegionAndAnnotation(center: coordinate, meters: 400)
            }
            
        case .authorizedAlways:
            print("authorizedAlways")
            
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            locationManager.startUpdatingLocation()
            
        case .authorized:
            print("authorized")
            
        @unknown default:
            print("unknown case")
        }
    }
    
    func showLocationSettingAlert() {
        
        // MARK: 위치 정보 사용을 거부하였을 경우의 Alert
        let alert = UIAlertController(title: "위치 정보 이용", message: "위치 정보를 사용할 수 없습니다. 기기의 '설정 > 개인정보 보호'에서 위치 서비스를 켜 주세요.", preferredStyle: .alert)
        
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let setting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(setting)
            } else {
                print("설정으로 직접 이동 부탁드립니다.")
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(goSetting)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    // 지도 지역 설정 및 핀 찍기
    func setRegionAndAnnotation(center: CLLocationCoordinate2D, meters: CLLocationDistance) {
        
        // 지도 중심 기반으로 보여질 범위 설정
        let region = MKCoordinateRegion(center: center, latitudinalMeters: meters, longitudinalMeters: meters)
        
        theaterMapView.setRegion(region, animated: true)
    }
}

extension TheaterMapViewController: CLLocationManagerDelegate {
    
    // 5. 사용자의 위치를 성공적으로 가지고 온 경우 실행
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        
        if let coordinate = locations.last?.coordinate {
            print(coordinate)
            print(coordinate.latitude)
            print(coordinate.longitude)
            // 날씨 앱을 만든다고 치면, 여기서 API 호출을 하면 될 것이다.
            
            setRegionAndAnnotation(center: coordinate, meters: 400)
        }
        
        // 필요한 시점에 STOP하는게 중요하다. (날씨 앱이라면 한번만 부르면 되겠지만, 네비게이션이라면 지속 호출 필요)
        locationManager.stopUpdatingLocation()
    }
    
    // 6. 사용자의 위치를 가지고 오지 못한 경우
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    // 4) 사용자 권한 상태가 바뀔 때를 알려주는 메서드
    // 예) 거부했다가 설정에서 허용으로 바꾸거나, notDetermined에서 허용 상태로 바뀌었거나
    // 허용해서 위치를 가져오는 도중 다시 설정에서 거부를 한 경우 등
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkDeviceLocationAuthorization()
    }
    
    // 4) 사용자 권한 상태가 바뀔 때를 알려주는 메서드
    // iOS 14 미만
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
    }
}
