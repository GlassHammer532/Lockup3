import UIKit

class CategoryCreateViewController: UIViewController {
    let viewModel: CategoryCreateViewModel
    var onSave: ((Category) -> Void)?

    private let nameField = UITextField()
    private let descriptionField = UITextField()
    private let colorField = UITextField()

    init(viewModel: CategoryCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.existing == nil ? "New Category" : "Edit Category"
        view.backgroundColor = .systemBackground
        setupForm()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(saveTapped)
        )
    }

    private func setupForm() {
        let stack = UIStackView(arrangedSubviews: [nameField, descriptionField, colorField])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        nameField.placeholder = "Name"
        descriptionField.placeholder = "Description"
        colorField.placeholder = "#RRGGBB"

        nameField.text = viewModel.name
        descriptionField.text = viewModel.description
        colorField.text = viewModel.colorHex

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func saveTapped() {
        viewModel.name = nameField.text ?? ""
        viewModel.description = descriptionField.text ?? ""
        viewModel.colorHex = colorField.text ?? "#000000"
        let category = viewModel.buildCategory()
        onSave?(category)
        navigationController?.popViewController(animated: true)
    }
}
