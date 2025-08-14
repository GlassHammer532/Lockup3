//
//  FacilityCreateViewController.swift
//  Lockup3
//
//  Created by Felix Clissold on 14/08/2025.
//


//
//  FacilityCreateViewController.swift
//  Lockup
//

import UIKit

class FacilityCreateViewController: UIViewController {
    let viewModel: FacilityCreateViewModel
    var onSave: ((StorageFacility) -> Void)?

    init(viewModel: FacilityCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.existingFacility == nil ? "New Facility" : "Edit Facility"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
    }

    @objc private func saveTapped() {
        let facility = viewModel.save()
        onSave?(facility)
        navigationController?.popViewController(animated: true)
    }
}
