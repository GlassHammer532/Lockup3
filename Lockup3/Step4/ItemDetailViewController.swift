//
//  ItemDetailViewController.swift
//  Lockup
//

import UIKit
import Combine

class ItemDetailViewController: UIViewController {
    private let viewModel: ItemDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ItemDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.item.name
        view.backgroundColor = .systemBackground
    }
}
