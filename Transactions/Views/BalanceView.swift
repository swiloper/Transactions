//
//  BalanceView.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import UIKit

final class BalanceView: UIView {
    
    // MARK: - Subviews
    
    lazy private var balanceVerticalStackView: UIStackView = {
        stack(axis: .vertical)
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Balance"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bitcoinAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "0.000461 BTC"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var horizontalStackView: UIStackView = {
        stack(axis: .horizontal, spacing: 12)
    }()
    
    let replenishBitcoinsButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .medium
        
        configuration.title = "Replenish"
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    lazy private var dividerVerticalStack: UIStackView = {
        stack(axis: .vertical, spacing: 16)
    }()
    
    lazy private var topSeparator: UIView = {
        separator()
    }()
    
    lazy private var bottomSeparator: UIView = {
        separator()
    }()
    
    lazy private var addTransactionVerticalStack: UIStackView = {
        stack(axis: .vertical, spacing: 16)
    }()
    
    let addTransactionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .medium
        
        configuration.image = UIImage(systemName: "plus.circle")
        configuration.imagePadding = 6
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        configuration.title = "Add transaction"
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        horizontalStackView.addArrangedSubview(bitcoinAmountLabel)
        horizontalStackView.addArrangedSubview(replenishBitcoinsButton)
        
        balanceVerticalStackView.addArrangedSubview(balanceLabel)
        balanceVerticalStackView.addArrangedSubview(horizontalStackView)
        
        dividerVerticalStack.addArrangedSubview(topSeparator)
        dividerVerticalStack.addArrangedSubview(balanceVerticalStackView)
        dividerVerticalStack.addArrangedSubview(bottomSeparator)
        dividerVerticalStack.backgroundColor = .row
        
        addTransactionVerticalStack.addArrangedSubview(dividerVerticalStack)
        addTransactionVerticalStack.addArrangedSubview(addTransactionButton)
        
        addSubview(addTransactionVerticalStack)
        
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Separator
    
    private func separator() -> UIView {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    // MARK: - Stack
    
    private func stack(axis: NSLayoutConstraint.Axis, spacing: CGFloat = .zero) -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = axis
        view.spacing = spacing
        return view
    }
    
    // MARK: - Constraints
    
    private func constraints() {
        NSLayoutConstraint.activate([
            balanceLabel.heightAnchor.constraint(equalToConstant: 16),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 38),
            replenishBitcoinsButton.widthAnchor.constraint(equalToConstant: 120),
            
            topSeparator.leadingAnchor.constraint(equalTo: dividerVerticalStack.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: dividerVerticalStack.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            balanceVerticalStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            balanceVerticalStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            bottomSeparator.leadingAnchor.constraint(equalTo: dividerVerticalStack.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: dividerVerticalStack.trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            dividerVerticalStack.leadingAnchor.constraint(equalTo: addTransactionVerticalStack.leadingAnchor),
            
            addTransactionButton.heightAnchor.constraint(equalToConstant: 42),
            addTransactionButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addTransactionButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            addTransactionVerticalStack.topAnchor.constraint(equalTo: topAnchor),
            addTransactionVerticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            addTransactionVerticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            addTransactionVerticalStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
