//
//  ProductService.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 29/10/2024.
//

import Foundation
import Combine

protocol ProductServiceProtocol {
    func fetchProducts(limit: Int) -> AnyPublisher<[Product], Error>
}
class ProductService: ProductServiceProtocol{
    private var baseURL = "https://fakestoreapi.com/products"
    func fetchProducts(limit: Int) -> AnyPublisher<[Product], Error> {
        let urlString = "\(baseURL)?limit=\(limit)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Product].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
