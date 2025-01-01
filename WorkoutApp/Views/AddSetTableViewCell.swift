//
//  AddSetTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/12/24.
//

import UIKit

protocol AddSetTableViewCellDelegate: AnyObject {
    func didTapAddSetButton(_ sender: AddSetTableViewCell)
}

class AddSetTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AddSetTableViewCell"
    
    private let addButton: UIButton  = {
        let button = UIButton(configuration: .tinted())
        button.titleLabel?.text = "Add Set"
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: AddSetTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let addAction = UIAction { [self] _ in
            delegate?.didTapAddSetButton(self)
        }
        addButton.addAction(addAction, for: .touchUpInside)
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String) {
        addButton.setTitle(title, for: .normal)
    }
    
}
