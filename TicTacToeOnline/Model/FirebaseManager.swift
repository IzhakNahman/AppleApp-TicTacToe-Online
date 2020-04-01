//
//  FirebaseManager.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//
import Foundation
import FirebaseDatabase
import FirebaseAuth

class FirebaseManager {
    static let manager = FirebaseManager()
    var userId : String? {
        return Auth.auth().currentUser?.uid
    }
    
    var userName : String? {
        return Auth.auth().currentUser?.displayName
    }
    //Databse refferences:
    
    
    private lazy var gameRoomsDatabaseReference : DatabaseReference = {
        return Database.database().reference().child("GameRooms")
    }()
    
    private lazy var gameRoomPlayersDatabaseReference : DatabaseReference = {
        return Database.database().reference().child("GameRoomPlayers")
    }()
    
    private lazy var onlineGamesDatabaseReference : DatabaseReference = {
        return Database.database().reference().child("OnlineGames")
    }()
    
    private lazy var usersDatabaseReference : DatabaseReference = {
        return Database.database().reference().child("Users")
    }()
    
    private lazy var messagesDatabaseReference : DatabaseReference = {
           return Database.database().reference().child("Messages")
       }()
    
    func stopListenToGamerooms() {
        gameRoomsDatabaseReference.removeAllObservers()
    }
    
    func stopListenToMessages() {
        messagesDatabaseReference.removeAllObservers()
    }

    func stopListenToGamePlayers() {
        gameRoomPlayersDatabaseReference.removeAllObservers()
    }
    
    func stopOnlineGamesDatabaseReference() {
        onlineGamesDatabaseReference.removeAllObservers()
    }
    
    func stopGameUsersDatabaseReference() {
        usersDatabaseReference.removeAllObservers()
    }
    
    func createMessage(roomId : String, text : String){
        guard let uid = userId, let uname = userName else {
            return
        }
        
        let message = ChatMessage.init(roomId: roomId, authorId: uid, authorName: uname, text: text)
        messagesDatabaseReference.child(roomId).child(message.id).setValue(message.dictionaryRepresentation)
    }
    
    func listenToNewMessage(roomId : String, with callback : @escaping (ChatMessage)->Void){
        
        let ref = messagesDatabaseReference.child(roomId).queryOrdered(byChild: "date")
        
        ref.observe(.childAdded) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let message = ChatMessage(json) else {
                return
            }
            
            callback(message)
            
        }
    }
    
    
    func deleteMessage(roomId : String) {
        messagesDatabaseReference.child(roomId).setValue(nil)
    }

    
    func createGameUser(){
        guard let uid = userId, let uname = userName else {
            return
        }
        let user = GameUser.init(userId: uid, userName: uname)
        usersDatabaseReference.child(uid).setValue(user.dictionaryRepresentation)
    }
    
    func listenToNewGameUser(with callback : @escaping (GameUser)->Void){
        
        let ref = usersDatabaseReference.queryOrdered(byChild: "score")
        
        ref.observe(.childAdded) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let user = GameUser(json) else {
                return
            }
            
            callback(user)
            
        }
    }
    
    func listenToDeleteGameUser(with callback : @escaping (GameUser)->Void){
        
        let ref = usersDatabaseReference.queryOrdered(byChild: "score")
        
        ref.observe(.childRemoved) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let user = GameUser(json) else {
                return
            }
            
            callback(user)
            
        }
    }
    
    func updateGameUser(user : GameUser){
        usersDatabaseReference.child(user.userId).setValue(nil)
        usersDatabaseReference.child(user.userId).setValue(user.dictionaryRepresentation)
    }
    
    func getGameUserById(userId : String, with callback : @escaping (GameUser)->Void){
        
        let ref = usersDatabaseReference.child(userId)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let user = GameUser(json) else {
                return
            }
            
            callback(user)
        }
    }
    
    
    
    func createOnlineGame(roomId : String,startingPlayer : String) -> OnlineGame?{
        let onlineGame = OnlineGame(startingPlayerId: startingPlayer)
        onlineGamesDatabaseReference.child(roomId).setValue(onlineGame.dictionaryRepresentation)
        return onlineGame
    }
    
    func listenToChangeGameUser(userId : String, with callback : @escaping (GameUser)->Void){
        
        let ref = onlineGamesDatabaseReference.child(userId)
        
        ref.observe(.value) { (snapshot) in
            //print(snapshot)
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let user = GameUser(json) else {
                return
            }
            
            callback(user)
        }
    }
    
    
    func listenToChangeOnlineGame(roomId : String, with callback : @escaping (OnlineGame)->Void){
        
        let ref = onlineGamesDatabaseReference.child(roomId)
        
        ref.observe(.value) { (snapshot) in
            //print(snapshot)
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let game = OnlineGame(json) else {
                return
            }
            
            callback(game)
        }
    }
    
    func updateOnlineGame(roomId : String, onlineGame : OnlineGame){
        let ref = onlineGamesDatabaseReference.child(roomId)
        ref.setValue(onlineGame.dictionaryRepresentation)
    }
    
    func deleteOnlineGame(roomId : String){
        let ref = onlineGamesDatabaseReference.child(roomId)
        ref.setValue(nil)
    }
    
    func createGameRoom(title : String, password : String?) -> Gameroom?{
        guard let uid = self.userId,
            let uname = self.userName else {
                return nil
        }
        
        let gameRoom = Gameroom(title : title, password : password, uid : uid, uname : uname)
        gameRoomsDatabaseReference.child(gameRoom.id).setValue(gameRoom.dictionaryRepresentation)
        return gameRoom
    }
    
    func editQuantityGameRoom(gameRoomId : String,playersQuantity : Int){
        gameRoomsDatabaseReference.child(gameRoomId).child("playersQuantity").setValue("\(playersQuantity)")
        
        if(playersQuantity == 0){
            getGameroomById(roomId: gameRoomId) { (gameRoom) in
                self.deleteGameroom(gameRoom)
            }
        }
    }
    
    func editIsOpenGameRoom(gameRoomId : String,isOpen : Bool){
        gameRoomsDatabaseReference.child(gameRoomId).child("isOpen").setValue(isOpen)
    }
    
    func deleteGameroom(_ gameroom : Gameroom) {
        gameRoomsDatabaseReference.child(gameroom.id).setValue(nil)
        //chatroomsDatabaseReference.child(chatroom.id).removeValue()
    }
    
    
    
    
    func listenToNewGameRoom(with callback : @escaping (Gameroom)->Void){
        
        let ref = gameRoomsDatabaseReference.queryOrdered(byChild: "date")
        
        ref.observe(.childAdded) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let room = Gameroom(json) else {
                return
            }
            
            callback(room)
            
        }
    }
    
    func updateGameRoom(roomId : String, newRoom : Gameroom){
        let ref = gameRoomsDatabaseReference.child(roomId)
        ref.setValue(newRoom.dictionaryRepresentation)
    }
    
    
    func listenToDeleteGameRoom(with callback : @escaping (Gameroom)->Void){
        
        let ref = gameRoomsDatabaseReference.queryOrdered(byChild: "date")
        
        ref.observe(.childRemoved) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let room = Gameroom(json) else {
                return
            }
            
            callback(room)
        }
    }
    
    func listenToChangeGameRoom(with callback : @escaping (Gameroom)->Void){
        
        let ref = gameRoomsDatabaseReference.queryOrdered(byChild: "date")
        
        ref.observe(.childChanged) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let room = Gameroom(json) else {
                return
            }
            
            callback(room)
        }
    }
    
    func listenToChangeSingleGameRoom(roomId : String,with callback : @escaping (Gameroom)->Void){
        
        gameRoomsDatabaseReference.child(roomId).observe(.childChanged) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let room = Gameroom(json) else {
                return
            }
            
            callback(room)
        }
    }
    
    func getGameroomById(roomId : String, with callback : @escaping (Gameroom)->Void){
        
        let ref = gameRoomsDatabaseReference.child(roomId)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let room = Gameroom(json) else {
                return
            }
            
            callback(room)
        }
    }
    
    
    
    func createGameroomPlayer(roomId : String){
        guard let uid = self.userId,
            let uname = self.userName else {
                return
        }
        
        let player = GamePlayer(playerId: uid, playerName: uname)
        gameRoomPlayersDatabaseReference.child(roomId).child(player.playerId).setValue(player.dictionaryRepresentation)
    }
    
    func listenToNewGamePlayer(roomId : String, with callback : @escaping (GamePlayer)->Void){
        
        let ref = gameRoomPlayersDatabaseReference.child(roomId).queryOrdered(byChild: "date")
        
        ref.observe(.childAdded) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let player = GamePlayer(json) else {
                return
            }
            
            callback(player)
            
        }
    }
    
    func listenToChangeGamePlayer(roomId : String, with callback : @escaping (GamePlayer)->Void){
        
        let ref = gameRoomPlayersDatabaseReference.child(roomId)
        
        ref.observe(.childChanged) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let player = GamePlayer(json) else {
                return
            }
            
            callback(player)
            
        }
    }
    
    func updateGamePlayer(roomId : String, gamePlayer : GamePlayer){
        let ref = gameRoomPlayersDatabaseReference.child(roomId).child(gamePlayer.playerId)
        ref.setValue(gamePlayer.dictionaryRepresentation)
    }
    
    func listenToDeleteGamePlayer(roomId : String, with callback : @escaping (GamePlayer)->Void){
        
        let ref = gameRoomPlayersDatabaseReference.child(roomId)
        
        ref.observe(.childRemoved) { (snapshot) in
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            guard let player = GamePlayer(json) else {
                return
            }
            
            callback(player)
            
        }
    }
    
    
    func deleteGameroomPlayer(_ gameroom : Gameroom) {
        guard let uid = self.userId else {
            return
        }
        gameRoomPlayersDatabaseReference.child(gameroom.id).child(uid).setValue(nil)
        //chatroomsDatabaseReference.child(chatroom.id).removeValue()
    }
    
    func deleteOtherGameroomPlayer(gameroom : Gameroom, playerId : String) {
        guard let uid = self.userId else {
            return
        }
        gameRoomPlayersDatabaseReference.child(gameroom.id).child(uid).setValue(nil)
        //chatroomsDatabaseReference.child(chatroom.id).removeValue()
    }
    
  
    
    
    
    
    
    
    
    
}


