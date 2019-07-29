//
//  RaitingStack.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 27/07/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import UIKit

@IBDesignable class RaitingStack: UIStackView {
    
    // MARK: Properties
    
    var rating = 0 {
        didSet {
            updateButtonSelectedState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButton()
        }
    }
    @IBInspectable var starsCount: Int = 5 {
        didSet {
            setupButton()
        }
    }
    
    // MARK: Initilization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: Button action
    
    @objc func pressRetingButton(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {return}
        
        let selecteRating = index + 1
        if selecteRating == rating {
            rating = 0
        } else  {
            rating = selecteRating
        }
    }
    
    // MARK: Private methods

    private func setupButton() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        //MARK: Load button image
        let bundle = Bundle(for: type(of: self))
        let fullStar = UIImage(named: "full", in: bundle, compatibleWith: self.traitCollection)
       // let highlightedStar = UIImage(named: "highlighted", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "empty", in: bundle, compatibleWith: self.traitCollection)
        
        ratingButtons.removeAll()
        
        for _ in 0 ..< starsCount {
            
        // Create buttons
        let button = UIButton()
            
        // Set the button image
        button.setImage(emptyStar, for: .normal)
        button.setImage(fullStar, for: .selected)
       // button.setImage(highlightedStar, for: .highlighted)
       // button.setImage(highlightedStar, for: [.highlighted, .selected])
        
        // Add constraints
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
        
        // Setup the button actions
        
        button.addTarget(self, action: #selector(pressRetingButton(button:)), for: .touchUpInside)
        
        // Add button into Stack
        
        addArrangedSubview(button)
            
        // Add button in array
            
        ratingButtons.append(button)
        }
        updateButtonSelectedState()
    }
    
    private func updateButtonSelectedState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
