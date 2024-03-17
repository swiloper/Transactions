//
//  MainViewController.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var sections = [GroupedSection<Date, Transaction>]()
    
    // MARK: - TableView
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - EmptyView
    
    private let contentUnavailableView: UIContentUnavailableView = {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.image = UIImage(systemName: "list.bullet")
        configuration.text = "Empty"
        configuration.secondaryText = "List of expenses and incomes is empty, you can add a transaction by clicking on the corresponding button above."
        return UIContentUnavailableView(configuration: configuration)
    }()
    
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
        constraints()
        fetchAllTransactions()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bitcoinCurrentRateLabel)
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = BalanceView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 145)))
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    
    // MARK: - Constraints
    
    private func constraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - IsPriceShouldBeUpdated
    
    /// Checks if Bitcoin price needs to be updated based on last update time.
    private func isPriceShouldBeUpdated() -> Bool {
        if let updated = UserDefaults.standard.string(forKey: UserDefaults.Keys.lastPriceUpdate.rawValue), let date = DateFormatter.full.date(from: updated) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour], from: date, to: Date.now)
            
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

// MARK: - Table

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        55
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        DateFormatter.dayMonthYear.string(from: sections[section].headline)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        
        if let value = transaction.category, let category = Category(rawValue: value), let date = transaction.date {
            configuration.image = UIImage(systemName: category.icon)
            configuration.imageProperties.tintColor = category.color
            configuration.secondaryText = "\(value.capitalized) · \(DateFormatter.time.string(from: date))"
        }
        
        configuration.text = "\(transaction.amount) BTC"
        configuration.textToSecondaryTextVerticalPadding = 2
        configuration.secondaryTextProperties.color = .gray
        
        cell.contentConfiguration = configuration
        
        return cell
    }
}

// MARK: - Transactions

extension MainViewController {
    
    // MARK: - Fetch
    
    private func fetchAllTransactions() {
        do {
            let transactions = try context.fetch(Transaction.fetchRequest())
            
            sections = GroupedSection.group(rows: transactions) {
                guard let from = $0.date, let day = Date.day(from: from) else { return Date.now }
                return day
            } sorted: {
                guard let first = $0.date, let second = $1.date else { return false }
                return first > second
            }

            sections.sort(by: { $0.headline > $1.headline })
            
            tableView.backgroundView = sections.isEmpty ? contentUnavailableView : nil
            tableView.isScrollEnabled = !sections.isEmpty
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Add
    
    private func addTransaction(amount: Double, category: Category) {
        let new = Transaction(context: context)
        new.id = UUID().uuidString
        new.amount = amount
        new.category = category.rawValue
        new.date = Date.now
        
        do {
            try context.save()
            fetchAllTransactions()
        } catch {
            print(error.localizedDescription)
        }
    }
}
