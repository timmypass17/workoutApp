//
//  WorkoutTitleTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/1/24.
//

import UIKit

protocol WorkoutTitleTableViewCellDelegate: AnyObject {
    func workoutTitleTableViewCell(_ cell: WorkoutTitleTableViewCell, didUpdateTitle title: String)
}

class WorkoutTitleTableViewCell: UITableViewCell, UITextFieldDelegate {
    static let reuseIdentifier = "WorkoutTitleCell"

    var iconImageView: UIImageView!
    var titleTextField: UITextField!
    
    let placeholderText = "Ex. Push Day"
    weak var delegate: WorkoutTitleTableViewCellDelegate?


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        
        iconImageView = UIImageView(image: UIImage(systemName: "a.circle.fill"))
        iconImageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 35),
            iconImageView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        titleTextField = UITextField()
        titleTextField.placeholder = placeholderText
        titleTextField.borderStyle = .roundedRect
        titleTextField.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        let hstack = UIStackView()
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.axis = .horizontal
        hstack.alignment = .center
        hstack.distribution = .fill
        hstack.spacing = 8
        
        hstack.addArrangedSubview(iconImageView)
        hstack.addArrangedSubview(titleTextField)
        
        contentView.addSubview(hstack)
        
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }

    @objc private func textFieldDidChange() {
        delegate?.workoutTitleTableViewCell(self, didUpdateTitle: titleTextField.text ?? "")
    }
}

#Preview {
    WorkoutTitleTableViewCell()
}
