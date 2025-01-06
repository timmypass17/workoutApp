//
//  EditTemplateViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/6/25.
//

import UIKit

protocol EditTemplateViewControllerDelegate: AnyObject {
    func editTemplateViewController(_ viewController: EditTemplateViewController, didUpdateTemplate template: Template)
}

class EditTemplateViewController: TemplateViewController {

    weak var delegate: EditTemplateViewControllerDelegate?

    init(template: Template) {
        let childContext = CoreDataStack.shared.newChildContext()
        let objectInNewContext = childContext.object(with: template.objectID) as! Template
        super.init(template: objectInNewContext, childContext: childContext)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Workout"
        navigationItem.rightBarButtonItems?.insert(UIBarButtonItem(systemItem: .save, primaryAction: didTapSaveButton()), at: 0)
        updateSaveButton()
    }
    
    func didTapSaveButton() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self else { return }
            delegate?.editTemplateViewController(self, didUpdateTemplate: template)
            self.dismiss(animated: true)
        }
    }

}
