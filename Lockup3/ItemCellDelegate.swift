//
//  ItemCell.swift
//  Lockup
//

import UIKit

protocol ItemCellDelegate: AnyObject {
    func didRequestDelete(_ cell: ItemCell)
    func didRequestTransfer(_ cell: ItemCell)
}

class ItemCell: UITableViewCell {
    static let reuseID = "ItemCell"

    weak var delegate: ItemCellDelegate?

    private let thumbnail = UIImageView()
    private let nameLabel = UILabel()
    private let moreButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
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
            moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with item: Item) {
        nameLabel.text = item.name
        if let firstImagePath = item.imageFileNames.first,
           let img = UIImage(contentsOfFile: firstImagePath) {
            thumbnail.image = img
        } else {
            thumbnail.image = UIImage(systemName: "cube.box")
        }
    }

    @objc private func moreTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Transfer", style: .default) { _ in
            self.delegate?.didRequestTransfer(self)
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate?.didRequestDelete(self)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        parentViewController?.present(alert, animated: true)
    }
}

private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}

