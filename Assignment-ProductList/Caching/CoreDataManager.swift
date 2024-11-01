//
//  CoreDataManager.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 30/10/2024.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    private init() {
        persistentContainer = NSPersistentContainer(name: "Products")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    func saveProducts(_ products: [Product]) {
        let context = persistentContainer.viewContext
        products.forEach { product in
            let entity = CachedProducts(context: context)
            entity.id = Int64(product.id ?? 0)
            entity.title = product.title
            entity.price = product.price ?? 0.0
            entity.information = product.description
            entity.category = product.category?.rawValue
            entity.image = product.image
            entity.rate = product.rating?.rate ?? 0
            entity.rateCount = Int64(product.rating?.count ?? 0)
        }
        try? context.save()
    }
    
    func fetchCachedProducts() -> [Product] {
           let request: NSFetchRequest<CachedProducts> = CachedProducts.fetchRequest()
           guard let entities = try? persistentContainer.viewContext.fetch(request) else { return [] }
           
           return entities.map { entity in
               return Product(
                   id: Int(entity.id),
                   title: entity.title,
                   price: entity.price,
                   description: entity.information,
                   category: Category(rawValue: entity.category ?? ""),
                   image: entity.image,
                   rating: Rating(rate: entity.rate, count: Int(entity.rateCount))
               )
           }
       }
}
