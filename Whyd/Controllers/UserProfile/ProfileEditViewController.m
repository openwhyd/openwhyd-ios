//
//  ProfileEditViewController.m
//  Whyd
//
//  Created by Damien Romito on 28/04/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "UIImageView+WebCache.h"
#import "WDClient.h"
#import "AFHTTPRequestOperation.h"
#import "WDActivityIndicatorView.h"
#import "SDImageCache.h"
#import "UserLinks.h"


#define PLACEHOLDER_STRING NSLocalizedString(@"ProfileEditBiographie", nil)
#define STRING_CAMERA_ROLL NSLocalizedString(@"ProfileCameraRoll", nil)
#define STRING_TAKE  NSLocalizedString(@"ProfileTakePhoto", nil)

static const CGFloat PROFILE_IMAGE_SIZE = 90;
static const CGFloat BACKGROUND_SIZE = 480;

@interface ProfileEditViewController ()<UITextViewDelegate, UIScrollViewDelegate, WDTextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem* saveButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) WDTextField *fullnameTextField;
@property (nonatomic, strong) WDTextField *locationTextField;
@property (nonatomic, strong) WDTextField *websiteTextField;
@property (nonatomic, strong) UITextView *biographyTextView;
@property (nonatomic) BOOL isEditing;
@property (nonatomic, weak) UIImageView *currentImageView;
@property (nonatomic, strong) WDActivityIndicatorView *loadingView;

@property (nonatomic, strong) NSString *profileImageUrlNew;
@property (nonatomic, strong) NSString *backgroundImageUrlNew;
@property (nonatomic, strong) UIView *currentResponder;

@end

@implementation ProfileEditViewController

- (instancetype)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.title = [NSLocalizedString(@"ProfileEditTitle", nil) uppercaseString];
    self.view.backgroundColor = WDCOLOR_WHITE;
    
    
    self.navigationItem.backBarButtonItem = [WDViews barButtonItemBack];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = WDCOLOR_BLUE;
    
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)  style:UIBarButtonItemStyleDone target:self action:@selector(actionSave)];
 
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    //PHOTOS
    UILabel *photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 30, self.view.frame.size.width, 13)];
    photoLabel.text = [NSLocalizedString(@"ProfileEditPhotos", nil) uppercaseString];
    photoLabel.textColor = WDCOLOR_GRAY_TEXT_DARK_MEDIUM;
    photoLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    [self.scrollView addSubview:photoLabel];
    
    UIButton *profilePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 90)];
    profilePhotoButton.backgroundColor = UICOLOR_WHITE;
    [profilePhotoButton setTitle:NSLocalizedString(@"ProfileEditPhotoProfile", nil) forState:UIControlStateNormal];
    profilePhotoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 0);
    profilePhotoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [profilePhotoButton setTitleColor:WDCOLOR_BLACK_LIGHT forState:UIControlStateNormal];
    profilePhotoButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_4];
    [profilePhotoButton addTarget:self action:@selector(actionProfilePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:profilePhotoButton];
    
    self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 15, 60, 60)];
    self.profileImageView.layer.cornerRadius = 30;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    [profilePhotoButton addSubview:self.profileImageView];

    

    
    UIButton *backgroundPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 141, self.view.frame.size.width, 90)];
    backgroundPhotoButton.backgroundColor = UICOLOR_WHITE;
    [backgroundPhotoButton setTitle:NSLocalizedString(@"ProfileEditPhotoBackground", nil) forState:UIControlStateNormal];
    backgroundPhotoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 0);
    backgroundPhotoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backgroundPhotoButton setTitleColor:WDCOLOR_BLACK_LIGHT forState:UIControlStateNormal];
    backgroundPhotoButton.titleLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_4];
    [backgroundPhotoButton addTarget:self action:@selector(actionBackgroundPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:backgroundPhotoButton];
    
    UIImageView *placeholderBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EditProfileIconBackgroundEmpty"]];
    placeholderBackground.frame = CGRectMake(11, 15, 60, 60);
    [backgroundPhotoButton addSubview:placeholderBackground];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:placeholderBackground.frame];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [backgroundPhotoButton addSubview:self.backgroundImageView];
    
    
    //INFORMATIONS
    UILabel *informationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 260, self.view.frame.size.width, 13)];
    informationsLabel.text = [NSLocalizedString(@"ProfileEditInformation", nil) uppercaseString];
    informationsLabel.textColor = WDCOLOR_GRAY_TEXT_DARK_MEDIUM;
    informationsLabel.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    [self.scrollView addSubview:informationsLabel];
    
    
    self.fullnameTextField = [[WDTextField alloc] initWithYPosition:280];
    self.fullnameTextField.placeholder = NSLocalizedString(@"ProfileEditFullnamePlaceholder", nil);
    self.fullnameTextField.labelString =  NSLocalizedString(@"ProfileEditFullname", nil) ;
    self.fullnameTextField.delegate = self;
    [self.scrollView addSubview:self.fullnameTextField];

    self.locationTextField = [[WDTextField alloc] initWithYPosition:self.fullnameTextField.frame.origin.y + self.fullnameTextField.frame.size.height + 1 ];
    self.locationTextField.labelString = NSLocalizedString(@"ProfileEditLocation", nil);
    self.locationTextField.placeholder = NSLocalizedString(@"ProfileEditLocationPlaceholder", nil);
    self.locationTextField.delegate = self;
    [self.scrollView addSubview:self.locationTextField];
    
    self.websiteTextField = [[WDTextField alloc] initWithYPosition:self.locationTextField.frame.origin.y + self.fullnameTextField.frame.size.height + 1];
    self.websiteTextField.placeholder = NSLocalizedString(@"ProfileEditWebsitePlaceholder", nil) ;
    self.websiteTextField.labelString = NSLocalizedString(@"ProfileEditWebsite", nil) ;
    self.websiteTextField.delegate = self;
    [self.scrollView addSubview:self.websiteTextField];
    
    self.biographyTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.websiteTextField.frame.origin.y + self.fullnameTextField.frame.size.height + 1, self.view.frame.size.width, 90)];
    self.biographyTextView.backgroundColor = UICOLOR_WHITE;
    self.biographyTextView.textContainerInset = UIEdgeInsetsMake(15, 11, 15, 11);
    self.biographyTextView.font = [UIFont fontWithName:FONT_AVENIR_NEXT_REGULAR size:SIZE_FONT_3];
    self.biographyTextView.delegate = self;
    self.biographyTextView.textColor = WDCOLOR_BLUE;
    self.biographyTextView.returnKeyType = UIReturnKeyDone;
    [self.scrollView addSubview:self.biographyTextView];
    

    self.loadingView = [WDActivityIndicatorView activityIndicatorInView:self.view];
    
    [self configureView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.frame;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.biographyTextView.frame.origin.y + self.biographyTextView.frame.size.height + 90);
    
}


- (void)configureView
{
    NSURL *imageURL = [NSURL URLWithString:[self.user imageUrl:UserImageSizeMedium]];
    [self.profileImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"EditProfileIconProfileAvatarEmpty"]];
    
    NSURL *backgroundURL = [NSURL URLWithString:self.user.imageCoverUrl];
    [self.backgroundImageView sd_setImageWithURL:backgroundURL];
    
    self.fullnameTextField.text = self.user.name;
    
    self.locationTextField.text = self.user.loc;
    
    self.websiteTextField.text = self.user.lnk.home;
    
    if (self.user.bio.length) {
        self.biographyTextView.text = self.user.bio;
    }else
    {
        [self biographyViewIsPlaceHolderStyle:YES];
    }
    

}


- (void)biographyViewIsPlaceHolderStyle:(BOOL)placeholderStyle
{
    if (!placeholderStyle) {
        self.biographyTextView.text = @"";
        self.biographyTextView.textColor = WDCOLOR_BLUE;
    }else
    {
        self.biographyTextView.text = PLACEHOLDER_STRING;
        self.biographyTextView.textColor = WDCOLOR_GRAY_PLACEHOLDER_TEXTVIEW;
        self.biographyTextView.selectedRange = NSMakeRange(0,0);
    }
}

- (void) keyboardWillShow:(NSNotification *)note
{
    
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    

    CGFloat bottomTextField = self.currentResponder.frame.origin.y + self.currentResponder.frame.size.height - self.scrollView.contentOffset.y;
    CGFloat topKeyboard = self.view.frame.size.height - keyboardBounds.size.height;

     if (bottomTextField > topKeyboard) {
        self.isEditing = YES;
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y +(bottomTextField - topKeyboard));


        [UIView commitAnimations];
        
        self.isEditing = NO;
     }

}

- (void)keyboardWillHide:(NSNotification *)notification {

}

- (void) makeViewVisible:(UIView*)view
{
    CGFloat bottomTextField = view.frame.origin.y + view.frame.size.height - self.scrollView.contentOffset.y;
    CGFloat topKeyboard = self.view.frame.size.height - 216;
    
    if (bottomTextField > topKeyboard) {
        
        self.isEditing = YES;
        
        [UIView animateWithDuration:.27 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y +(bottomTextField - topKeyboard));
        } completion:^(BOOL finished) {
            self.isEditing = NO;
        }];
    }
}

#pragma -mark Actions

- (void)actionProfilePhoto
{
    self.currentImageView = self.profileImageView;
    [self actionOpenUpdatePhoto];
}

- (void)actionBackgroundPhoto
{
    self.currentImageView = self.backgroundImageView;
    [self actionOpenUpdatePhoto];
}


- (void)actionSave
{
    
    [self.view endEditing:YES];
    
    self.user.name = self.fullnameTextField.text;
    self.user.loc = self.locationTextField.text;
    
    if (!self.user.lnk) {
        self.user.lnk = [[UserLinks alloc] init];
    }
    self.user.lnk.home = self.websiteTextField.text;
    self.user.bio = ([self.biographyTextView.text isEqualToString:PLACEHOLDER_STRING])?@"":self.biographyTextView.text;
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.user.name,@"name",
                                       self.user.loc, @"loc",
                                       self.user.lnk.home, @"lnk_home",
                                       self.user.bio, @"bio",
                                        nil];
    

    
    if (self.profileImageUrlNew) {
        [parameters setObject:self.profileImageUrlNew forKey:@"img"];
    }
    if (self.backgroundImageUrlNew) {
        [parameters setObject:self.backgroundImageUrlNew forKey:@"cvrImg"];
    }
    
    [self.loadingView startAnimating];
    
    [[WDClient client] POST:API_USER_UPDATE parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.navigationItem.rightBarButtonItem = nil;
        [self.loadingView stopAnimating];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        if (self.profileImageUrlNew) {
            [[SDImageCache sharedImageCache] removeImageForKey:[self.user imageUrl:UserImageSizeMedium] fromDisk:YES];
            [[SDImageCache sharedImageCache] removeImageForKey:[self.user imageUrl:UserImageSizeLarge] fromDisk:YES];
            [[SDImageCache sharedImageCache] removeImageForKey:[self.user imageUrl:UserImageSizeSmall] fromDisk:YES];
            self.profileImageUrlNew = nil;
        }
        if (self.backgroundImageUrlNew) {
            [[SDImageCache sharedImageCache] removeImageForKey:self.user.imageCoverUrl fromDisk:YES];
            self.backgroundImageUrlNew = nil;
        }



    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Operation Error: %@", error);
        [self.loadingView stopAnimating];
        self.navigationItem.rightBarButtonItem = nil;

    }];
}

- (void) actionOpenUpdatePhoto
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:STRING_CAMERA_ROLL,STRING_TAKE, nil];
    [actionSheet showInView:self.scrollView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if  ([buttonTitle isEqualToString:STRING_CAMERA_ROLL]) {
        [self startMediaBrowserFromViewController:self.navigationController usingDelegate:self fromCameraRoll:YES];
    }
    else if ([buttonTitle isEqualToString:STRING_TAKE]) {
        [self startMediaBrowserFromViewController:self.navigationController usingDelegate:self fromCameraRoll:NO];

    }
    
}

#pragma -mark WDTextField Delegate
- (void)textFieldDidBeginEditing:(WDTextField *)textField
{
   // [self makeViewVisible:textField];
    self.currentResponder = textField;
    
    if (textField == self.websiteTextField)
    {
        self.biographyTextView.selectedRange = NSMakeRange(0,0);
    }

}

- (BOOL)textFieldShouldReturn:(WDTextField *)textField
{
    if (textField == self.fullnameTextField) {
        [self.locationTextField becomeFirstResponder];
        return NO;

    }else if (textField == self.locationTextField)
    {
        [self.websiteTextField becomeFirstResponder];
        return NO;

    }else if (textField == self.websiteTextField)
    {
        [self.biographyTextView becomeFirstResponder];
        self.biographyTextView.selectedRange = NSMakeRange(0,0);
        return NO;
    }
    

    
    return YES;
}

- (BOOL)textField:(WDTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.navigationItem.rightBarButtonItem = self.saveButton;

    return YES;
}


#pragma mark TextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{    self.currentResponder = textView;

    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
//    [self makeViewVisible:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}



- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            
            CGAffineTransform t = CGAffineTransformIdentity;
            self.view.transform = CGAffineTransformTranslate(t , 0, 0 );
            
        } completion:^(BOOL finished) {
            
        }];
        return NO;
    }
    
    //PLACEHOLDER
    if ( range.length == 1 && range.location == 0) {
        [self biographyViewIsPlaceHolderStyle:YES];
        
        return NO;
    }
    else if ([textView.text isEqualToString:PLACEHOLDER_STRING]) {
        [self biographyViewIsPlaceHolderStyle:NO];
    }
    
    self.navigationItem.rightBarButtonItem = self.saveButton;

    
    return YES;
}

#pragma SCROLLVIEW Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!self.isEditing)
    {
        [self.view endEditing:YES];
        
    }

}

#pragma MEdia BRowser

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate fromCameraRoll:(BOOL)fromCameraRoll{
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.navigationBar.tintColor = WDCOLOR_BLUE;
    mediaUI.navigationBar.translucent = NO;
    
    if (!fromCameraRoll) {
        mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:  UIImagePickerControllerSourceTypeCamera];
    }
    
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [self presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}


- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
 
    UIImage *imageToUse = (UIImage *) [info objectForKey:  UIImagePickerControllerOriginalImage];

    //FIX ORIENTATION IMAGE
    if (imageToUse.imageOrientation != UIImageOrientationUp)
    {
        UIGraphicsBeginImageContextWithOptions(imageToUse.size, NO, imageToUse.scale);
        [imageToUse drawInRect:(CGRect){0, 0, imageToUse.size}];
        imageToUse = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    CGFloat size = (self.currentImageView == self.profileImageView)?PROFILE_IMAGE_SIZE:BACKGROUND_SIZE;
    
    imageToUse = [self squareImageWithImage:imageToUse scaledToSize:CGSizeMake(size, size)];

    NSData *data = [[NSData alloc]  initWithData:UIImageJPEGRepresentation(imageToUse, 0.8f)];
    

    self.currentImageView.image = imageToUse;

    //loading
    [self.loadingView startAnimating];
    self.navigationItem.rightBarButtonItem = nil;

    [WDClient uploadImageWithData:data success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"response %@", responseObject);
        
        NSString *newImageUrl = [responseObject valueForKeyPath:@"file.path"];
        
        if (self.currentImageView == self.profileImageView) {
            self.profileImageUrlNew = newImageUrl;
        }else
        {
            self.backgroundImageUrlNew = newImageUrl;
        }
        [self.loadingView stopAnimating];
        self.navigationItem.rightBarButtonItem = self.saveButton;

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Operation Error: %@", error);
        [self.loadingView stopAnimating];
        self.navigationItem.rightBarButtonItem = self.saveButton;

    }];

//    
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [picker release];
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
