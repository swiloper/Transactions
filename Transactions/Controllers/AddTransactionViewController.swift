//
//  AddTransactionViewController.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 17.03.2024.
//

import UIKit

/// Transfers data to create a new transaction between controllers.
protocol AddTransactionDelegate: AnyObject {
    func addTransaction(amount: Double, type: TransactionType, category: ExpenseCategory?)
}

final class AddTransactionViewController: UIViewController {
    
    // MARK: - Field
    
    let amountField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter amount in BTC"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 6.0
        return textField
    }()
    
    // MARK: - Category
    
    private let categoryButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.imagePadding = 6
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        configuration.title = "Category"
        configuration.cornerStyle = .medium
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Actions
    
    /// Displays a menu options with the ability to select a category.
    var actions: [UIAction] {
        return ExpenseCategory.allCases.map { category in
            let title = category.rawValue.capitalized
            
            return UIAction(title: title, image: category.icon) { [weak self] _ in
                self?.categoryButton.configuration?.title = title
                self?.categoryButton.configuration?.image = category.icon
                self?.categoryButton.tintColor = .accent
            }
        }
    }
    
    // MARK: - Menu
    
    var menu: UIMenu {
        UIMenu(title: "Choose transaction category.", image: nil, identifier: nil, options: [], children: actions)
    }
    
    // MARK: - Toolbar
    
    /// Toolbar for the keyboard with an end input button, since it is missing for decimal pad keyboard type.
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 35)))
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .accent
        toolbar.sizeToFit()
        
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done(sender:)))
        
        toolbar.setItems([spacer, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    // MARK: - Done
    
    /// End editing of amount field.
    @objc func done(sender: UIBarButtonItem) {
        amountField.resignFirstResponder()
    }
    
    // MARK: - Add
    
    let addButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .medium
        
        configuration.title = "Add"
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    weak var delegate: AddTransactionDelegate?
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        constraints()
    }
    
    /// Returns the amount of bitcoins entered by the user in the text field or nil if the number is incorrect.
    private func amount() -> Double? {
        guard let text = amountField.text, let amount = Double(text) else { return nil }
        return amount
    }
    
    /// Returns the category selected by the user, or nothing if the user did not select one.
    private func category() -> ExpenseCategory? {
        guard let text = categoryButton.configuration?.title, let category = ExpenseCategory(rawValue: text.lowercased()) else { return nil }
        return category
    }
    
    /// Changes the appearance of the text field if the entered amount is not valid.
    private func validateAmountField() {
        amountField.layer.borderColor = amount() == nil || amount() == .zero ? UIColor.red.cgColor : UIColor.clear.cgColor
    }

    /// Changes the appearance of the button if the user has not selected a category.
    private func validateCategoryButton() {
        categoryButton.tintColor = category() != nil ? .accent : .red
    }
    
    /// Adds a new transaction to storage if all data is entered correctly.
    private func add() {
        validateAmountField()
        validateCategoryButton()
        
        if let amount = amount(), let category = category() {
            delegate?.addTransaction(amount: -amount, type: .expense, category: category)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        title = "Add transaction"
        view.backgroundColor = .systemGray6
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        view.addSubview(amountField)
        view.addSubview(categoryButton)
        view.addSubview(addButton)
        
        amountField.delegate = self
        amountField.inputAccessoryView = toolbar
        
        categoryButton.menu = menu
        categoryButton.showsMenuAsPrimaryAction = true
        
        addButton.addAction(
            UIAction { [weak self] _ in
                self?.add()
            }, for: .touchUpInside
        )
    }
    
    // MARK: - Constraints
    
    private func constraints() {
        NSLayoutConstraint.activate([
            amountField.heightAnchor.constraint(equalToConstant: 42),
            amountField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            amountField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            amountField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            categoryButton.heightAnchor.constraint(equalToConstant: 42),
            categoryButton.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 16),
            categoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            addButton.heightAnchor.constraint(equalToConstant: 42),
            addButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - UITextFieldDelegate

extension AddTransactionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        // Replace any comma with a dot.
        let updated = (text as NSString).replacingCharacters(in: range, with: string)
            .replacingOccurrences(of: ",", with: ".")
        
        textField.text = updated
        validateAmountField()
        return false
    }
}
