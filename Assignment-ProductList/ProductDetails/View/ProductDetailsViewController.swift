//
//  ProductDetailsViewController.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 30/10/2024.
//

import UIKit
import Kingfisher
class ProductDetailsViewController: UIViewController {
    @IBOutlet weak var productRateCount: UILabel!
    @IBOutlet weak var productRate: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    private var product: Product?
    init(product: Product) {
        self.product = product
        super.init(nibName: "ProductDetailsViewController", bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        guard let product = product else { return }
        productTitle.text = product.title
        productPrice.text = String(format: "$%.2f", product.price ?? 0)
        productRate.text = "★\(product.rating?.rate ?? 0)"
        productRateCount.text = "(\(product.rating?.count ?? 0))"
        productDescription.text = product.description
        productCategory.text = product.category?.rawValue
        if let imageUrl = product.image {
            productImage.kf.setImage(with: URL(string: imageUrl))
        }
    }
}
