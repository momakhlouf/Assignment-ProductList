//
//  ProductCell.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 29/10/2024.
//

import UIKit
import Kingfisher

class ProductCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var roundedView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        roundedView.layer.cornerRadius = 8
        roundedView.layer.masksToBounds = false
        roundedView.layer.shadowColor = UIColor.black.cgColor
        roundedView.layer.shadowOffset = CGSize(width: 23, height: 5)
        roundedView.layer.frame.inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    func configureCell(with product: Product?) {
        guard let product = product else {return}
        productTitle.text = product.title
        productCategory.text = product.category?.rawValue
        productPrice.text = String(format: "$%.2f", product.price ?? 0)
        let url = URL(string: product.image ?? "")
        productImage.kf.setImage(with: url)
    }
}
