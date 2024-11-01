//
//  ProductsViewModel.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 29/10/2024.
//

import Foundation
import Combine
import CoreData

class ProductsViewModel: ObservableObject{
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var hasMoreData = true
    @Published var isFetchingMore = false
    @Published var errorMessage: String?
    private let context = CoreDataManager.shared.persistentContainer.viewContext

    private let networkManager = NetworkManager()
    
    private var cancellables = Set<AnyCancellable>()
    private let productService: ProductService
    private var limit = 7
    private var currentPage = 0
    
    init(service: ProductService){
        self.productService = service
        fetchProducts(isInitialLoad: true)
    }
    func fetchProducts(isInitialLoad: Bool) {
        if isInitialLoad{
            isLoading = true
        }else {
            isFetchingMore = true
        }
        productService.fetchProducts(limit: currentPage + limit)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.isFetchingMore = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.products = CoreDataManager.shared.fetchCachedProducts()
                    print("from core data")
                    self?.errorMessage = error.localizedDescription
                    self?.hasMoreData = false
                }
            }, receiveValue: { [weak self] returnedProducts in
                guard let self = self else { return }
                let filteredProducts = returnedProducts.filter { product in
                    !self.products.contains(where: { $0.id == product.id })
                }
                if filteredProducts.isEmpty {
                    self.hasMoreData = false
                } else {
                    self.products.append(contentsOf: filteredProducts)
                    self.currentPage += self.limit
                    CoreDataManager.shared.saveProducts(filteredProducts)
                }
            })
            .store(in: &cancellables)
    }
    func fetchMoreProducts(currentProduct: Product) {
        guard hasMoreData, !isFetchingMore else { return }
        fetchProducts(isInitialLoad: false)
    }
}
