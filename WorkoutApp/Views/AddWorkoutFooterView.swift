//
//  AddExerciseButtonView.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/2/24.
//

import UIKit

protocol AddExerciseFooterViewDelegate: AnyObject {
    func didTapAddExerciseButton(_ sender: UIButton)
}

class AddExerciseFooterView: UIView {
    
    private let addExerciseButton: UIButton = {
        let button = UIButton(configuration: .tinted())
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitle("Add Exercise", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: AddExerciseFooterViewDelegate?
    var title: String!
    
    init() {
        super.init(frame: .zero)
        let addAction = UIAction { [self] _ in
            delegate?.didTapAddExerciseButton(addExerciseButton)
        }
        addExerciseButton.addAction(addAction, for: .touchUpInside)
        
        addSubview(addExerciseButton)
        
        NSLayoutConstraint.activate([
            addExerciseButton.topAnchor.constraint(equalTo: topAnchor),
            addExerciseButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            addExerciseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            addExerciseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    AddExerciseFooterView()
}
