//
//  OnlineGame.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import Foundation



struct OnlineGame {
    
    var gameState : String
    var playerTurnById : String
    var winner : String
    
    
    init(startingPlayerId : String) {
        //UUID - Universal Unique IDentifier
        self.gameState = "0,0,0,0,0,0,0,0,0"
        self.playerTurnById = startingPlayerId
        self.winner = "0"

        
    }
    
    init(playerTurnById : String, gameState : String, winner : String) {
        //UUID - Universal Unique IDentifier
        self.gameState = gameState
        self.playerTurnById = playerTurnById
        self.winner = winner
    }
    
    
    

    init?(_ dict : [String:Any]) {
       // print(dict)
        
        guard
            let playerTurnById = dict["playerTurnById"] as? String,
            let gameState = dict["gameState"] as? String,
            let winner = dict["winner"] as? String else {
                return nil
        }
        
        self.gameState = gameState
         self.playerTurnById = playerTurnById
        self.winner = winner
    }
    
    var dictionaryRepresentation : [String:Any] {
        return [
            "gameState":gameState,
            "playerTurnById":playerTurnById,
            "winner":winner
        ]
    }
}
