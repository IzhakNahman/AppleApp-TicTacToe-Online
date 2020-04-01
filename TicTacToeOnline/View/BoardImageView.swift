//
//  BoardImageView.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class BoardImageView: UIImageView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()

    }
    
    
    private func setup(){
       // let screenSize = UIScreen.main.bounds
        self.layer.borderWidth = 5
        self.layer.borderColor = .init(srgbRed: 0/255, green: 150/255, blue: 237/255, alpha: 1)
    }
}
