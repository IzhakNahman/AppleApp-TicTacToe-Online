//
//  ChatViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit

class ChatViewController: ViewController {
    
    var room : Gameroom!
    
    var messages : [ChatMessage] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: SendButton!
    @IBOutlet weak var stackViewBottomLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isHidden = true
        
        self.navigationItem.title = room.title
        
        self.tableView.dataSource = self
        
        //listen to keyboard open
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardOpen(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        addFirebaseListeners()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tableView.addGestureRecognizer(tap)
        
  
    }
    
    @objc func dismissKeyboard() {
        keyBoardClosed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard  self.tabBarController != nil else {
            return
        }
        self.tabBarController!.tabBar.items![1].image = UIImage(systemName: "text.bubble")
        

    }
    
    private func addFirebaseListeners() {
        
        guard let room = self.room else {
            return
        }
        //listen to new messages
        FirebaseManager.manager.listenToNewMessage(roomId: room.id){ [weak self](msg) in
            guard let self = self else { return }
            let rowIndex = self.messages.count
            self.messages.append(msg)
            let rowIndexPath = IndexPath(row: rowIndex, section: 0)
            self.tableView.insertRows(at: [rowIndexPath], with: .automatic)
            //scroll to new message
            self.tableView.scrollToRow(at: rowIndexPath, at: .bottom, animated: true)
            
        }
        
    }
    
    @IBAction func textEditedAction(_ sender: UITextField) {
        guard let text = textField.text, text.count > 0 else {
            UIView.animate(withDuration: 0.5) {
                self.sendButton.isHidden = true
            }
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.sendButton.isHidden = false
        }
    }
    @IBAction func textFieledClickAction(_ sender: Any) {
        self.textField.becomeFirstResponder()
    }
    
    @IBAction func keyboardReturnAction(_ sender: Any) {
        sendMessage()
    }
    
    
    @IBAction func sendMessageAction(_ sender: Any) {
        sendMessage()
       
    }
    
    private func sendMessage() {
        guard let text = textField.text, text.count > 0 , let room = self.room else {
                   return
               }
               
               FirebaseManager.manager.createMessage(roomId: room.id, text: text)
               
               textField.text = ""
               
               keyBoardClosed()
               
           }
           
           private func keyBoardClosed(){
               
               UIView.animate(withDuration: 0.5) {
                   self.sendButton.isHidden = true
               }
               
               //update stackview's bottom
               self.textField.resignFirstResponder()
               self.stackViewBottomLayout.constant = 0
               UIView.animate(withDuration: 0.28) {
                   self.view.layoutSubviews()
               }
    }
    
    @objc func handleKeyboardOpen(notification : Notification) {
        
        //get keyboard height
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let value = notification.userInfo?[key] as? NSValue else {
            return
        }
        
        let height = value.cgRectValue.height - self.navigationController!.navigationBar.frame.height
        
        //update UI according to keyboard's height
        self.stackViewBottomLayout.constant = (height * -1)
        
        UIView.animate(withDuration: 0.28) {
            self.view.layoutSubviews()
        }
    }
    
    
}

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier : String
        if messages[indexPath.row].authorId == FirebaseManager.manager.userId {
            //sent message
            identifier = "cell_out"
        } else {
            //received message
            identifier = "cell_in"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatCell
        
        cell.populate(with: messages[indexPath.row])
        //cell.textLabel?.text = messages[indexPath.row].text
        
        return cell
    }
    
    
    
    
    
}
