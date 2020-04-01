//
//  LeaderboardCell.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//


import UIKit

class LeaderboardCell: UITableViewCell {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var winRateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    override func awakeFromNib() {
          super.awakeFromNib()
          self.selectionStyle = .none
      }
      
      func populate(with user : GameUser) {
        
        nicknameLabel.text = user.userName
        winRateLabel.text = "\(user.winRate())"
        scoreLabel.text = "\(user.score)"
        
        guard let userId = FirebaseManager.manager.userId, userId == user.userId else {
            return
        }
        nicknameLabel.text =  (nicknameLabel.text ?? "") + "(Me)"
        nicknameLabel.font = UIFont.boldSystemFont(ofSize: nicknameLabel.font.pointSize)
        winRateLabel.font = UIFont.boldSystemFont(ofSize: winRateLabel.font.pointSize)
        scoreLabel.font = UIFont.boldSystemFont(ofSize: scoreLabel.font.pointSize)
        
        self.backgroundColor = .systemBlue
        
        
      }
    

}
