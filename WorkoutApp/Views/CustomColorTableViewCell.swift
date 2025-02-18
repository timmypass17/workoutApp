//
//  CustomColorTableViewCell.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 2/17/25.
//

import UIKit

protocol CustomColorTableViewCellDelegate: AnyObject {
    func customColorTableViewCell(_ cell: CustomColorTableViewCell, didSelectCustomColor color: UIColor)
}

class CustomColorTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CustomColorTableViewCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Custom"
        return label
    }()
    
    let colorWell: UIColorWell = {
        let colorWell = UIColorWell()
        colorWell.supportsAlpha = true
        colorWell.selectedColor = nil
        colorWell.title = "Color Well"
        colorWell.isUserInteractionEnabled = true

        return colorWell
    }()
    
    let container: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    weak var delegate: CustomColorTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        colorWell.addAction(didSelectColor(), for: .valueChanged)
        
        container.addArrangedSubview(label)
        container.addArrangedSubview(colorWell)
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(selectedColor: UIColor) {
        colorWell.selectedColor = selectedColor
    }
    
    func didSelectColor() -> UIAction {
        return UIAction { _ in
            guard let selectedColor = self.colorWell.selectedColor else { return }
            self.delegate?.customColorTableViewCell(self, didSelectCustomColor: selectedColor)
        }
    }
}
