//
//  ChatMessage.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import Foundation

struct ChatMessage {
    
    let id : String
    let roomId : String
    let authorId : String
    let authorName : String
    let date : Date
    let text : String
    
    init(roomId : String, authorId : String, authorName : String, text : String) {
        self.id = UUID().uuidString
        self.roomId = roomId
        self.authorId = authorId
        self.authorName = authorName
        self.date = Date()
        self.text = text
    }
    
    init?(_ dict : [String:Any]) {
        
        guard let id = dict["id"] as? String,
            let roomId = dict["roomId"] as? String,
            let authorId = dict["authorId"] as? String,
            let authorName = dict["authorName"] as? String,
            let date = dict["date"] as? TimeInterval,
            let text = dict["text"] as? String else {
                return nil
        }
        
        self.id = id
        self.roomId = roomId
        self.authorId = authorId
        self.authorName = authorName
        self.date = Date(timeIntervalSince1970: date)
        self.text = text
    }
    
    var dictionaryRepresentation : [String:Any] {
        return [
            "id":id,
            "roomId":roomId,
            "authorId":authorId,
            "authorName":authorName,
            "date":date.timeIntervalSince1970,
            "text":text
        ]
    }
    
}
