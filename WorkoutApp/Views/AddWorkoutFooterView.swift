//
//  AddExerciseButtonView.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/2/24.
//

import UIKit

protocol AddWorkoutFooterViewDelegate: AnyObject {
    func didTapAddExerciseButton(_ sender: UIButton)
}

class AddWorkoutFooterView: UIView {
    
    private let addExerciseButton: UIButton = {
        let button = UIButton(configuration: .tinted())
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitle("Add Exercise", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: AddWorkoutFooterViewDelegate?
    var title: String!
    
    init(title: String) {
        super.init(frame: .zero)
        self.title = title
        
        addSubview(addExerciseButton)
        
        NSLayoutConstraint.activate([
            addExerciseButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            addExerciseButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            addExerciseButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            addExerciseButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    AddWorkoutFooterView(title: "Add Exercise")
}
