//
//  SendButton.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//


import UIKit

class SendButton: UIButton {

     required init?(coder: NSCoder) {
          super.init(coder : coder)
          setup()
      }
      
      private func setup(){
          self.layer.cornerRadius = 4
      }
      
      

}
