//
//  ProductsViewController.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 29/10/2024.
//

import UIKit
import Combine
import SkeletonView
class ProductsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var viewModel: ProductsViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var contentUnavailableVC: ContentUnavailableViewController = {
        let vc = ContentUnavailableViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.view.isHidden = true
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.fetchProducts = { [weak self] in
            self?.viewModel.fetchProducts(isInitialLoad:true)
        }
        return vc
    }()
    init(viewModel: ProductsViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
        setupUnavailableView()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isLoading{
            tableView.isSkeletonable = true
            tableView.showSkeleton()
        }
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProductCell", bundle: .none), forCellReuseIdentifier: "productCell")
    }
    func setupBindings(){
        viewModel.$products
            .receive(on: RunLoop.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                if products.isEmpty {
                    self.showUnavailableView(with: "No data available.")
                } else {
                    self.hideUnavailableView()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                //self?.showAlert(message: message)
                self?.showUnavailableView(with: message)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.hideUnavailableView()
                } else {
                    self.tableView.hideSkeleton()
                }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension ProductsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductCell else {
            return UITableViewCell()
        }
        let product = viewModel.products[indexPath.row]
        cell.configureCell(with: product)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            
            if !viewModel.hasMoreData {
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.tableFooterView = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = viewModel.products[indexPath.row]
        let detailVC = ProductDetailsViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 200 {
            guard let lastProduct = viewModel.products.last else { return }
            if !viewModel.isFetchingMore {
                viewModel.fetchMoreProducts(currentProduct: lastProduct)
            }
        }
    }
}

extension ProductsViewController: SkeletonTableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "productCell"
    }
}


extension ProductsViewController{
    private func setupUnavailableView() {
        addChild(contentUnavailableVC)
        view.addSubview(contentUnavailableVC.view)
        contentUnavailableVC.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            contentUnavailableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentUnavailableVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentUnavailableVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentUnavailableVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func showUnavailableView(with message: String) {
        contentUnavailableVC.view.isHidden = false
        contentUnavailableVC.unavailableMessage.text = message
    }
    private func hideUnavailableView() {
        contentUnavailableVC.view.isHidden = true
    }
    @objc private func retryFetch() {
        hideUnavailableView()
        viewModel.fetchProducts(isInitialLoad: true)
    }
}
