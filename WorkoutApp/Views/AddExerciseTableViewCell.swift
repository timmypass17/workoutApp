//
//  AddExerciseTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/1/24.
//

import UIKit

protocol AddExerciseTableViewCellDelegate: AnyObject {
//    func addExerciseTableViewCell(_ cell: AddExerciseTableViewCell, didUpdatePlanItem planItem: PlanItem)
}

class AddExerciseTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AddExerciseCell"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var exerciseTitleTextField: UITextField!
    var setsTextField: UITextField!
    var repsTextField: UITextField!
    var weightTextField: UITextField!
    
    weak var delegate: AddExerciseTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func update(with item: PlanItem) {
//        exerciseTitleTextField.text = item.title
//        setsTextField.text = item.sets
//        repsTextField.text = item.reps
//        weightTextField.text = item.weight
//    }
    
    private func setupView() {
        selectionStyle = .none  // removes highlight when selecting cell
        showsReorderControl = true
        
        let textfieldEditAction = UIAction { [self] _ in
//            let title = exerciseTitleTextField.text ?? ""
//            let sets = setsTextField.text ?? ""
//            let reps = repsTextField.text ?? ""
//            let weight = weightTextField.text ?? ""
//            let item = PlanItem(entity: PlanItem.entity(), insertInto: nil)
//            item.title = title
//            item.sets = sets
//            item.reps = reps
//            item.weight = weight
//            delegate?.addExerciseTableViewCell(self, didUpdatePlanItem: item)
        }
        
        exerciseTitleTextField = UITextField()
        exerciseTitleTextField.placeholder = "Ex. Bench Press"
        exerciseTitleTextField.borderStyle = .roundedRect
        exerciseTitleTextField.addAction(textfieldEditAction, for: .allEditingEvents)
        
        setsTextField = UITextField()
        setsTextField.placeholder = "3"
        setsTextField.borderStyle = .roundedRect
        setsTextField.textAlignment = .center
        setsTextField.keyboardType = .numberPad
        setsTextField.addAction(textfieldEditAction, for: .allEditingEvents)
        
        repsTextField = UITextField()
        repsTextField.placeholder = "5"
        repsTextField.borderStyle = .roundedRect
        repsTextField.textAlignment = .center
        repsTextField.keyboardType = .numberPad
        repsTextField.addAction(textfieldEditAction, for: .allEditingEvents)

        weightTextField = UITextField()
        weightTextField.placeholder = "125" // should match prev
        weightTextField.borderStyle = .roundedRect
        weightTextField.textAlignment = .center
        weightTextField.keyboardType = .decimalPad
        weightTextField.addAction(textfieldEditAction, for: .allEditingEvents)

        let hstack = UIStackView(arrangedSubviews: [exerciseTitleTextField, setsTextField, repsTextField, weightTextField])
        hstack.axis = .horizontal
        hstack.distribution = .fillProportionally
        hstack.spacing = 8
                
        contentView.addSubview(hstack)  // doing addSubview doesnt let textfield editable
        
        hstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
}

#Preview {
    AddExerciseTableViewCell()
}
