//
//  DesignButton.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class DesignedButton: UIButton {
    
    
    required init?(coder: NSCoder) {
        super.init(coder : coder)
        setup()
    }
    
    private func setup(){
        self.layer.borderWidth = 2
        //self.layer.borderColor = .init(srgbRed: 0/255, green: 150/255, blue: 237/255, alpha: 1)
        self.layer.borderColor = self.titleLabel?.textColor.cgColor
        self.layer.cornerRadius = self.frame.width
        // self.titleLabel?.font = self.titleLabel?.font.withSize(22)
    }
    
    
    
    
}
