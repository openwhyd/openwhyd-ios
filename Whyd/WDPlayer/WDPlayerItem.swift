//
//  WDPlayerItem.swift
//  Whyd
//
//  Created by Damien Romito on 28/07/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

import UIKit
import AVFoundation


class WDPlayerItem: AVPlayerItem {
    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "WDPlayerItemInitNotification"), object: self)
    }
    
    
   deinit {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "WDPlayerItemDeallocNotification"), object: self)
        print("DEALLOOCC SWIFT")
    }
}


