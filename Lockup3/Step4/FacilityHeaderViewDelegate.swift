//
//  FacilityHeaderView.swift
//  Lockup
//
//  Created by YourName on 08/2025.
//

import UIKit

protocol FacilityHeaderViewDelegate: AnyObject {
    func didTapEdit(_ header: FacilityHeaderView)
    func didTapDelete(_ header: FacilityHeaderView)
}

class FacilityHeaderView: UIView {

    weak var delegate: FacilityHeaderViewDelegate?

    private let nameLabel = UILabel()
    private let sizeLabel = UILabel()
    private let addressLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        nameLabel.font = .boldSystemFont(ofSize: 24)
        sizeLabel.font = .systemFont(ofSize: 14)
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel

        editButton.setTitle("Edit", for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)

        [nameLabel, sizeLabel, addressLabel, editButton, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            editButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            deleteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -16),

            sizeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            sizeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            addressLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
        ])

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    func configure(with facility: StorageFacility) {
        nameLabel.text = facility.name
        if let d = facility.dimensions {
            sizeLabel.text = "\(Int(d.width))×\(Int(d.length))×\(Int(d.height)) \(d.shape)"
        } else {
            sizeLabel.text = "Temporary"
        }
        addressLabel.text = facility.address
    }

    @objc private func editTapped() {
        delegate?.didTapEdit(self)
    }
    @objc private func deleteTapped() {
        delegate?.didTapDelete(self)
    }
}
