//
//  MainViewController.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import UIKit

final class MainViewController: UIViewController, AddTransactionDelegate {
    
    // MARK: - Properties
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /// Specifies the number of transactions that should be fetched from the storage at a time.
    private var paginationLimit: Int = 20
    
    /// Defines the place in the array of all transactions from which pagination continues.
    private var currentOffset: Int = .zero
    
    /// Stops pagination if all transactions have been received.
    private var isAllTransactionReceived: Bool = false
    
    /// Sections with transactions grouped by day.
    private var sections = [GroupedSection<Date, Transaction>]()
    
    /// Transactions from all sections.
    private var rows: [Transaction] {
        sections.reduce([], { $0 + $1.rows })
    }
    
    // MARK: - BalanceView
    
    private let balanceView = BalanceView(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 145)))
    
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
    
    // MARK: - BitcoinCurrentRateStack
    
    lazy private var bitcoinCurrentRateHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        
        let icon = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.white, .orange]).applying(UIImage.SymbolConfiguration(scale: .large)))
        
        stack.addArrangedSubview(UIImageView(image: icon))
        stack.addArrangedSubview(bitcoinCurrentRateLabel)
        
        return stack
    }()
    
    // MARK: - BitcoinCurrentRateLabel
    
    lazy private var bitcoinCurrentRateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        // Sets label text if rate is more than zero.
        if getBitcoinData().rate > .zero, let formattedRate = NumberFormatter.bitcoinAmount(maximumFractionDigits: 2).string(from: NSNumber(value: getBitcoinData().rate)) {
            label.text = "\(formattedRate) USD"
        }
        
        return label
    }()
    
    // MARK: - ReplenishAlert
    
    lazy private var replenishAlert: UIAlertController = {
        let alert = UIAlertController(title: "Replenish", message: "Enter the amount of bitcoins you would like to deposit.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter amount in BTC"
            textField.keyboardType = .decimalPad
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(title: "Done", style: .default) { [weak self] _ in
                if let textFields = alert.textFields, let first = textFields.first, let text = first.text, let amount = Double(text) {
                    self?.addTransaction(amount: amount, category: .income)
                }
            }
        )
        
        if let index = alert.actions.firstIndex(where: { $0.title == "Done" }) {
            alert.actions[index].isEnabled = false
        }
        
        return alert
    }()
        
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        constraints()
        fetchTransactions(withPagination: true, limit: paginationLimit, offset: currentOffset)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bitcoinCurrentRateHorizontalStack)
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        balanceView.frame.size.width = view.frame.width
        
        if let formattedAmount = NumberFormatter.bitcoinAmount().string(from: NSNumber(value: getBitcoinData().balance)) {
            balanceView.bitcoinAmountLabel.text = "\(formattedAmount) BTC"
        }
        
        balanceView.replenishBitcoinsButton.addTarget(self, action: #selector(showReplenishAlert), for: .touchUpInside)
        balanceView.addTransactionButton.addTarget(self, action: #selector(showAddTransactionViewController), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = balanceView
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    
    // MARK: - ShowReplenishAlert
    
    @objc private func showReplenishAlert() {
        if let textFields = replenishAlert.textFields, let first = textFields.first, let index = replenishAlert.actions.firstIndex(where: { $0.title == "Done" }) {
            first.text = .empty
            replenishAlert.actions[index].isEnabled = false
        }
        
        present(replenishAlert, animated: true)
    }
    
    // MARK: - ShowAddTransactionViewController
    
    @objc private func showAddTransactionViewController() {
        let addTransactionViewController = AddTransactionViewController()
        addTransactionViewController.delegate = self
        navigationController?.pushViewController(addTransactionViewController, animated: true)
    }
    
    // MARK: - AlertTextFieldDidChange
    
    @objc private func alertTextFieldDidChange(_ sender: UITextField) {
        var isEnabled = false
        
        if let text = sender.text {
            sender.text = text.replacingOccurrences(of: ",", with: ".")
            let amount = Double(text)
            isEnabled = !(amount == nil || amount == .zero)
        }
        
        if let index = replenishAlert.actions.firstIndex(where: { $0.title == "Done" }) {
            replenishAlert.actions[index].isEnabled = isEnabled
        }
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
        if let date = getBitcoinData().lastUpdate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour], from: date, to: Date.now)
            
            // Allows updating the Bitcoin price only if the last rate update time value is present in storage and the difference between it and the current time is more than one hour.
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
            save(rate, DateFormatter.full.date(from: response.time.updated))
            
            if let formattedRate = NumberFormatter.bitcoinAmount(maximumFractionDigits: 2).string(from: NSNumber(value: getBitcoinData().rate)) {
                bitcoinCurrentRateLabel.text = "\(formattedRate) USD"
            }
        } catch {
            // Resets saved rate and last updated time in storage.
            save()
            bitcoinCurrentRateLabel.text = "Failure"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bitcoinCurrentRateHorizontalStack)
    }
    
    // MARK: - Save
    
    /// Saves Bitcoin rate and last update time to storage.
    private func save(_ rate: Double = .zero, _ updated: Date? = nil) {
        getBitcoinData().rate = rate
        getBitcoinData().lastUpdate = updated
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
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
        cell.selectionStyle = .none
        
        var configuration = cell.defaultContentConfiguration()
        
        if let value = transaction.category, let category = Category(rawValue: value), let date = transaction.date, let image = category.icon {
            configuration.image = image
            configuration.imageProperties.tintColor = category.color
            configuration.secondaryText = "\(value.capitalized) · \(DateFormatter.time.string(from: date))"
        }
        
        if let formattedAmount = NumberFormatter.bitcoinAmount().string(from: NSNumber(value: transaction.amount)) {
            configuration.text = formattedAmount
        }
        
        configuration.textProperties.color = transaction.amount > .zero ? .systemGreen : .label
        configuration.textToSecondaryTextVerticalPadding = 2
        configuration.secondaryTextProperties.color = .gray
        
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isAllTransactionReceived, indexPath.section == sections.indices.last, let section = sections.last, indexPath.row == section.rows.indices.last {
            currentOffset += 1
            fetchTransactions(withPagination: true, limit: paginationLimit, offset: currentOffset)
        }
    }
}

// MARK: - Transactions

extension MainViewController {
    
    // MARK: - Fetch
    
    private func fetchTransactions(withPagination: Bool = false, limit: Int, offset: Int = .zero) {
        let request = Transaction.fetchRequest()
        request.fetchLimit = limit
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)] // Sort transactions from oldest to newest.
        request.fetchOffset = offset * limit // Shifts the starting point of transaction retrieval depending on the parameter passed to the function.
        
        do {
            let transactions = try context.fetch(request)
            
            if transactions.isEmpty {
                isAllTransactionReceived = true
                tableView.backgroundView = sections.isEmpty ? contentUnavailableView : nil
                tableView.isScrollEnabled = !sections.isEmpty
                return // No need to update sections or reload data.
            }
            
            let rows = withPagination ? rows + transactions : transactions
            
            sections = GroupedSection.group(rows: rows) {
                guard let from = $0.date, let day = Date.day(from: from) else { return Date.now }
                return day
            } sorted: {
                guard let first = $0.date, let second = $1.date else { return false }
                return first > second
            }

            sections.sort(by: { $0.headline > $1.headline })
            
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - GetBitcoinData
    
    private func getBitcoinData() -> Bitcoin {
        do {
            let transactions = try context.fetch(Bitcoin.fetchRequest())
            if let first = transactions.first {
                return first
            }
        } catch {
            print(error.localizedDescription)
        }
        
        let bitcoin = Bitcoin(context: context)
        bitcoin.balance = .zero
        return bitcoin
    }
    
    // MARK: - Add
    
    func addTransaction(amount: Double, category: Category) {
        let new = Transaction(context: context)
        new.amount = amount
        new.category = category.rawValue
        new.date = Date.now
        
        getBitcoinData().balance += amount
        
        if let formattedAmount = NumberFormatter.bitcoinAmount().string(from: NSNumber(value: getBitcoinData().balance)) {
            balanceView.bitcoinAmountLabel.text = "\(formattedAmount) BTC"
        }
        
        do {
            try context.save()
            fetchTransactions(limit: rows.count + 1) // Updates rows in table view without pagination, but with a limit of one more than the current number of transactions, for the newly created.
        } catch {
            print(error.localizedDescription)
        }
    }
}
