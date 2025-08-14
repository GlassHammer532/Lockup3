import UIKit

protocol CategoryHeaderViewDelegate: AnyObject {
    func didTapEdit(_ header: CategoryHeaderView)
    func didTapDelete(_ header: CategoryHeaderView)
}

class CategoryHeaderView: UIView {
    weak var delegate: CategoryHeaderViewDelegate?

    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let colorView = UIView()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        nameLabel.font = .boldSystemFont(ofSize: 24)
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        colorView.layer.cornerRadius = 10

        editButton.setTitle("Edit", for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)

        [colorView, nameLabel, descriptionLabel, editButton, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            colorView.widthAnchor.constraint(equalToConstant: 20),
            colorView.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: colorView.centerYAnchor),

            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    func configure(with category: Category) {
        nameLabel.text = category.name
        descriptionLabel.text = category.description
        colorView.backgroundColor = UIColor(hex: category.colorHex) ?? .clear
    }

    @objc private func editTapped() { delegate?.didTapEdit(self) }
    @objc private func deleteTapped() { delegate?.didTapDelete(self) }
}
