//
//  newButton.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class NewButton: UIButton {

        override init(frame: CGRect) {
           super.init(frame : frame)
           setup()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder : coder)
           setup()
       }
    
    private func setup(){
        
        self.layer.borderWidth = 2
        self.layer.borderColor = self.titleColor(for: .normal)?.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
    

}
