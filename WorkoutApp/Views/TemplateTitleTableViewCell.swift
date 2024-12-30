//
//  TemplateTitleTableViewCell.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/28/24.
//

import UIKit

protocol TemplateTitleTableViewCellDelegate: AnyObject {
    func templateTitleTableViewCell(_ cell: TemplateTitleTableViewCell, titleTextFieldDidChange title: String)
}

class TemplateTitleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TemplateTitleTableViewCell"
    
    var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Push Day"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    weak var delegate: TemplateTitleTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleTextField.addAction(titleTextFieldDidChange(), for: .editingChanged)
        
        contentView.addSubview(titleTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String) {
        titleTextField.text = title
    }
    
    func titleTextFieldDidChange() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self, let titleText = titleTextField.text else { return }
            delegate?.templateTitleTableViewCell(self, titleTextFieldDidChange: titleText)
        }
    }
}
