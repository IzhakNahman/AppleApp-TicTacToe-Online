//
//  LeaderboardViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var winRateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    var usersAray : [GameUser] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Online Games Leaderboard"
        
        self.tableView.dataSource = self
        
        setupListeners()
    }
    
    private func setupListeners(){
        
        FirebaseManager.manager.listenToNewGameUser { [weak self](user) in
            guard let self = self else {return}
            
            if user.userId == FirebaseManager.manager.userId ?? ""{
                
                self.nameLabel.text = user.userName + "(Me)"
                self.winRateLabel.text = "\(user.winRate())"
                self.scoreLabel.text = "\(user.score)"
            }
            
            
            self.usersAray.sort { (a, b) -> Bool in
                a.score > b.score
            }
            var index = 0
            if self.usersAray.count > 0{
                for i in 0...self.usersAray.count - 1 {
                    if user.score < self.usersAray[i].score  {
                        index += 1
                    }
                }
            }
            self.usersAray.insert(user, at: index)
            let rowIndexPath = IndexPath(row:index, section: 0)
            self.tableView.insertRows(at: [rowIndexPath], with: .automatic)
        }
        
        FirebaseManager.manager.listenToDeleteGameUser { [weak self](user) in
            guard let self = self else {return}
            
            let index = self.usersAray.lastIndex { (userInArray) -> Bool in
                userInArray.userId == user.userId
            }
            
            guard let newIndex : Int = index else {
                return
            }
            self.usersAray.remove(at: newIndex)
            let rowIndexPath = IndexPath(row: newIndex, section: 0)
            self.tableView.deleteRows(at: [rowIndexPath], with: .automatic)
        }
    }

}

extension LeaderboardViewController : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersAray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardCell
        cell.populate(with: usersAray[indexPath.row])
        
        return cell
    }
    
    
}

