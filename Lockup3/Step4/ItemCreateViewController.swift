import UIKit

class ItemCreateViewController: UIViewController {
    let viewModel: ItemCreateViewModel
    var onSave: ((Item) -> Void)?

    private let nameField = UITextField()
    private let descriptionField = UITextField()

    init(viewModel: ItemCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.existing == nil ? "New Item" : "Edit Item"
        view.backgroundColor = .systemBackground
        setupForm()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(saveTapped)
        )
    }

    private func setupForm() {
        let stack = UIStackView(arrangedSubviews: [nameField, descriptionField])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        nameField.placeholder = "Item Name"
        descriptionField.placeholder = "Description"
        nameField.text = viewModel.name
        descriptionField.text = viewModel.description

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func saveTapped() {
        viewModel.name = nameField.text ?? ""
        viewModel.description = descriptionField.text ?? ""
        let item = viewModel.buildItem()
        onSave?(item)
        navigationController?.popViewController(animated: true)
    }
}
