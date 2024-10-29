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
    private var cancellables = Set<AnyCancellable>()
    private let productService: ProductService
    private var limit = 7
    private var currentPage = 0
    
    init(service: ProductService){
        self.productService = service
        fetchProducts()
    }
    
    private func fetchProducts() {
          isLoading = true
          productService.fetchProducts(limit: currentPage + limit)
              .sink(receiveCompletion: { [weak self] completion in
                  self?.isLoading = false
                  if case .failure(_) = completion {
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
}
