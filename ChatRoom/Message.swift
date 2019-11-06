//
//  Message.swift
//  ChatRoom
//
//  Created by Alan Luo on 11/2/19.
//  Copyright © 2019 iLtc. All rights reserved.
//

import UIKit

class Message: NSObject {
    public var message: String
    public var name: String
    public var time: String
    
    init(_ message: String, withName: String, andTime: String) {
        self.message = message;
        self.name = withName;
        self.time = andTime;
    }
}
