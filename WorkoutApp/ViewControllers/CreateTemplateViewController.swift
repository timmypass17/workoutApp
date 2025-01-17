//
//  CreateTemplateTableViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/5/25.
//

import UIKit

protocol CreateTemplateViewControllerDelegate: AnyObject {
    func createTemplateViewController(_ viewController: CreateTemplateViewController, didCreateTemplate template: Template)
}

class CreateTemplateViewController: TemplateViewController {

    weak var delegate: CreateTemplateViewControllerDelegate?

    init(workoutService: WorkoutService) {
        let childContext = CoreDataStack.shared.newChildContext()
        let newTemplate = workoutService.createTemplate(childContext: childContext)
        super.init(template: newTemplate, childContext: childContext, workoutService: workoutService)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create Workout"
        navigationItem.rightBarButtonItems?.insert(UIBarButtonItem(systemItem: .save, primaryAction: didTapCreateButton()), at: 0)
        updateSaveButton()
    }
    
    func didTapCreateButton() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self else { return }
            delegate?.createTemplateViewController(self, didCreateTemplate: template)
            self.dismiss(animated: true)
        }
    }

}
