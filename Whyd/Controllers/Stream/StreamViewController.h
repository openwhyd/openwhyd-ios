//
//  StreamViewController.h
//  Whyd
//
//  Created by Damien Romito on 06/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "TracksListViewController.h"

@interface StreamViewController : TracksListViewController
- (void)reload:(void (^)())success failure:(void (^)(NSError *error))failure;
@end

