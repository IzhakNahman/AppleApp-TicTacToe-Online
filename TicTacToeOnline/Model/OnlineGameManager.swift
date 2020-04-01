//
//  OnlineGameManager.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import Foundation



class OnlineGameManager {
    
    static let game = OnlineGameManager()
    
    var onlineGame : OnlineGame?
    var gameroom : Gameroom?
    var playersArray : [GamePlayer] = []
    
    var flagGameStarted : Int = 0
     var flagGameFinished : Int = 0
    var flagPlayAgain : Int = 0
    
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
    
    func cleanGame () {
        flagGameStarted = 0
        flagGameFinished = 0
        flagPlayAgain = 0
        playersArray = []
        gameroom = nil
        onlineGame = nil
        winnerMoveArr = []
        
    }
    
    func userLeavedRoom (room : Gameroom){

        FirebaseManager.manager.deleteGameroomPlayer(room)
        self.playersArray.removeAll { (player) -> Bool in
            player.playerId == FirebaseManager.manager.userId
        }
        FirebaseManager.manager.editQuantityGameRoom(gameRoomId: room.id, playersQuantity: self.playersArray.count)
        FirebaseManager.manager.deleteOnlineGame(roomId: room.id)
        if playersArray.count == 0 {
            FirebaseManager.manager.deleteGameroom(room)
        }
        self.cleanGame()
        
    }
    
    func playAgainMode (onlineGame : OnlineGame) {
        var newGame = onlineGame
        newGame.gameState = "0,0,0,0,0,0,0,0,0"
        newGame.winner = "0"
        flagGameFinished = 0
        flagPlayAgain = 0
        winnerMoveArr = []
        
        guard let room = gameroom,
            playersArray.count == 2,
            let firstPlayer = playersArray.first,
            let index = self.getCurrentPlayerIndex() else{
            return
        }
        var _ : GamePlayer =  playersArray[index]
        
        newGame.playerTurnById = firstPlayer.playerId
        //currentPlayer.wantPlayAgain = false
        //lastPlayer.wantPlayAgain = false
        
        //FirebaseManager.manager.updateGamePlayer(roomId: room.id, gamePlayer: currentPlayer)
        //FirebaseManager.manager.updateGamePlayer(roomId: room.id, gamePlayer: lastPlayer)
        
        FirebaseManager.manager.updateOnlineGame(roomId: room.id, onlineGame: newGame)
        
    }
    
    func updateGamePlayerPlayAgain(){
        guard let room = gameroom,
                   let index = self.getCurrentPlayerIndex() else{
                   return
               }
        
        let currentPlayer : GamePlayer =  playersArray[index]
        
        FirebaseManager.manager.updateGamePlayer(roomId: room.id, gamePlayer: currentPlayer)

    }
    
    func turnsCounter (onlineGame : OnlineGame) -> Int{
        
        var splits = onlineGame.gameState.components(separatedBy: ",")
        splits = splits.filter { (str) -> Bool in
            str != "0"
        }
        return splits.count
    }
    
    
    func startGame(onlineGame : OnlineGame, gameroom : Gameroom){
        self.onlineGame = onlineGame
        self.gameroom = gameroom
        self.flagGameStarted = 1
    }
    
    
    func makeStep(position p : Int) -> String{
        
        guard let room = self.gameroom,
            var newOnlineGame = onlineGame,
            newOnlineGame.playerTurnById == FirebaseManager.manager.userId,
            newOnlineGame.winner == "0" else {
                return ""
        }
        
        var gameState : [String] = newOnlineGame.gameState.components(separatedBy: ",")
        
        guard gameState[p] == "0" else {
            return ""
        }
        
        gameState[p] = newOnlineGame.playerTurnById
        newOnlineGame.gameState = gameState.joined(separator: ",")
        
        //if(turnsCounter>4){ checkWinner() }
        
        let lastPlayer = newOnlineGame.playerTurnById
        
        let player1Id : String = playersArray.first?.playerId ?? ""
        let player2Id : String = playersArray.last?.playerId ?? ""
        
        newOnlineGame.playerTurnById = onlineGame!.playerTurnById == player1Id ? player2Id : player1Id
        
        FirebaseManager.manager.updateOnlineGame(roomId: room.id, onlineGame: checkWinner(onlineGame: newOnlineGame, playerTurnId: lastPlayer))
        
        return lastPlayer
    }
    
    func playerImage (playerId : String?) -> String {
        
        let playerId : String = playerId ?? ""
        let player1Id : String = playersArray.first?.playerId ?? ""
        let player2Id : String = playersArray.last?.playerId ?? ""
        
        switch playerId {
        case player1Id:
            return "xImage"
        case player2Id:
            return "circleImage"
        default:
            return ""
        }
    }
    
    func updateOnlineGame (onlineGame : OnlineGame) {
        self.onlineGame = onlineGame
        if onlineGame.winner != "0" {
            checkWinner(onlineGame: onlineGame, playerTurnId: onlineGame.winner)
        }
    }
    
    @discardableResult
    func checkWinner(onlineGame : OnlineGame, playerTurnId : String) -> OnlineGame{
        
        var newOnlineGame =  onlineGame
        
        let gameState : [String] = newOnlineGame.gameState.components(separatedBy: ",")
        let playerTurn : String = playerTurnId
        
        
        //print(gameState)
        //print(playerTurn)
        
        
        for subArray in winningPositions {
            
            var counter = 0;
            
            for number in subArray {
                if gameState[number] == playerTurn {
                    counter += 1;
                }
            }
            
            if counter > 2 {
                newOnlineGame.winner = playerTurn
                winnerMoveArr = subArray
                return newOnlineGame
            }
        }
        
        //print(newOnlineGame)
        return onlineGame
        
    }
    
    func getPlayerIndex(playerId: String) -> Int?{
        let index = self.playersArray.lastIndex { (playerInArray) -> Bool in
            playerInArray.playerId == playerId
        }
        return index
    }
    
    
    func getCurrentPlayerIndex() -> Int?{
        
        let index = self.playersArray.lastIndex { (playerInArray) -> Bool in
            playerInArray.playerId == FirebaseManager.manager.userId
        }
        return index
    }
    
    func getRivalPlayerIndex() -> Int?{
        
        let index = self.playersArray.lastIndex { (playerInArray) -> Bool in
            playerInArray.playerId != FirebaseManager.manager.userId
        }
        return index
    }
    
    func updateScoreIfUserLeft(winnerPlayer : String, loserPlayer : String){
        
        FirebaseManager.manager.getGameUserById(userId: winnerPlayer) {(user) in
            var newUser = user
            newUser.score = newUser.score + 2
            newUser.wins += 1
            FirebaseManager.manager.updateGameUser(user: newUser)
        }
        
        FirebaseManager.manager.getGameUserById(userId: loserPlayer) {(user) in
            var newUser = user
            newUser.losses += 1
            FirebaseManager.manager.updateGameUser(user: newUser)
        }
    }
    
    func updateScore(points : Int, onlineGame : OnlineGame, roomId: String){
        
        switch points {
        case 2:
            
            for i in 0...OnlineGameManager.game.playersArray.count - 1 {
                
                if(OnlineGameManager.game.playersArray[i].playerId == onlineGame.winner){
                    FirebaseManager.manager.getGameUserById(userId: OnlineGameManager.game.playersArray[i].playerId) {(user) in
                        var newUser = user
                        newUser.score = newUser.score + 2
                        newUser.wins += 1
                        FirebaseManager.manager.updateGameUser(user: newUser)
                    }
                    var newGamePlayer = OnlineGameManager.game.playersArray[i]
                    newGamePlayer.score += 2
                    FirebaseManager.manager.updateGamePlayer(roomId :roomId, gamePlayer : newGamePlayer)
                    OnlineGameManager.game.playersArray[i].score += 2
                }else{
                    FirebaseManager.manager.getGameUserById(userId: OnlineGameManager.game.playersArray[i].playerId) {(user) in
                        var newUser = user
                        newUser.losses += 1
                        FirebaseManager.manager.updateGameUser(user: newUser)
                    }
                }
                
            }
            
            
            OnlineGameManager.game.playAgainMode(onlineGame: onlineGame)
            return
        case 1:
            
            for i in 0...OnlineGameManager.game.playersArray.count - 1 {
                
                FirebaseManager.manager.getGameUserById(userId: OnlineGameManager.game.playersArray[i].playerId) {(user) in
                    var newUser = user
                    newUser.score = newUser.score + 1
                    newUser.draws += 1
                    FirebaseManager.manager.updateGameUser(user: newUser)
                }
                var newGamePlayer = OnlineGameManager.game.playersArray[i]
                newGamePlayer.score += 1
                FirebaseManager.manager.updateGamePlayer(roomId : roomId, gamePlayer : newGamePlayer)
                OnlineGameManager.game.playersArray[i].score += 1
                
            }
            for i in 0...OnlineGameManager.game.playersArray.count - 1 {
                OnlineGameManager.game.playersArray[i].score = Int(OnlineGameManager.game.playersArray[i].score) + 1
            }
            
            OnlineGameManager.game.playAgainMode(onlineGame: onlineGame)
            return
        default:
            return
        }
    }
    
    func createGameRoomPlayer(roomId : String){
        FirebaseManager.manager.createGameroomPlayer(roomId: roomId)
    }
    
    
    
}
