//
//  Multisource.swift
//  Whyd
//
//  Created by Damien Romito on 30/09/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

import Foundation

import UIKit


class Multisource{
    
    let sp: String = ""
    let yt: String = ""
 
    
    init(sources:NSDictionary) {
        
        for source in sources {
             println("You selected cell \(source)!")
        }
        
    }

    required init(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
