//
//  TwoPlayersViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class TwoPlayersViewController: UIViewController {
    
    
    
    @IBOutlet var boardSquares: [UIImageView]!
    
    @IBOutlet weak var player1Image: UIImageView!
    @IBOutlet weak var player2Image: UIImageView!
    @IBOutlet weak var turnImage: UIImageView!
    
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupGame();
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        TwoPlayersGameManager.game.reset()
        
    }
    
    private func setupGame(){
        
        let images : [String] = TwoPlayersGameManager.game.playersImages()
        player1Image.image = UIImage(named: images.first ?? "")
        player2Image.image = UIImage(named: images.last ?? "")
        
    }
    
    private func updateUiGame(){
        
        player1ScoreLabel.text = "Score: \(TwoPlayersGameManager.game.player1Score)"
        player2ScoreLabel.text = "Score: \(TwoPlayersGameManager.game.player2Score)"
        
        UIView.transition(with: turnImage , duration: 0.3 , options: [.transitionCrossDissolve], animations: {
            self.turnImage.image = UIImage(named: TwoPlayersGameManager.game.currentPlayerImage)
        })
        checkWinner()
    }
    
    func updateUiWinner(){
          
          for index in TwoPlayersGameManager.game.winnerMoveArr {
              
              UIView.animate(withDuration: 1) {
                  self.boardSquares[index].layer.borderWidth = 10
                  self.boardSquares[index].layer.borderColor = UIColor.systemGreen.cgColor
              }
              
          }
          
      }
    
    private func checkWinner(){
        
        if TwoPlayersGameManager.game.winner != 0 || TwoPlayersGameManager.game.turnsCounter == 9 {
            
            var message : String = ""
            if TwoPlayersGameManager.game.winner != 0  {
                message = "Player \(TwoPlayersGameManager.game.winner) Won"
                updateUiWinner()
            }else if TwoPlayersGameManager.game.turnsCounter == 9{
                message = "It's a Draw"
            }else { return }
            
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alert.view.tintColor = TwoPlayersGameManager.game.winner == 1 ? UIColor.blue : UIColor.red
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            let createAction = UIAlertAction(title: "Play Again", style: .default) { (_) in
                TwoPlayersGameManager.game.playAgain()
                
                self.reloadUI()
            }
            
            alert.addAction(createAction)
            self.present(alert, animated:  true, completion: nil)
            
        }
    }
    
    
    
    @IBAction func boardClickAction(_ sender: UITapGestureRecognizer) {
        
        let tappedImage = sender.view as! UIImageView
        
        let player = TwoPlayersGameManager.game.makeStep(position: tappedImage.tag)
        
        guard player != 0 else {
            return
        }
        
        let squareImage : UIImageView = boardSquares[tappedImage.tag]
        
        
        UIView.transition(with: squareImage , duration: 0.3 , options: [.transitionFlipFromBottom], animations: {
            squareImage.image = UIImage(named: TwoPlayersGameManager.game.playerImage(player: player))
        })
        
        updateUiGame();
        
    }
    
    func reloadUI(){
        boardSquares.forEach { (image) in
            image.image = nil
            image.layer.borderWidth = 0
            setupGame()
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
