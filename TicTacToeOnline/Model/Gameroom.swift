//
//  Gameroom.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import Foundation

struct Gameroom {
    
    var id : String
    var title : String
    var password : String
    var ownerId : String
    var ownerName : String
    var playersQuantity : Int
    var createdAt : Date
    var isOpen : Bool
    
    
    init(title : String, password : String?, uid : String, uname : String) {
        //UUID - Universal Unique IDentifier
        self.id = UUID().uuidString
        self.title = title
        self.password = password ?? ""
        self.ownerId = uid
        self.ownerName = uname
        self.playersQuantity = 1
        self.createdAt = Date() //new date is now
        self.isOpen = true
    }
    
    init?(_ dict : [String:Any]) {
        guard let id = dict["id"] as? String,
            let title = dict["title"] as? String,
            let password = dict["password"] as? String?,
            let ownerId = dict["ownerId"] as? String,
            let playersQuantity = dict["playersQuantity"] as? String,
            let ownerName = dict["ownerName"] as? String,
            let createdAt = dict["createdAt"] as? TimeInterval,
            let isOpen = dict["isOpen"] as? Bool else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.password = password ?? ""
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.playersQuantity = Int(playersQuantity) ?? 0
        self.createdAt = Date(timeIntervalSince1970: createdAt)
        self.isOpen = isOpen
    }
    
    var dictionaryRepresentation : [String:Any] {
        return [
            "id":id,
            "title":title,
            "password":password,
            "ownerId":ownerId,
            "ownerName":ownerName,
            "playersQuantity":"\(playersQuantity)",
            "createdAt":createdAt.timeIntervalSince1970,
            "isOpen":isOpen
        ]
    }
}
