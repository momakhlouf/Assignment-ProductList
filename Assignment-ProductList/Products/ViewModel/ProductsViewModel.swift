//
//  ProductsViewModel.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 29/10/2024.
//

import Foundation
import Combine

class ProductsViewModel: ObservableObject{
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var hasMoreData = true
    @Published var isFetchingMore = false 
    @Published var errorMessage: String?
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
        guard networkManager.isConnected else {
            errorMessage = "No internet connection."
            return
        }
        productService.fetchProducts(limit: currentPage + limit)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.isFetchingMore = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
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
                }
            })
            .store(in: &cancellables)
    }
    func fetchMoreProducts(currentProduct: Product) {
            guard hasMoreData, !isFetchingMore else { return }
            fetchProducts(isInitialLoad: false)
        }
}
