//
//  OnlineGameViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class OnlineGameViewController: UIViewController {
    
    var room : Gameroom!
    
    @IBOutlet weak var customAlertView: UIView!
    @IBOutlet weak var customAlertTextLabel: UILabel!
    @IBOutlet weak var customAlertTextSecLabel: UILabel!
    
    
    @IBOutlet var boardSquares: [UIImageView]!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var player1Image: UIImageView!
    @IBOutlet weak var player2Image: UIImageView!
    @IBOutlet weak var turnImage: UIImageView!
    @IBOutlet weak var player1NameLabel: UILabel!
    @IBOutlet weak var player2NameLabel: UILabel!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    
    @IBOutlet weak var waitingLabel: UILabel!
    
    @IBOutlet weak var secLabel: UILabel!
    var flagAppClosed : Int = 0
    
    
    var timerWaitingAnimation: Timer?
    var timerPlayerMove : Timer?
    var secCounter : Int = 0
    
    var timerForPlayAgain : Timer?
    
    var secCounterForPlayAgain : Double = 0
    
    //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateAction), userInfo: nil, repeats: true)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageView.alpha = 0
        customAlertView.alpha = 0
        customAlertTextSecLabel.isHidden = true
        customAlertView.layer.cornerRadius = customAlertView.frame.height * 0.5
        messageView.layer.cornerRadius = messageView.frame.height / 4
        
        //show chat room title in screen title
        self.navigationItem.title = room.title
        
        //start firebase listeners
        onlineGameListeners()
        
        //login user to game
        OnlineGameManager.game.createGameRoomPlayer(roomId: room.id)
        
        //start waiting for players animation
        waitingForPlayerAnimation()
       
        replaceBackButton()
     
        
        //handle user minimize app
         NotificationCenter.default.addObserver(self, selector: #selector(self.closeActivityController), name: UIApplication.willResignActiveNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(self.openactivity), name: UIApplication.didBecomeActiveNotification, object: nil)
             
        
    }
    
    private func replaceBackButton (){
        self.tabBarController?.navigationItem.hidesBackButton = true
             
             let button = UIButton(type: .system)
             button.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
             button.setTitle("Leave Game", for: .normal)
             button.sizeToFit()
             button.addTarget(self, action: #selector(back(sender:)), for: .touchDown)
             
             //let newBackButton = UIBarButtonItem(title: "Leave Game", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back(sender:)))
             
             self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)

             
    }
    
    @objc func back(sender: UIBarButtonItem) {
        
        guard OnlineGameManager.game.playersArray.count == 2, OnlineGameManager.game.flagGameFinished == 0  else{
            _ = navigationController?.popViewController(animated: true)
            return
        }
        let alert = UIAlertController(title: "Leave Game", message: "Are you sure you want to leave this game ֿ? ", preferredStyle: .alert)
        
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let createAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(createAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    
    
    @IBAction func boardClickAction(_ sender: UITapGestureRecognizer) {
        
        guard OnlineGameManager.game.onlineGame != nil,
            OnlineGameManager.game.playersArray.count>0,
            let tappedView = sender.view else {
                return
        }
        
        let player = OnlineGameManager.game.makeStep(position: tappedView.tag)
        
        guard player != "" else {
            return
        }
        
        let squareImage : UIImageView = boardSquares[tappedView.tag]
        
        UIView.transition(with: squareImage , duration: 0.3 , options: [.transitionFlipFromBottom], animations: {
            squareImage.image = UIImage(named: OnlineGameManager.game.playerImage(playerId: player))
        })
        
        
        
    }
    
    private func startListenToMessages(){
        //listen to new messages
        FirebaseManager.manager.listenToNewMessage(roomId: self.room.id){ [weak self](msg) in
            guard let self = self, msg.authorId != FirebaseManager.manager.userId else { return }
            
            self.messageLabel.text = "New message recived: " + msg.text
            
            self.tabBarController?.tabBar.items![1].image = UIImage(systemName: "text.bubble.fill")
            
            UIView.animate(withDuration: 3, animations: {
                self.messageView.alpha = 1
            }) { (bool) in
                UIView.animate(withDuration: 3) {
                    self.messageView.alpha = 0
                }
            }
            
        }
    }
    
    private func onlineGameListeners(){
        FirebaseManager.manager.listenToNewGamePlayer(roomId: room.id) { [weak self](player) in
            guard let self = self else { return }
            OnlineGameManager.game.playersArray.append(player)
            if OnlineGameManager.game.playersArray.count == 2 , OnlineGameManager.game.flagGameStarted == 0 /* start game */{
                
                OnlineGameManager.game.playersArray = OnlineGameManager.game.playersArray.sorted(by: { $0.date < $1.date })
                
                guard let player1 : String = OnlineGameManager.game.playersArray.first?.playerId,
                    let onlineGame = FirebaseManager.manager.createOnlineGame(roomId: self.room.id, startingPlayer: player1) else {
                        return
                }
                
                self.room.isOpen = false
                FirebaseManager.manager.deleteMessage(roomId: self.room.id)
               

                FirebaseManager.manager.editIsOpenGameRoom(gameRoomId: self.room.id, isOpen: false)
                OnlineGameManager.game.startGame(onlineGame: onlineGame, gameroom: self.room)
                
                self.startListenToMessages()
                
                self.setupGame()
            }
            FirebaseManager.manager.editQuantityGameRoom(gameRoomId: self.room.id, playersQuantity: OnlineGameManager.game.playersArray.count)
        }
        
        FirebaseManager.manager.listenToDeleteGamePlayer(roomId: room.id) { [weak self](leavePlayer) in
            guard let self = self, leavePlayer.playerId != FirebaseManager.manager.userId else { return }
            
            let index = OnlineGameManager.game.getPlayerIndex(playerId: leavePlayer.playerId)
            
            guard let newIndex : Int = index else {
                return
            }
            
            OnlineGameManager.game.playersArray.remove(at: newIndex)
            
            FirebaseManager.manager.editQuantityGameRoom(gameRoomId: self.room.id, playersQuantity: OnlineGameManager.game.playersArray.count)
            
            if OnlineGameManager.game.playersArray.count == 1 , OnlineGameManager.game.flagGameStarted == 1, let stayPlayer = OnlineGameManager.game.playersArray.first, OnlineGameManager.game.flagGameFinished == 0  {
                
                
                OnlineGameManager.game.updateScoreIfUserLeft(winnerPlayer: stayPlayer.playerId, loserPlayer: leavePlayer.playerId)
                
                
                let alert = UIAlertController(title: "You won!", message: leavePlayer.playerName + " left the game, you won!", preferredStyle: .alert)
                
                self.cleanUiGame()
                
                
                let newGame = UIAlertAction(title: "Start New Game", style: .default) { (_) in
                    
                    guard let room = self.room else {
                        return
                    }
                    var newRoom : Gameroom = room
                    newRoom.ownerId = stayPlayer.playerId
                    newRoom.ownerName = stayPlayer.playerName
                    newRoom.isOpen = true
                    FirebaseManager.manager.updateGameRoom(roomId: room.id, newRoom: newRoom)
                    OnlineGameManager.game.cleanGame()
                    self.onlineGameListeners()
                    self.cleanUiGame()
                    
                }
                alert.addAction(newGame)
                
                let leaveGame = UIAlertAction(title: "Leave Game", style: .cancel){ (_) in
                    
                    self.navigationController?.popViewController(animated: true)
                    self.userLeavedController()
                }
                
                alert.addAction(leaveGame)
                
                self.present(alert, animated: true, completion: nil)
                
               
                
            }
            
            
            
        }
        
        FirebaseManager.manager.listenToChangeGamePlayer(roomId: self.room.id) { [weak self](gamePlayer) in
            guard let _ = self ,let index = OnlineGameManager.game.getPlayerIndex(playerId: gamePlayer.playerId) else {
                return
            }
            OnlineGameManager.game.playersArray[index] = gamePlayer
        }
        
        FirebaseManager.manager.listenToChangeSingleGameRoom(roomId: room.id) { [weak self](newRoom) in
            guard let self = self else { return }
            self.room = Gameroom(newRoom.dictionaryRepresentation)
        }
        
        FirebaseManager.manager.listenToChangeOnlineGame(roomId: room.id) { [weak self](game) in
            guard self != nil else { return }
            
            guard OnlineGameManager.game.flagGameStarted == 1 else {return}
            
            OnlineGameManager.game.updateOnlineGame(onlineGame: game)
            
            if OnlineGameManager.game.winnerMoveArr.count > 0 {
                self!.updateUiWinner()
            }
            
            self!.checkWinner(onlineGame : game)
            
            if OnlineGameManager.game.flagGameFinished == 0 {
                self!.updateUiGame();
            }
            
            
            
            if game.playerTurnById != FirebaseManager.manager.userId ,  self!.timerWaitingAnimation == nil, game.winner == "0" , OnlineGameManager.game.turnsCounter(onlineGame: game) != 9, OnlineGameManager.game.flagGameFinished == 0{
                guard self != nil else { return }
                
                self!.startWaitForPlayerTurn()
                
            }
            else if game.playerTurnById == FirebaseManager.manager.userId, OnlineGameManager.game.flagGameFinished == 0 {
                self!.timerPlayerMove?.invalidate()
                self!.secCounter = 0
                self!.timerPlayerMove = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self](timer) in
                    guard let self = self else {
                        return
                    }
                    if self.secCounter < 30 {
                        self.secLabelAnimation()
                    }else{
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                    
                })
                self!.stopWaitingAnimation(insertText: "Your turn")
            }
            
        }
    }
    
    private func secLabelAnimation(){
        self.secCounter += 1
        if self.secCounter > 20 {
            self.secLabel.textColor = .systemRed
        }
        if self.secCounter > 25 {
            UIView.animate(withDuration: 0.2, animations: {
                self.secLabel.alpha = 0
            }) { (bool) in
                self.secLabel.alpha = 1
            }
        }
        
        self.secLabel.text = String(format: "%02d", self.secCounter)
    }
    
    private func gameStartedAlertAnimation(){
        customAlertTextLabel.text = "Game Started"
        
        UIView.animate(withDuration: 1, animations: {
            self.customAlertView.alpha = 1
        }) { (bool) in
            UIView.animate(withDuration: 2) {
                self.customAlertView.alpha = 0
            }
        }
        
    }
    
    private func showWatingForPlayAgainAlert(show : Bool){
        
        if show == true {
            UIView.animate(withDuration: 1) {
                self.customAlertView.alpha = 1
                self.customAlertTextLabel.text = "Waiting for rival player decision"
                self.customAlertTextSecLabel.isHidden = false
            }
        }else{
            UIView.animate(withDuration: 1) {
                self.customAlertView.alpha = 0
                self.customAlertTextLabel.text = "Game Started"
                self.customAlertTextSecLabel.isHidden = true
            }
        }
        

        
    }
    
    
    private func setupGame(){
        
        self.gameStartedAlertAnimation()
        
        stopWaitingAnimation(insertText: "")
        
         self.startWaitForPlayerTurn()
        
        OnlineGameManager.game.updateGamePlayerPlayAgain()
        
        guard OnlineGameManager.game.onlineGame != nil,
            let playerFirst = OnlineGameManager.game.playersArray.first ,
            let playerLast = OnlineGameManager.game.playersArray.last else{
                return
        }
        
        if playerFirst.playerId == FirebaseManager.manager.userId {
            player1NameLabel.text = "You"
            player2NameLabel.text = playerLast.playerName
        }else{
            player1NameLabel.text = playerFirst.playerName
            player2NameLabel.text = "You"
        }
        
        player1Image.image = UIImage.init(named: OnlineGameManager.game.playerImage( playerId:  playerFirst.playerId))
        player2Image.image = UIImage.init(named: OnlineGameManager.game.playerImage( playerId:  playerLast.playerId))
        
        turnImage.image = UIImage.init(named: OnlineGameManager.game.playerImage(playerId: OnlineGameManager.game.onlineGame!.playerTurnById))
        
        player1ScoreLabel.text = "Score: \(playerFirst.score)"
        player2ScoreLabel.text = "Score: \(playerLast.score)"
        
        let gameState : [String] = "0,0,0,0,0,0,0,0,0".components(separatedBy: ",")
        
        
        boardSquares.forEach { (image) in
            if gameState[image.tag] == "0" {
                UIView.transition(with: image , duration: 0.3 , options: [.transitionCrossDissolve], animations: {
                    image.image = nil
                })
            }
            image.layer.borderWidth = 0
        }
        
        secLabel.text = "00"
        timerWaitingAnimation?.invalidate()
        timerWaitingAnimation = nil
        secCounter = 0
        
    }
    
    func updateUiWinner(){
        
        for index in OnlineGameManager.game.winnerMoveArr {
            
            UIView.animate(withDuration: 1) {
                self.boardSquares[index].layer.borderWidth = 10
                self.boardSquares[index].layer.borderColor = UIColor.systemGreen.cgColor
            }
            
        }
        
    }
    
    private func checkWinner(onlineGame : OnlineGame){
        
        let winerFlag = onlineGame.winner != "0"
        let drawFlag = OnlineGameManager.game.turnsCounter(onlineGame: onlineGame) == 9
        
        //if win or draw
        if winerFlag || drawFlag {
            
            OnlineGameManager.game.flagGameFinished = 1
            //stop showing witing label animation
            stopWaitingAnimation(insertText : "")
            stopsecCounterAnimation(insertText: "00")
            
            var alertMessage : String = ""
            
            if winerFlag{
                
                guard let index = OnlineGameManager.game.getPlayerIndex(playerId: onlineGame.winner) else {
                    return
                }
                
          
                
                 OnlineGameManager.game.updateScore(points : 2, onlineGame : onlineGame, roomId : self.room.id)
                self.updateUiGame()
                
                alertMessage = "Player \(OnlineGameManager.game.playersArray[index].playerName) Won"
            }
            else  {
                
                OnlineGameManager.game.updateScore(points : 1, onlineGame : onlineGame, roomId : self.room.id)
                self.updateUiGame()

                alertMessage = "It's a Draw"
            }
            
            stopWaitingAnimation(insertText: "")
            stopsecCounterAnimation(insertText: "00")
            
            OnlineGameManager.game.flagGameFinished = 1
            
            OnlineGameManager.game.flagPlayAgain = 1
            
            
            let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ){ (_) in
                self.userLeavedController()
                self.navigationController?.popViewController(animated: true)
            }
            
            alert.addAction(cancelAction)
            let playAgainAction = UIAlertAction(title: "Play Again", style: .default) { (_) in
                
                
                guard let indexCurrentPlayer = OnlineGameManager.game.getCurrentPlayerIndex() else{
                    return
                }
                
                self.showWatingForPlayAgainAlert(show: true)
                
                var currentPlayer = OnlineGameManager.game.playersArray[indexCurrentPlayer]
                
                currentPlayer.wantPlayAgain = true
                
                FirebaseManager.manager.updateGamePlayer(roomId: self.room.id, gamePlayer: currentPlayer)
                
                
                self.timerForPlayAgain = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self](timer) in
                    guard let self = self  else {
                        return
                    }
                    
                    self.secCounterForPlayAgain += 0.5
                    
//                    guard self.secCounterForPlayAgain > 2 else {
//                        return
//                    }
//
                    
                    guard self.secCounterForPlayAgain < 20 else {
                        self.secCounterForPlayAgain = 0
                        self.playAgainFailed()
                        return
                    }
                    
                    guard let indexRivalPlayer = OnlineGameManager.game.getRivalPlayerIndex() else{
                        self.secCounterForPlayAgain = 0
                        self.playAgainFailed()
                        return
                    }
                    if OnlineGameManager.game.playersArray[indexRivalPlayer].wantPlayAgain == true {
                        OnlineGameManager.game.playAgainMode(onlineGame: onlineGame)
                        self.secCounterForPlayAgain = 0
                        self.showWatingForPlayAgainAlert(show: false)
                        self.setupGame()
                        self.timerForPlayAgain?.invalidate()
                        self.timerForPlayAgain = nil
                    }
                    
                    
                    
                    if self.secCounterForPlayAgain.truncatingRemainder(dividingBy: 1) == 0 {
                        self.customAlertTextSecLabel.text = "\(Int(15 - self.secCounterForPlayAgain))"
                    }
                    
                    
                })
                
                
            }
            
            alert.addAction(playAgainAction)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.present(alert, animated:  true, completion: nil)
            })
           
            
        }
    }
    
    private func playAgainFailed() {
        
        let alert = UIAlertController(title: "Play Again Failed", message: nil , preferredStyle: .alert)
        
        self.cleanUiGame()
        
       /* let newGame = UIAlertAction(title: "Start New Game", style: .default) { (_) in
            
            
            guard let room = self.room, let stayPlayer = OnlineGameManager.game.playersArray.first  else {
                return
            }
            var newRoom : Gameroom = room
            newRoom.ownerId = stayPlayer.playerId
            newRoom.ownerName = stayPlayer.playerName
            FirebaseManager.manager.updateGameRoom(roomId: room.id, newRoom: newRoom)
            OnlineGameManager.game.cleanGame()
            self.onlineGameListeners()
            self.cleanUiGame()
            
        }
        alert.addAction(newGame)*/
        
        let leaveGame = UIAlertAction(title: "Ok", style: .cancel){ (_) in
            
            self.showWatingForPlayAgainAlert(show: false)
            self.userLeavedController()
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(leaveGame)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateUiGame(){
        
        guard OnlineGameManager.game.onlineGame != nil,
            OnlineGameManager.game.playersArray.count>0 else {
                return
        }
        
        guard let score1 : Int = OnlineGameManager.game.playersArray.first?.score ,
            let score2 : Int = OnlineGameManager.game.playersArray.last?.score else {
                return
        }
        
        player1ScoreLabel.text = "Score: \(score1)"
        player2ScoreLabel.text = "Score: \(score2)"
        
        let gameState : [String] = OnlineGameManager.game.onlineGame?.gameState.components(separatedBy: ",") ?? []
        
        
        boardSquares.forEach { (image) in
            if gameState[image.tag] != "0", image.image == nil {
                UIView.transition(with: image , duration: 0.3 , options: [.transitionFlipFromBottom], animations: {
                    image.image = UIImage(named: OnlineGameManager.game.playerImage(playerId: gameState[image.tag]))
                })
            }
        }
        
        
        UIView.transition(with: self.turnImage , duration: 0.3 , options: [.transitionCrossDissolve], animations: {
            self.turnImage.image = UIImage.init(named: OnlineGameManager.game.playerImage(playerId: OnlineGameManager.game.onlineGame!.playerTurnById))
        })
        
        
    }
    
    private func cleanUiGame(){
        
        stopWaitingAnimation(insertText : "")
        
        stopsecCounterAnimation(insertText: "00")
        
        self.waitingLabel.text = "Waiting for player to join."
        waitingForPlayerAnimation()
        
        
        player1NameLabel.text = "player1"
        player2NameLabel.text = "player2"
        
        player1Image.image = nil
        player2Image.image = nil
        
        
        player1ScoreLabel.text = "Score:"
        player2ScoreLabel.text = "Score:"
        turnImage.image = nil
        
        self.secLabel.textColor = .black
        
        boardSquares.forEach { $0.image = nil
            $0.layer.borderWidth = 0
        }
        
        
        timerForPlayAgain?.invalidate()
        timerForPlayAgain = nil
        
    }
    
    private func startWaitForPlayerTurn(){
        
        self.waitingForPlayerTurnAnimation()
        self.timerPlayerMove?.invalidate()
        self.secCounter = 0
        self.secLabel.textColor = .black
        
        self.timerPlayerMove = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self](timer) in
            guard let self = self else {
                return
            }
            if self.secCounter < 31 {
                self.secLabelAnimation()
            }else if self.secCounter > 35 && Reachability.connection.isConnectedToNetwork()==true{
                
                guard let rivalPlayerIndex = OnlineGameManager.game.getRivalPlayerIndex() else {
                    return
                }
                FirebaseManager.manager.deleteOtherGameroomPlayer(gameroom: self.room, playerId: OnlineGameManager.game.playersArray[rivalPlayerIndex].playerId )
                
            }
        })
    }
    
    //starting wating for players animtion
    private func waitingForPlayerAnimation(){
        
        self.waitingLabel.text = "Waiting for player to join."

        self.timerWaitingAnimation = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { [weak self](timer) in
            guard let self = self else { return }
            
            var string: String {
                switch self.waitingLabel.text {
                case "Waiting for player to join.":       return "Waiting for player to join.."
                case "Waiting for player to join..":      return "Waiting for player to join..."
                case "Waiting for player to join...":     return "Waiting for player to join."
                default:                return "Waiting for player to join"
                }
            }
            self.waitingLabel.text = string
        }
    }
    
    private func waitingForPlayerTurnAnimation(){
        
        guard let playerId = OnlineGameManager.game.onlineGame?.playerTurnById,
                let index = OnlineGameManager.game.getPlayerIndex(playerId:  playerId) else {
            return
        }
        
        
        
        /*guard let index = OnlineGameManager.game.getRivalPlayerIndex(),
            self.timerWaitingAnimation == nil else {
                return
        }*/
        self.waitingLabel.text = "Waiting for \(OnlineGameManager.game.playersArray[index].playerName)."
        
        self.timerWaitingAnimation = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { [weak self](timer) in
            guard let self = self, OnlineGameManager.game.playersArray.count > 1  else { return }
            
            var string: String {
                switch self.waitingLabel.text {
                case "Waiting for \(OnlineGameManager.game.playersArray[index].playerName).":       return "Waiting for \(OnlineGameManager.game.playersArray[index].playerName).."
                case "Waiting for \(OnlineGameManager.game.playersArray[index].playerName)..":      return "Waiting for \(OnlineGameManager.game.playersArray[index].playerName)..."
                case "Waiting for \(OnlineGameManager.game.playersArray[index].playerName)...":     return "Waiting for \(OnlineGameManager.game.playersArray[index].playerName)."
                default:                return "Waiting for \(OnlineGameManager.game.playersArray[index].playerName)"
                }
            }
            self.waitingLabel.text = string
        }
    }
    
    private func stopWaitingAnimation(insertText text : String){
        self.timerWaitingAnimation?.invalidate()
        self.timerWaitingAnimation = nil
        self.waitingLabel.text = text
    }
    
    private func stopsecCounterAnimation(insertText text : String){
        self.timerPlayerMove?.invalidate()
        self.timerPlayerMove = nil
        self.secLabel.text = text
        secCounter = 0
        
    }
    
    
    
    deinit {
        if flagAppClosed == 0 {
            userLeavedController()
        }
    }
    
    
    private func userLeavedController(){
        OnlineGameManager.game.userLeavedRoom(room: room)
        
        timerForPlayAgain?.invalidate()
        timerForPlayAgain = nil
        timerPlayerMove?.invalidate()
        timerPlayerMove = nil
        timerWaitingAnimation?.invalidate()
        timerWaitingAnimation = nil
        
        stopListeners()
    }
    
    private func stopListeners(){
        //FirebaseManager.manager.stopListenToGamerooms()
        FirebaseManager.manager.stopListenToGamePlayers()
        FirebaseManager.manager.stopGameUsersDatabaseReference()
        FirebaseManager.manager.stopOnlineGamesDatabaseReference()
        FirebaseManager.manager.stopListenToMessages()
        FirebaseManager.manager.deleteMessage(roomId: room.id)
    }
    
    
    
    @objc func closeActivityController()  {
        
         userLeavedController()
         flagAppClosed = 1
        
    }
    
    @objc func openactivity()  {
        
        //view should reload the data.
        if flagAppClosed == 1 {
            //print(flagAppClosed)
            
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    
}
