//
//  PlaylistCreateViewController.h
//  Whyd
//
//  Created by Damien Romito on 25/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"

@interface PlaylistCreateViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic, weak) id delegate;
@end

@protocol PlaylistCreateDelegate <NSObject>

- (void)playlistCreated:(Playlist *)playlist;

@end