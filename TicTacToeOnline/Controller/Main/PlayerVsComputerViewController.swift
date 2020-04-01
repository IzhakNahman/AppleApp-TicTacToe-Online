//
//  PlayerVsComputerViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class PlayerVsComputerViewController: UIViewController {
    
    @IBOutlet var boardSquares: [UIImageView]!
    @IBOutlet weak var humanImage: UIImageView!
    @IBOutlet weak var computerImage: UIImageView!
    @IBOutlet weak var turnImage: UIImageView!
    
    @IBOutlet weak var humanScoreLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    var difficultyLevel : Int?
    
    @IBOutlet weak var turnIndicatorLabel: UILabel!
    var timerWaitingAnimation: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUiGame()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopWaitingAnimation(insertText: "")
        PvsCGameManager.game.reset()
        
    }
    
    private func updateUiGame(){
        
        PvsCGameManager.game.difficultyLevel = self.difficultyLevel ?? 0
        let images : [String] = PvsCGameManager.game.playersImages()
        humanImage.image = UIImage(named: images.first ?? "")
        computerImage.image = UIImage(named: images.last ?? "")
        
    }
    
    
    @IBAction func boardClickAction(_ sender: UITapGestureRecognizer) {
        
        let tappedImage = sender.view as! UIImageView
        
        let humanPosition = PvsCGameManager.game.makeStep(position: tappedImage.tag)
        guard humanPosition > -1 , humanPosition < PvsCGameManager.game.gameState.count else {
            return
        }
        let humanId = PvsCGameManager.game.gameState[humanPosition]
        hundleUIBoardclick(position: humanPosition, playerId: humanId)
        
        
        guard PvsCGameManager.game.winner == 0 , PvsCGameManager.game.turnsCounter != 9 else {
            return
        }
        
        computerClickAction()
    }
    
    func computerClickAction(){
        waitingForComputerTurnAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 , execute: {
            let computerPosition = PvsCGameManager.game.computerStep()
            guard computerPosition > -1 , computerPosition < PvsCGameManager.game.gameState.count else {
                return
            }
            let computerId = PvsCGameManager.game.gameState[computerPosition]
            self.hundleUIBoardclick(position: computerPosition, playerId: computerId)
            self.stopWaitingAnimation(insertText : "Your turn")
        })
        
    }
    
    func hundleUIBoardclick(position : Int, playerId : Int){
        
        UIView.transition(with: self.boardSquares[position] , duration: 0.3 , options: [.transitionFlipFromBottom], animations: {
            self.boardSquares[position].image = UIImage(named: PvsCGameManager.game.playerImage(player: playerId))
        })
        
        UIView.transition(with: turnImage , duration: 0.3 , options: [.transitionCrossDissolve], animations: {
            self.turnImage.image = UIImage(named: PvsCGameManager.game.currentPlayerImage)
        })
        
        checkWinner()
    }
    
    
    private func waitingForComputerTurnAnimation(){
        
        self.turnIndicatorLabel.text = "Waiting for computer."
        
        self.timerWaitingAnimation = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { [weak self](timer) in
            guard let self = self  else { return }
            
            var string: String {
                switch self.turnIndicatorLabel.text {
                case "Waiting for computer.":       return "Waiting for computer.."
                case "Waiting for computer..":      return "Waiting for computer..."
                case "Waiting for computer...":     return "Waiting for computer."
                default:                return "Waiting for computer"
                }
            }
            self.turnIndicatorLabel.text = string
        }
    }
    
    private func stopWaitingAnimation(insertText text : String){
        self.timerWaitingAnimation?.invalidate()
        self.timerWaitingAnimation = nil
        self.turnIndicatorLabel.text = text
    }
    
    
    private func checkWinner(){
        
        guard PvsCGameManager.game.winner != 0 || PvsCGameManager.game.turnsCounter == 9 else {
            return
        }
        
        var message : String = ""
        if PvsCGameManager.game.winner != 0  {
            message = PvsCGameManager.game.winnerName() + " Won"
            updateUiWinner()
        }else if PvsCGameManager.game.turnsCounter == 9{
            message = "It's a Draw"
        }else { return }
        
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let createAction = UIAlertAction(title: "Play Again", style: .default) { (_) in
            PvsCGameManager.game.playAgain()
            self.reloadUI()
            
            if PvsCGameManager.game.startingPlayer == PvsCGameManager.game.computerId {
                self.computerClickAction()
            }else{
                self.turnIndicatorLabel.text = "Your turn"
            }
        }
        
        alert.addAction(createAction)
        self.present(alert, animated:  true, completion: nil)
        
        humanScoreLabel.text = "Score: \(PvsCGameManager.game.humanScore)"
        computerScoreLabel.text = "Score: \(PvsCGameManager.game.computerScore)"
        
        
    }
    
    func updateUiWinner(){
        
        for index in PvsCGameManager.game.winnerMoveArr {
            
            UIView.animate(withDuration: 1) {
                self.boardSquares[index].layer.borderWidth = 10
                self.boardSquares[index].layer.borderColor = UIColor.systemGreen.cgColor
            }
            
        }
        
    }
    
    func reloadUI(){
        
        boardSquares.forEach { (image) in
            image.image = nil
            image.layer.borderWidth = 0
        }
        self.stopWaitingAnimation(insertText: "")
        
        updateUiGame()
        UIView.transition(with: turnImage , duration: 0.3 , options: [.transitionCrossDissolve], animations: {
            self.turnImage.image = UIImage(named: PvsCGameManager.game.currentPlayerImage)
        })
        
        humanScoreLabel.text = "Score: \(PvsCGameManager.game.humanScore)"
        computerScoreLabel.text = "Score: \(PvsCGameManager.game.computerScore)"
        
        
        
    }
    
    
    
}
