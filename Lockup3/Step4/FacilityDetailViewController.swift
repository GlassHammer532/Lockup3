//
//  FacilityDetailViewController.swift
//  Lockup
//
//  Created by YourName on 08/2025.
//

import UIKit
import Combine

class FacilityDetailViewController: UIViewController {

    private let viewModel: FacilityDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var headerView: FacilityHeaderView = {
        let hv = FacilityHeaderView()
        hv.translatesAutoresizingMaskIntoConstraints = false
        hv.delegate = self
        return hv
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    init(viewModel: FacilityDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Facility Details"
        view.backgroundColor = .systemBackground
        setupSubviews()
        bindViewModel()
    }

    private func setupSubviews() {
        view.addSubview(headerView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160),

            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.$facility
            .receive(on: DispatchQueue.main)
            .sink { [weak self] facility in
                self?.headerView.configure(with: facility)
            }
            .store(in: &cancellables)

        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                self?.showError(msg)
            }
            .store(in: &cancellables)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: – UITableViewDataSource

extension FacilityDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ItemCell.reuseID,
            for: indexPath
        ) as! ItemCell
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
}

// MARK: – UITableViewDelegate

extension FacilityDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let item = viewModel.items[indexPath.row]

        let delete = UIContextualAction(style: .destructive,
                                        title: "Delete") { _, _, cb in
            self.viewModel.deleteItem(item)
            cb(true)
        }

        let transfer = UIContextualAction(style: .normal,
                                          title: "Transfer") { _, _, cb in
            self.presentTransfer(for: item)
            cb(true)
        }
        transfer.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [delete, transfer])
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        let vm = ItemDetailViewModel(item: item)
        let vc = ItemDetailViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func presentTransfer(for item: Item) {
        // Fetch all other facilities
        let all = (try? PersistenceService.shared.fetchFacilities()) ?? []
        let alert = UIAlertController(title: "Transfer Item",
                                      message: "Choose destination",
                                      preferredStyle: .actionSheet)
        for fac in all where fac.id != facility.id {
            alert.addAction(.init(
                title: fac.name,
                style: .default) { _ in
                self.viewModel.transferItem(item, to: fac.id)
            })
        }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: – FacilityHeaderViewDelegate

extension FacilityDetailViewController: FacilityHeaderViewDelegate {
    func didTapEdit(_ header: FacilityHeaderView) {
        let editVM = FacilityCreateViewModel(existing: viewModel.facility)
        let editVC = FacilityCreateViewController(viewModel: editVM)
        editVC.onSave = { updated in
            self.viewModel.updateFacility(updated)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }

    func didTapDelete(_ header: FacilityHeaderView) {
        let alert = UIAlertController(
            title: "Delete Facility",
            message: "All items will be unassigned.",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Delete", style: .destructive) { _ in
            self.viewModel.deleteFacility { success in
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: – ItemCellDelegate

extension FacilityDetailViewController: ItemCellDelegate {
    func didRequestDelete(_ cell: ItemCell) {
        if let idx = tableView.indexPath(for: cell) {
            let item = viewModel.items[idx.row]
            viewModel.deleteItem(item)
        }
    }

    func didRequestTransfer(_ cell: ItemCell) {
        if let idx = tableView.indexPath(for: cell) {
            presentTransfer(for: viewModel.items[idx.row])
        }
    }
}
