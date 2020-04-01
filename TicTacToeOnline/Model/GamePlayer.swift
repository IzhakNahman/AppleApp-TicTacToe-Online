//
//  GamePlayer.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//
import Foundation

struct GamePlayer {
    
    let playerId : String
    let playerName : String
    var wantPlayAgain : Bool
    let date : Date
    var score : Int
    

    
    init(playerId : String, playerName : String) {
        //UUID - Universal Unique IDentifier
        self.playerId = playerId
        self.playerName = playerName
        self.wantPlayAgain = false
        self.date = Date()
        self.score = 0
    }
    
    init?(_ dict : [String:Any]) {
        
       // print(dict)
        
        
        guard let score = dict["score"] as? Int,
            let playerId = dict["playerId"] as? String,
            let playerName = dict["playerName"] as? String,
            let wantPlayAgain = dict["wantPlayAgain"] as? Bool,
            let date = dict["date"] as? TimeInterval else{
                return nil
        }
        
        
        self.score = score
        self.playerId = playerId
        self.playerName = playerName
        self.wantPlayAgain = wantPlayAgain
        self.date = Date(timeIntervalSince1970: date)

    }
    
    var dictionaryRepresentation : [String:Any] {
        return [
            "score":score,
            "playerId":playerId,
            "playerName":playerName,
            "wantPlayAgain":wantPlayAgain,
            "date":date.timeIntervalSince1970
        ]
    }
}
