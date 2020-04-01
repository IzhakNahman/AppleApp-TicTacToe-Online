//
//  ChatCell.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        contentLabel.layer.cornerRadius = contentLabel.frame.height / 6
        contentLabel.isEditable = false
    }
    
    
    func populate(with message : ChatMessage) {
        
        
        if fromLabel != nil {
            fromLabel?.text = message.authorName + ":"
        }
        
        contentLabel.text = message.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: message.date)
    }
    
    
    
}
