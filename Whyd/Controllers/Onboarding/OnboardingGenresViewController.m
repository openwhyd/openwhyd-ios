//
//  OnboardingGenresViewController.m
//  Whyd
//
//  Created by Damien Romito on 01/05/14.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "OnboardingGenresViewController.h"
#import "OnboardingGenreCell.h"
#import "WDActivityIndicatorView.h"
#import "WDClient.h"
#import "User.h"
#import "OnboardingSuggestionsViewController.h"
#import "MainViewController.h"
#import "Genre.h"

static NSString* GenreCollectionIdentifier = @"GenreCollectionIdentifier";


@interface OnboardingGenresViewController ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *genresArray;
@property (nonatomic, strong) NSMutableArray *selectedGenres;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;
@end

@implementation OnboardingGenresViewController


- (void)viewWillAppear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO ];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //NAVBAR
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    [super viewWillAppear:animated];
    

}



- (void)loadView
{
    
    [super loadView];
    self.navigationItem.hidesBackButton = YES;


    self.title = [NSLocalizedString(@"WhoAreYou", nil) uppercaseString];

    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionNext)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    self.view.backgroundColor = WDCOLOR_WHITE;
    
    //COLLECTION VIEW
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    CGFloat width =self.view.frame.size.width/2 - 8;
    layout.itemSize = CGSizeMake( width, width *  0.75);
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    self.collectionView.backgroundColor = WDCOLOR_WHITE;
    [self.collectionView registerClass:[OnboardingGenreCell class] forCellWithReuseIdentifier:GenreCollectionIdentifier];
    
    
    //HEADER
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , -56, self.view.frame.size.width, 55)];
    infoLabel.text = NSLocalizedString(@"PickSomeGenresYouLike", nil);
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_MEDIUM size:SIZE_FONT_3];
    infoLabel.textColor = WDCOLOR_BLACK_TITLE;
    [self.collectionView addSubview: infoLabel];
    
    [self.view addSubview:self.collectionView];
    

    self.genresArray = [Genre all];
    self.selectedGenres = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 11);
    self.collectionView.contentInset = UIEdgeInsetsMake(65, 3, 0,  11);
}


#pragma -mark Actions

- (void)actionNext
{
    if (self.selectedGenres.count) {
        [Flurry logEvent:FLURRY_REGISTER_ACTION];

        [self.loadingView startAnimating];
        
        //Genres list
        NSString *genres = @"";
        for (Genre *genre in self.selectedGenres) {
            genres = [NSString stringWithFormat:@"%@%@,", genres, genre.key ];
        }
        
        //Parameters
        NSDictionary *parameters = @{@"ajax":@"people",
                                     @"genres": genres };
        
        
        [[WDClient client] POST:API_ONBOARDING parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.loadingView stopAnimating];
            NSMutableArray *usersSuggested = [NSMutableArray new];
             NSMutableArray *uIdsToFollowed = [NSMutableArray new];
            
            for (NSDictionary *u in responseObject) {
                User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:u error:nil];
                NSLog(@"USER %@", user);
                
               // if (user.isSubscribing != 1) {
                    [uIdsToFollowed addObject:user.id];
                    user.isSubscribing = YES;
                //}
                [usersSuggested addObject:user];
            }
            
            
            
            OnboardingSuggestionsViewController *vc = [[OnboardingSuggestionsViewController alloc] initWithSuggestedUsers:usersSuggested];
            

            vc.uIdsToFollowed = uIdsToFollowed;
            [self.navigationController pushViewController:vc animated:YES];
            [Flurry logEvent:FLURRY_REGISTER_PEOPLE_SUGGESTION];

            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"ERROR %@", error);
            
            [self.loadingView stopAnimating];
        }];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nothing", nil)
                                                        message:NSLocalizedString(@"YouNeedToSelectAtLeastOneGenre", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
   
}

#pragma -mark Collection iew Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.genresArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    OnboardingGenreCell *cell=[self.collectionView dequeueReusableCellWithReuseIdentifier:GenreCollectionIdentifier forIndexPath:indexPath];
    
    cell.genre = [self.genresArray objectAtIndex:indexPath.row];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Genre *genre = [self.genresArray objectAtIndex:indexPath.row];
    OnboardingGenreCell *cell = (OnboardingGenreCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!genre.isSelected  ) {
        [self.selectedGenres addObject:genre];
        cell.checked = YES;
    }else
    {
        cell.checked = NO;
        [self.selectedGenres removeObject:genre];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING ONBOARDING GENRE");
    [super didReceiveMemoryWarning];
}

@end
