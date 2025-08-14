//
//  ItemCell.swift
//  Lockup
//
//  Created by YourName on 08/2025.
//

import UIKit

protocol ItemCellDelegate: AnyObject {
    func didRequestDelete(_ cell: ItemCell)
    func didRequestTransfer(_ cell: ItemCell)
}

class ItemCell: UITableViewCell {

    static let reuseID = "ItemCell"

    weak var delegate: ItemCellDelegate?

    private let nameLabel = UILabel()
    private let thumbnail = UIImageView()
    private let moreButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.layer.cornerRadius = 6
        thumbnail.clipsToBounds = true
        thumbnail.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)

        contentView.addSubview(thumbnail)
        contentView.addSubview(nameLabel)
        contentView.addSubview(moreButton)

        NSLayoutConstraint.activate([
            thumbnail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnail.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnail.widthAnchor.constraint(equalToConstant: 40),
            thumbnail.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(with item: Item) {
        nameLabel.text = item.name
        if let file = item.imageFileNames.first,
           let img = UIImage(contentsOfFile: file) {
            thumbnail.image = img
        } else {
            thumbnail.image = UIImage(systemName: "cube.box")
        }
    }

    @objc private func moreTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "Transfer", style: .default) { _ in
            self.delegate?.didRequestTransfer(self)
        })
        actionSheet.addAction(.init(title: "Delete", style: .destructive) { _ in
            self.delegate?.didRequestDelete(self)
        })
        actionSheet.addAction(.init(title: "Cancel", style: .cancel))
        if let vc = parentViewController {
            vc.present(actionSheet, animated: true)
        }
    }
}

// MARK: – UIView extension to find parent view controller

private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController { return vc }
            responder = responder?.next
        }
        return nil
    }
}
