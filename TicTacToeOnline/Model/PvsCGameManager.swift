//
//  PvsCGameManager.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//


import Foundation

class PvsCGameManager {
    
    enum PlayerId : Int{
        case human = 1, computer
        func getId() -> Int {
            return self.rawValue
        }
        
        func name() -> String {
            switch self.rawValue {
            case 1:
                return "Human"
            case 2:
                return "Computer"
            default:
                return ""
            }
        }
    }
    
    
    static let game = PvsCGameManager()
    var difficultyLevel : Int?
    var gameState : [Int] = [0,0,0,0,0,0,0,0,0]
    var startingPlayer : Int = PlayerId.human.getId()
    var playerturn : Int = PlayerId.human.getId()
    var humanId = PlayerId.human.getId()
    var humanScore = 0
    var computerId = PlayerId.computer.getId()
    var computerScore = 0
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
    
    func winnerName() -> String {
        return PlayerId.init(rawValue: winner)?.name() ?? ""
    }
    
    
    func makeStep(position p : Int) -> Int{
        
        guard playerturn == PlayerId.human.getId(), gameState[p] == 0 && winner == 0 else {
            return -1
        }
        
        turnsCounter += 1
        
        gameState[p] = playerturn
        
        
        if(turnsCounter>4){ checkWinner() }
        
        playerturn = playerturn == PlayerId.human.getId() ? PlayerId.computer.getId() : PlayerId.human.getId()
        
        self.currentPlayerImage = playerImage(player: playerturn)
        
        return p
    }
    
    func computerStep() -> Int {
        
        guard let difficultyLevel = self.difficultyLevel, winner == 0 else {
            return -1
        }
        
        switch difficultyLevel {
        case 0:
            return beginnerStep()
        case 1:
            return amateurStep(checkStep: false)
        case 2:
            return semiProStep(checkStep: false)
        case 3:
            return LegendStep()
        default:
            return -1
        }
        
    }
    //random step
    private func beginnerStep() -> Int {
        let emptySquares : [Int] = self.emptySquares()
        guard emptySquares.count > 0 else {
            return -1
        }
        
        var randomIndex = 0
        
        if emptySquares.count > 1 {
            randomIndex = Int.random(in: 0 ..<  emptySquares.count-1)
        }
        
        turnsCounter += 1
        
        gameState[emptySquares[randomIndex]] = playerturn
        
        if(turnsCounter>4){ checkWinner() }
        
        
        playerturn = playerturn == PlayerId.human.getId() ? PlayerId.computer.getId() : PlayerId.human.getId()
        
        self.currentPlayerImage = playerImage(player: playerturn)
        
        return emptySquares[randomIndex]
    }
    
    //block human
    private func amateurStep(checkStep : Bool) -> Int {
        
        for subArray in winningPositions {
            
            var counter = 0;
            var saveSubArray : [Int] = []
            
            for number in subArray {
                if gameState[number] == humanId {
                    counter += 1
                }
                saveSubArray = subArray
            }
            
            if counter == 2 {
                
                for number in saveSubArray {
                    if gameState[number] == 0 {
                        turnsCounter += 1
                        
                        gameState[number] = playerturn
                        
                        if(turnsCounter>4){ checkWinner() }
                        
                        playerturn = playerturn == PlayerId.human.getId() ? PlayerId.computer.getId() : PlayerId.human.getId()
                        
                        self.currentPlayerImage = playerImage(player: playerturn)
                        return number
                    }
                }
                
            }
        }
        
        if checkStep == false {
            return beginnerStep()
        }else{
            return -1
        }
    }
    
    //auto complete for win
    private func semiProStep(checkStep : Bool) -> Int {
        
        for subArray in winningPositions {
            
            var counter = 0;
            var saveSubArray : [Int] = []
            
            for number in subArray {
                if gameState[number] == computerId {
                    counter += 1
                }
                saveSubArray = subArray
            }
            
            if counter == 2 {
                
                for number in saveSubArray {
                    if gameState[number] == 0 {
                        turnsCounter += 1
                        
                        gameState[number] = playerturn
                        
                        if(turnsCounter>4){ checkWinner() }
                        
                        playerturn = playerturn == PlayerId.human.getId() ? PlayerId.computer.getId() : PlayerId.human.getId()
                        
                        self.currentPlayerImage = playerImage(player: playerturn)
                        return number
                    }
                }
                
            }
        }
        
        if checkStep == false {
            return amateurStep(checkStep: false)
        }else{
            return -1
        }
    }
    
    //best move
    private func LegendStep() -> Int {
        
        let checkSemi =  semiProStep(checkStep: true)
        guard checkSemi == -1 else{
            return checkSemi
        }
        
        let checkBegnner = amateurStep(checkStep: true)
        guard checkBegnner == -1 else{
            return checkBegnner
        }
        
        
        for subArray in winningPositions {
            
            var counterComputer = 0;
            var counterHuman = 0;
            var saveSubArray : [Int] = []
            
            for number in subArray {
                if gameState[number] == computerId {
                    counterComputer += 1
                }else if  gameState[number] == humanId{
                    counterHuman += 1
                }
                saveSubArray = subArray
            }
            
            if counterComputer == 1 && counterHuman == 0 {
                
                for number in saveSubArray {
                    if gameState[number] == 0 {
                        turnsCounter += 1
                        
                        gameState[number] = playerturn
                        
                        if(turnsCounter>4){ checkWinner() }
                        
                        playerturn = playerturn == PlayerId.human.getId() ? PlayerId.computer.getId() : PlayerId.human.getId()
                        
                        self.currentPlayerImage = playerImage(player: playerturn)
                        return number
                    }
                }
                
            }
        }
        
        
        return semiProStep(checkStep: false)
    }
    
    
    private func emptySquares() -> [Int] {
        var emptySquares : [Int] = []
        for i in 0...gameState.count - 1 {
            if gameState[i] == 0 {
                emptySquares.append(i)
            }
        }
        return emptySquares
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
        
        switch humanId {
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
        
        guard winner == 0 else {
            return
        }
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
                return
            }
        }
        
    }
    
    func playAgain(){
        
        if turnsCounter == 9, winner == 0 {
            humanScore += 1
            computerScore += 1
        }
        
        switch winner {
        case humanId:
            humanScore += 2
        case computerId:
            computerScore += 2
        default:
            break
        }
        
        
        
        gameState = [0,0,0,0,0,0,0,0,0]
        
        startingPlayer = startingPlayer == humanId ? computerId : humanId
        
        playerturn = startingPlayer
        
        turnsCounter = 0
        self.currentPlayerImage = playerImage(player: playerturn)
        winner = 0
        
    }
    
    func reset(){
        
        gameState = [0,0,0,0,0,0,0,0,0]
        winner = 0
        turnsCounter = 0
        startingPlayer = PlayerId.human.getId()
        playerturn = PlayerId.human.getId()
        humanId = PlayerId.human.getId()
        humanScore = 0
        computerScore = 0
        currentPlayerImage = ""
    }
    
    
    
    
    
    
    
    
    
}
