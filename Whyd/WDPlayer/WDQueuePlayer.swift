//
//  WDQueuePlayer.swift
//  Whyd
//
//  Created by Damien Romito on 28/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

import UIKit
import AVFoundation

class WDQueuePlayer: AVQueuePlayer {
   //ini
    override func insertItem(item: AVPlayerItem!, afterItem: AVPlayerItem!) {
        
        var exist = false
        
        for i in self.items(){
            if item === i {
                println("swift item \(item)")
                exist = true
            }
            
        }
        if !exist{
            super.insertItem(item, afterItem: afterItem);
        }
    }
}
