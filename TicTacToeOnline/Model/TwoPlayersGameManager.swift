//
//  TwoPlayersGameManager.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import Foundation

class TwoPlayersGameManager {
    
    static let game = TwoPlayersGameManager()
    
    var gameState : [Int] = [0,0,0,0,0,0,0,0,0]
    var playerturn : Int = 1 //player1 = 1, player2 = 2
    var player1 = 1
    var player1Score = 0
    var player2 = 2
    var player2Score = 0
    var currentPlayerImage = ""
    var turnsCounter = 0
    var winner = 0
    
    var winnerMoveArr : [Int] = []
    
    let winningPositions = {
        return [
            [0,1,2],
            [3,4,5],
            [6,7,8],
            [0,3,6],
            [1,4,7],
            [2,5,8],
            [0,4,8],
            [2,4,6]
        ]
    }()
    
    private init() {
        self.currentPlayerImage = playerImage(player: playerturn)
    }
    
    
    func makeStep(position p : Int) -> Int{
        
        guard gameState[p] == 0 && winner == 0 else {
            return 0
        }
        
        turnsCounter += 1
        
        gameState[p] = playerturn
        
      
        
        
        if(turnsCounter>4){ checkWinner() }
        
        playerturn = playerturn == 1 ? 2 : 1
              
        self.currentPlayerImage = playerImage(player: playerturn)

    
        return gameState[p]
    }
    
    func playerImage (player : Int) -> String {
        switch player {
            case 1:
                return "xImage"
            case 2:
                return "circleImage"
            default:
                return ""
        }
    }
    
    func playersImages () -> [String] {
        
        var playersImages : [String] = []
        
          switch player1 {
              case 1:
                   playersImages = ["xImage","circleImage"]
              case 2:
                  playersImages = ["circleImage","xImage"]
              default:
                  return []
          }
        return playersImages
      }
    
    func checkWinner(){
        
        for subArray in winningPositions {
            
            var counter = 0;
            for number in subArray {
                if gameState[number] == playerturn {
                    counter += 1;
                }
            }
            
            if counter > 2 {
                winner = playerturn
                 winnerMoveArr = subArray
                //print("Winner is: \(winner)")
            }
        }
            
    }
    
    func playAgain(){
        
        
        if winner == player1 {
            player1Score += 1
        } else if winner == player2 {
            player2Score += 1
        }
        
        gameState = [0,0,0,0,0,0,0,0,0]
        
        player1 = player2
        player2 = player1 == 1 ? 2 : 1
        
        playerturn = 1
        turnsCounter = 0
        self.currentPlayerImage = playerImage(player: playerturn)
        winner = 0
        
    }
    
    func reset(){
        playAgain()
        player1 = 2
        player2 = 2
        player1Score = 0
        player2Score = 0
    }
    
    
   
    
    

    
    
    
}
