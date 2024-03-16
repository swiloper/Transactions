//
//  MainViewController.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    // MARK: - BitcoinCurrentRateLabel
    
    private let bitcoinCurrentRateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        // Sets label text if rate is available in user defaults.
        if let rate = UserDefaults.standard.string(forKey: UserDefaults.Keys.bitcoinRate.rawValue) {
            label.text = "BTCUSD " + rate
        }
        
        return label
    }()
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - viewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isPriceShouldBeUpdated() {
            Task {
                await fetchBitcoinCurrentPrice()
            }
        }
    }
    
    // MARK: - Setup
    
    /// Setups view and navigation bar appearance.
    private func setup() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bitcoinCurrentRateLabel)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    
    // MARK: - IsPriceShouldBeUpdated
    
    /// Checks if Bitcoin price needs to be updated based on last update time.
    private func isPriceShouldBeUpdated() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss zzz"
        
        if let updated = UserDefaults.standard.string(forKey: UserDefaults.Keys.lastPriceUpdate.rawValue), let date = formatter.date(from: updated) {
            let now = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour], from: date, to: now)
            
            // Allows updating the Bitcoin price only if the last rate update time value is present in user defaults and the difference between it and the current time is more than one hour.
            if let hours = components.hour {
                return hours > 1
            }
        }
        
        return true
    }
    
    // MARK: - FetchBitcoinCurrentPrice
    
    /// Gets current Bitcoin price asynchronously.
    private func fetchBitcoinCurrentPrice() async {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        
        do {
            let response = try await NetworkService.shared.request(link: EndpointPath.currentBitcoinPrice, method: .get, decode: BitcoinCurrentPriceResponse.self)
            let rate = response.price.dollar.rate
            
            // Saves rate and last updated time received from response.
            save(rate, response.time.updated)
            bitcoinCurrentRateLabel.text = "BTCUSD " + rate
        } catch {
            // Resets saved rate and last updated time in user defaults.
            save()
            bitcoinCurrentRateLabel.text = "Failure"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bitcoinCurrentRateLabel)
    }
    
    // MARK: - Save
    
    /// Saves Bitcoin rate and last update time to user defaults.
    private func save(_ rate: String? = nil, _ updated: String? = nil) {
        UserDefaults.standard.set(rate, forKey: UserDefaults.Keys.bitcoinRate.rawValue)
        UserDefaults.standard.set(updated, forKey: UserDefaults.Keys.lastPriceUpdate.rawValue)
    }
}
