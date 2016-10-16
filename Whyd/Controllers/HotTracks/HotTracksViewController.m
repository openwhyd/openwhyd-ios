//
//  HotTracksViewController.m
//  Whyd
//
//  Created by Damien Romito on 13/03/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "HotTracksViewController.h"
#import "WDPlayerManager.h"
#import "UIViewController+WD.h"
#import "UIImage+Additions.h"

static NSString * const KEY_DEFAULT_GENRE = @"default_genre";
static CGFloat const HOT_BUTTON_IMAGE_WIDTH = 11.;

@interface HotTracksViewController ()
@property (nonatomic, strong) UIButton *hotTrackButton;
@property (nonatomic, strong) GenresView *genresView;
@property (nonatomic, strong) NSArray *genresArray;


@end

@implementation HotTracksViewController



- (void)loadView
{

    [super loadView];
    self.title = [NSLocalizedString(@"HotTracks", nil) uppercaseString];
    [self makeAsMainViewController];
    
    /********* HEADER *********/
    self.hotTrackButton = [[UIButton alloc] initWithFrame:CGRectMake(-1, -1, self.view.frame.size.width + 2, 45)];
    self.hotTrackButton.backgroundColor = UICOLOR_WHITE;
    self.hotTrackButton.layer.borderColor = WDCOLOR_GRAY_BORDER_LIGHT.CGColor;
    self.hotTrackButton.layer.borderWidth = 1.;
    [self.hotTrackButton addTarget:self action:@selector(actionOpenGenres) forControlEvents:UIControlEventTouchUpInside];
    UIImage *openImage = [UIImage imageNamed:@"HotTrackButtonOpenfilter"];
    [self.hotTrackButton setImage:openImage forState:UIControlStateNormal];
    self.hotTrackButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.hotTrackButton setTitleColor:WDCOLOR_BLUE forState:UIControlStateNormal];
    self.hotTrackButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_DEMIBOLD size:SIZE_FONT_3];
    self.tableView.tableHeaderView = self.hotTrackButton;

    /********* GENRES VIEWS *********/
    

    self.genresView = [[GenresView alloc] init];
    self.genresView.delegate = self;
    self.genresView.hidden = YES;
    self.genresView.alpha = 0;
    self.genresView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    

    self.genresArray = [Genre allHasAllItem:YES];
    [self.view addSubview:self.genresView];
    
    self.genresView.genresArray = self.genresArray;
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_DEFAULT_GENRE]) {
        NSString * key = [[NSUserDefaults standardUserDefaults] valueForKey:KEY_DEFAULT_GENRE];
        [self.genresArray enumerateObjectsUsingBlock:^(Genre *genre, NSUInteger idx, BOOL *stop) {
            if ([genre.key isEqualToString:key]) {
                self.genresView.selectedIndex = idx;
                [self pickGenre:genre];
                
            }
        }];
        
    }else
    {
        [self pickGenre:[self.genresArray objectAtIndex:0]];        
    }
    

  

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.genresView.frame = self.view.bounds;
    

}

- (void)updateHotButtonTitle:(NSString *)titleString
{
    CGFloat width = self.view.frame.size.width /2;
    [self.hotTrackButton setTitle:[NSString stringWithFormat:@"%@",titleString] forState:UIControlStateNormal];
    [self.hotTrackButton.titleLabel sizeToFit];
    self.hotTrackButton.imageEdgeInsets = UIEdgeInsetsMake(0., width+ self.hotTrackButton.titleLabel.frame.size.width/2 + HOT_BUTTON_IMAGE_WIDTH, 2., 0.);
    self.hotTrackButton.titleEdgeInsets = UIEdgeInsetsMake(0., width- self.hotTrackButton.titleLabel.frame.size.width/2 - HOT_BUTTON_IMAGE_WIDTH, 0., HOT_BUTTON_IMAGE_WIDTH);
}


#pragma mark Actions



- (void)actionOpenGenres
{
    [self actionDisplayGenres:self.genresView.hidden];
}

- (void)actionDisplayGenres:(BOOL)displayed
{
    if (displayed) {
        self.genresView.hidden = NO;
        self.genresView.backgroundView = [[WDBackgroundBlurView alloc] initWithFrame:self.genresView.frame];
        [self.genresView.backgroundView showInView:self.view];
        [self.view bringSubviewToFront:self.genresView];
        self.genresView.backgroundView.alpha = 1;
        [UIView animateWithDuration:ANIMATION_DISPLAY_DURATION animations:^{
            self.genresView.alpha = 1;
            self.genresView.backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }else
    {
        [UIView animateWithDuration:ANIMATION_DISPLAY_DURATION animations:^{
            self.genresView.alpha = 0;
            self.genresView.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.genresView.backgroundView hide];
            self.genresView.hidden = YES;

        }];
    }
}



- (void)pickGenre:(Genre *)genre
{
    genre.isSelected = YES;
    NSString *newUrlString;
    if ([genre.name isEqualToString:@"GenreAll"]) {
        newUrlString = API_HOT_ALL;
    }else
    {
        newUrlString = API_HOT_GENRE(genre.key);
    }

    if ( !self.playlist || ![newUrlString isEqualToString:self.playlist.url]) {
        self.playlist = [Playlist new];
        self.playlist.fromHotTracks = YES;
        self.playlist.url = newUrlString;
        self.playlist.name = [NSString stringWithFormat:@"%@ - %@",NSLocalizedString(@"HotTracks", nil),[genre.key capitalizedString ] ];
        self.playlist.shuffleEnable = NO;
        [self updateHotButtonTitle:[NSLocalizedString(genre.name, nil) uppercaseString]];
        [self reload];

        [[NSUserDefaults standardUserDefaults] setObject:genre.key forKey:KEY_DEFAULT_GENRE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self actionDisplayGenres:NO];    

}

- (void)actionPlayAll
{
    [Flurry logEvent:FLURRY_PLAYALL_HOTTRACK];
    
    [super actionPlayAll];
}




@end
