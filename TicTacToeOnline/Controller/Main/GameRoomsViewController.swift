//
//  GameRoomsViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase



class GameRoomsViewController: UIViewController {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    var tableArray : [Gameroom] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButton.isEnabled = false
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            guard let self = self else {
                return
            }
            self.addBarButton.isEnabled = true
        }
        gameRoomesListeners()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? OnlineGameViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            nextVC.room = tableArray[indexPath.row]
        }
    }
    
    
    
    func gameRoomesListeners(){
        //listen to new rooms
        FirebaseManager.manager.listenToNewGameRoom { [weak self](room) in
            guard let self = self else { return }
            self.tableArray.sort { (a, b) -> Bool in
                a.createdAt > b.createdAt
            }
            var index = 0
            if self.tableArray.count > 0{
                for i in 0...self.tableArray.count - 1 {
                    if room.createdAt < self.tableArray[i].createdAt  {
                        index += 1
                    }
                }
            }
            self.tableArray.insert(room, at: index)
            let rowIndexPath = IndexPath(row:index, section: 0)
            self.tableView.insertRows(at: [rowIndexPath], with: .automatic)
            
            /*
             let index = self.tableArray.count
             self.tableArray.append(room)
             let rowIndexPath = IndexPath(row: index, section: 0)
             self.tableView.insertRows(at: [rowIndexPath], with: .automatic)
             */
        }
        
        //listen to deleted rooms
        FirebaseManager.manager.listenToDeleteGameRoom { [weak self](room) in
            guard let self = self else { return }
            let index = self.tableArray.lastIndex { (gameRoom) -> Bool in
                NSDictionary(dictionary:  gameRoom.dictionaryRepresentation).isEqual(to: room.dictionaryRepresentation)
            }
            
            guard let newIndex : Int = index else {
                return
            }
            self.tableArray.remove(at: newIndex)
            let rowIndexPath = IndexPath(row: newIndex, section: 0)
            self.tableView.deleteRows(at: [rowIndexPath], with: .automatic)
            
        }
        
        //listen to changed rooms
        FirebaseManager.manager.listenToChangeGameRoom { [weak self](room) in
            guard let self = self else { return }
            let index = self.tableArray.lastIndex { (gameRoom) -> Bool in
                gameRoom.id == room.id
            }
            
            guard let newIndex : Int = index else {
                return
            }
            self.tableArray[newIndex] = room
            let rowIndexPath = IndexPath(row: newIndex, section: 0)
            self.tableView.reloadRows(at: [rowIndexPath], with: .automatic)
        }
        
    }
    
    private func createRoomNumber() -> Int{
        var lastRoomNumber : Int = 0
        guard tableArray.count > 0 else{
            return 0
        }
        tableArray.forEach { (gameRoom) in
            let roomName = gameRoom.title.components(separatedBy: " ")
            if Int(roomName[1]) ?? 0 > lastRoomNumber {
                lastRoomNumber =  Int(roomName[1]) ?? 0
            }
        }
        
        return lastRoomNumber
    }
    
    
    @IBAction func addRoomAction(_ sender: Any) {
        
        if Reachability.connection.isConnectedToNetwork() == false  {
            
            let alert = UIAlertController(title: "No Internet Connection", message: "Check your internet conncection and try again", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                       alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
            
        }else{
        
            let alert = UIAlertController(title: "Create Gameroom", message: nil, preferredStyle: .alert)
            let label = UILabel(frame: CGRect(x: 0, y: 40, width: 270, height:18))
            label.textAlignment = .center
            label.textColor = .red
            label.font = label.font.withSize(12)
            alert.view.addSubview(label)
            alert.addTextField {
                //$0.placeholder = "Gameroom name"
                $0.text = "Room \(self.createRoomNumber()+1)"
                $0.isEnabled = false
            }
            alert.addTextField {
                $0.placeholder = "Gameroom password (Optional)"
                $0.becomeFirstResponder()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let createAction = UIAlertAction(title: "Create", style: .default) { (_) in
                //.. create stuff goes here
                let password : String? = alert.textFields?.last?.text
                guard let title = alert.textFields?.first?.text else{
                    label.text = "Please enter room name to create."
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                guard title.count > 2 else {
                    label.text = "Enter room name of at least 3 characters"
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                label.text = ""
                
                guard let gameRoom = FirebaseManager.manager.createGameRoom(title: title, password: password) else {
                    return
                }
                
                //get in gameroom
                self.moveToOnlineGameViewController(gameRoom: gameRoom, hasPassword: false)
                //self.present(loadVC, animated: true, completion: nil)
                
            }
            alert.addAction(createAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    deinit {
        //do not listen to room updates any more
        FirebaseManager.manager.stopListenToGamerooms()
        
    }
    
    
    func moveToOnlineGameViewController (gameRoom : Gameroom, hasPassword : Bool) {
        
        if hasPassword == true, gameRoom.password != "" {
            let alert = UIAlertController(title: "Join Gameroom", message: nil, preferredStyle: .alert)
            
            let label = UILabel(frame: CGRect(x: 0, y: 40, width: 270, height:18))
            label.textAlignment = .center
            label.textColor = .red
            label.font = label.font.withSize(12)
            alert.view.addSubview(label)
            
            alert.addTextField {
                $0.placeholder = "Password"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let createAction = UIAlertAction(title: "Join", style: .default) { (_) in
                //.. create stuff goes here
                
                guard let password = alert.textFields?.first?.text , password == gameRoom.password else{
                    label.text = "ncorrect password"
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                label.text = ""
                self.loadOnlineGameViewController(gameRoom: gameRoom)
            }
            alert.addAction(createAction)
            
            self.present(alert, animated: true, completion: nil)
        }else{
            loadOnlineGameViewController(gameRoom: gameRoom)
        }
        
    }
    
    func loadOnlineGameViewController(gameRoom : Gameroom){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let loadVCGame = storyboard.instantiateViewController(withIdentifier: "OnlineGameViewController") as? OnlineGameViewController else {
            return
        }
        guard let loadVCChat = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {
            return
        }
        
        
        
        loadVCGame.room = gameRoom
        loadVCChat.room = gameRoom
        
        let tabBarVc = UITabBarController()
        tabBarVc.viewControllers = [loadVCGame, loadVCChat]
        self.navigationController!.pushViewController(tabBarVc, animated: true)
    }
    
    func scrollToLastRow() {
        let indexPath : IndexPath = IndexPath(row: tableArray.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
}


extension GameRoomsViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameroomCell
        cell.populate(with: tableArray[indexPath.row])
        /*
         let room = tableArray[indexPath.row]
         cell.textLabel?.text = room.title
         cell.detailTextLabel?.text = "Created by " + room.ownerName
         */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let currentUid = FirebaseManager.manager.userId else {
            //user not logged in
            return false
        }
        
        //user can delete chatroom only if he is the owner
        return tableArray[indexPath.row].ownerId == currentUid
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        //remove from array
        let room = tableArray.remove(at: indexPath.row)
        
        //remove from firebase
        FirebaseManager.manager.deleteGameroom(room)
        FirebaseManager.manager.deleteGameroomPlayer(room)
        FirebaseManager.manager.deleteOnlineGame(roomId: room.id)
        
        //remove from tableview
        tableView.deleteRows(at: [indexPath], with: .left)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let room = tableArray[indexPath.row]
        
        guard room.playersQuantity<2, room.isOpen == true else {
            return
        }
        moveToOnlineGameViewController(gameRoom: tableArray[indexPath.row],hasPassword: true)
    }
    
    
}

