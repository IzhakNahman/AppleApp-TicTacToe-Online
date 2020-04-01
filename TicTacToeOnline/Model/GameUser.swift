//
//  gameUser.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import Foundation


struct GameUser {
    
    let userId : String
    let userName : String
    var score : Int
    let date : Date
    var wins : Int
    var losses : Int
    var draws : Int
    var isOnline : Bool
    

    
    init(userId : String, userName : String) {
        //UUID - Universal Unique IDentifier
        self.userId = userId
        self.userName = userName
        self.isOnline = true
        self.date = Date()
        self.score = 0
        self.wins = 0
        self.losses = 0
        self.draws = 0
    }
    
    init?(_ dict : [String:Any]) {
        
        //print(dict)
        
        
        guard let userId = dict["userId"] as? String,
            let userName = dict["userName"] as? String,
            let score = dict["score"] as? Int,
            let wins = dict["wins"] as? Int,
            let losses = dict["losses"] as? Int,
            let draws = dict["draws"] as? Int,
            let isOnline = dict["isOnline"] as? Bool,
            let date = dict["date"] as? TimeInterval else{
                return nil
        }
        
        
        self.userId = userId
        self.userName = userName
        self.isOnline = isOnline
        self.score = score
        self.wins = wins
        self.losses = losses
        self.draws = draws
        self.date = Date(timeIntervalSince1970: date)

    }
    
    var dictionaryRepresentation : [String:Any] {
        return [
            "userId":userId,
            "userName":userName,
            "score":score,
            "wins":wins,
            "losses":losses,
            "draws":draws,
            "isOnline":isOnline,
            "date":date.timeIntervalSince1970
        ]
    }
    
    
    
    func winRate() -> String{
        
        let sum = Double(wins + draws + losses)
        guard sum > 0 else {
            return "0%"
        }
        
        let str = String(format: "%.2f%%", Double(Double(wins) / Double(sum)))

        return str
    }
}
