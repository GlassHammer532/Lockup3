//
//  MapViewController.swift
//  Lockup
//
//  Created by YourName on 08/2025.
//

import UIKit
import MapKit
import Combine

// MARK: – MapViewModel

final class MapViewModel: NSObject, ObservableObject {
    @Published private(set) var facilities: [StorageFacility] = []
    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        loadFacilities()
    }

    func loadFacilities() {
        do {
            facilities = try persistence.fetchFacilities()
        } catch {
            print("Error loading facilities:", error)
            facilities = []
        }
    }
}

// MARK: – MapViewController

class MapViewController: UIViewController {

    private let viewModel = MapViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var mapView: MKMapView = {
        let map = MKMapView(frame: .zero)
        map.delegate = self
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar(frame: .zero)
        sb.placeholder = "Search facilities, items, categories"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.delegate = self
        return sb
    }()

    private lazy var createButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 28
        btn.clipsToBounds = true
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.gradient(from: .systemBlue, to: .systemTeal)
        btn.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        return btn
    }()

    private lazy var settingsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapSettings)
        )
        return btn
    }()

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lockup"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = settingsButton

        setupSubviews()
        bindViewModel()
    }

    // MARK: – Setup

    private func setupSubviews() {
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            createButton.widthAnchor.constraint(equalToConstant: 56),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    private func bindViewModel() {
        viewModel.$facilities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] facilities in
                self?.updateAnnotations(with: facilities)
            }
            .store(in: &cancellables)
    }

    // MARK: – Actions

    @objc private func didTapCreate() {
        let createMenu = UIAlertController(title: "Create", message: nil, preferredStyle: .actionSheet)
        createMenu.addAction(.init(title: "New Facility", style: .default) { _ in
            self.showFacilityCreate()
        })
        createMenu.addAction(.init(title: "New Item", style: .default) { _ in
            self.showItemCreate()
        })
        createMenu.addAction(.init(title: "New Category", style: .default) { _ in
            self.showCategoryCreate()
        })
        createMenu.addAction(.init(title: "Cancel", style: .cancel))
        present(createMenu, animated: true)
    }

    @objc private func didTapSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    // MARK: – Navigation Helpers

    private func showFacilityCreate() {
        let vm = FacilityCreateViewModel()
        let vc = FacilityCreateViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showItemCreate() {
        let vm = ItemCreateViewModel()
        let vc = ItemCreateViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showCategoryCreate() {
        let vm = CategoryCreateViewModel()
        let vc = CategoryCreateViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: – Annotations

    private func updateAnnotations(with facilities: [StorageFacility]) {
        mapView.removeAnnotations(mapView.annotations)
        for facility in facilities {
            let annotation = FacilityAnnotation(facility: facility)
            mapView.addAnnotation(annotation)
        }
    }
}

// MARK: – MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let facAnn = annotation as? FacilityAnnotation else { return nil }
        let id = "facilityPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
        if view == nil {
            view = MKMarkerAnnotationView(annotation: facAnn, reuseIdentifier: id)
            view?.markerTintColor = facAnn.facility.type == .permanent ? .systemBlue : .systemGreen
            view?.glyphImage = UIImage(systemName: "cube.box")
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            view?.annotation = facAnn
        }
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let facAnn = view.annotation as? FacilityAnnotation else { return }
        let detailVM = FacilityDetailViewModel(facility: facAnn.facility)
        let detailVC = FacilityDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: – UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        let resultsVM = SearchResultsViewModel(query: query)
        let resultsVC = SearchResultsViewController(viewModel: resultsVM)
        navigationController?.pushViewController(resultsVC, animated: true)
    }
}

// MARK: – FacilityAnnotation

final class FacilityAnnotation: NSObject, MKAnnotation {
    let facility: StorageFacility
    var coordinate: CLLocationCoordinate2D { facility.coordinate }
    var title: String? { facility.name }
    var subtitle: String? { facility.address }

    init(facility: StorageFacility) {
        self.facility = facility
        super.init()
    }
}

// MARK: – UIColor Gradient Helper

extension UIColor {
    static func gradient(from: UIColor, to: UIColor) -> UIColor {
        let size = CGSize(width: 1, height: 64)
        UIGraphicsBeginImageContext(size)
        guard let ctx = UIGraphicsGetCurrentContext() else { return from }
        let colors = [from.cgColor, to.cgColor] as CFArray
        let locs: [CGFloat] = [0, 1]
        let space = CGColorSpaceCreateDeviceRGB()
        let grad = CGGradient(colorsSpace: space, colors: colors, locations: locs)!
        ctx.drawLinearGradient(grad,
                               start: CGPoint(x: 0, y: 0),
                               end: CGPoint(x: 0, y: size.height),
                               options: [])
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return UIColor(patternImage: img)
    }
}
