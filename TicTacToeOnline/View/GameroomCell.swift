//
//  GameroomCell.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class GameroomCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var isOpenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func populate(with room : Gameroom) {
        nameLabel?.text = room.title
        ownerNameLabel.text = "Created by: \(room.ownerName)"
        quantityLabel.text = "\(room.playersQuantity)/2"
        
        if room.isOpen {
             isOpenLabel.text = "open"
            isOpenLabel.textColor = .systemGreen
        }else{
            isOpenLabel.text = "close"
            isOpenLabel.textColor = .systemRed
        }
        self.backgroundColor = UIColor.random
    }

}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0.1...0.9),
                       green: .random(in: 0.1...0.9),
                       blue: .random(in: 0.1...0.9),
                       alpha: 0.1)
    }
}
