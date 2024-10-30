//
//  NetworkManager.swift
//  Assignment-ProductList
//
//  Created by Mohamed Makhlouf Ahmed on 30/10/2024.
//

import Foundation
import Network

class NetworkManager {
    private let monitor = NWPathMonitor()
    var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
