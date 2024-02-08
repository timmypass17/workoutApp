//
//  EmptyLabel.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/7/24.
//

import UIKit

class EmptyLabel: UILabel {

    convenience init(text: String) {
        self.init()
        self.text = text
        textAlignment = .center
        textColor = .secondaryLabel
        font = UIFont.systemFont(ofSize: 18)
        numberOfLines = 0
    }
    
}
