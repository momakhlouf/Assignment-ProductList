//
//  ContentUnavailableViewController.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 31/10/2024.
//

import UIKit

class ContentUnavailableViewController: UIViewController {

    @IBOutlet weak var unavailableMessage: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var fetchProducts: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func RetryButtonPressed(_ sender: Any) {
        fetchProducts?()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
