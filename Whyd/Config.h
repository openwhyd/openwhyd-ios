//
//  UIConfig.h
//  Whyd
//
//  Created by Damien Romito on 02/02/2014.
//  Copyright (c) 2014 Damien Romito. All rights reserved.
//


/************************************* HELPERS **********************************************/



typedef NS_ENUM(NSUInteger, SearchType) {
    SearchTypeTrack = 0,
    SearchTypePlaylist = 1,
    SearchTypeUser = 2,
};

typedef NS_ENUM(NSUInteger, SearchTrackType) {
    SearchTrackTypeWhyd = 0,
    SearchTrackTypeYoutube = 1,
    SearchTrackTypeSoundclound = 2,
};

#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif
#define IS_IPHONE_5 ( ( double )[ [ UIScreen mainScreen ] bounds ].size.height >=  ( double )568 )
#define IS_SHUFFLING ([[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_SHUFFLE_MODE])?YES:NO


/************************************* ERROR **********************************************/


static NSInteger const ERROR_TRACK_UNAVAILABLE =  9997;
static NSInteger const ERROR_PLAYLIST_UNAVAILABLE =  9999;
static NSInteger const ERROR_PLAYLIST_EMPTY  =  9998;

static NSInteger const ERROR_INTERNET_NO  =  -1009;
static NSInteger const ERROR_AVMEDIA_SERVISES_RESET  =  -11819;
static NSInteger const ERROR_INTERNET_LOST  =  -1005;

/************************************* SETTINGS **********************************************/

static const NSInteger NOTIFICATION_HISTORY_LIMIT = 20;
static float ANIMATION_DISPLAY_DURATION = 0.2;
static NSString* const DEFAULT_DECODE_HTML_DATE = @"1453267797000"; //change if you update the decode.html file

static CGFloat const COMMENT_WIDTH = 230.;


static NSInteger SETTING_ADD_COUNT_BEFORE_RATE_POPUP = 5;
static NSInteger SETTING_ADD_COUNT_BEFORE_RATE_POPUP2 = 10;

static NSInteger SETTING_PLAY_COUNT_BEFORE_RATE_POPUP = 10;
static NSInteger SETTING_PLAY_COUNT_BEFORE_RATE_POPUP2 = 20;
static NSInteger SETTING_FAVORITES_USERS_MAX = 15;




/************************************* NOTIFICATIONS **********************************************/


static NSString* const NOTIFICATION_LOGIN_SUCCESS = @"login_success";
static NSString* const NOTIFICATION_ONBOARDING_SUCCESS = @"onboarding_success";
static NSString* const NOTIFICATION_STREAM_LOADED = @"stream_loaded";
static NSString* const NOTIFICATION_NOTIFICATIONS_UPDATE = @"notifications_update";
static NSString* const NOTIFICATION_NOTIFICATIONS_UPDATE_COUNT_KEY = @"notifications_update_count";
static NSString* const NOTIFICATION_APN_TOKEN_UPDATED = @"notifications_apn_token_updated";
static NSString* const NOTIFICATION_ORIENTATION_LANDSCAPE = @"notifications_orientation_landscape";


/************************************* USERDEFAULT **********************************************/

static NSString * const USERDEFAULT_NOTIFICATIONS = @"userdefault_notifications";
static NSString * const USERDEFAULT_RATE_ASKED = @"userdefault_rate_asked";
static NSString * const USERDEFAULT_RATE_ASKED_SKIP = @"userdefault_rate_asked_skip";

static NSString * const USERDEFAULT_OPENWHYD_INFO = @"userdefault_openwhyd_info";

static NSString * const USERDEFAULT_APN_ASKED = @"userdefault_apn_asked";
static NSString * const USERDEFAULT_APN_LIKES_ASKED = @"userdefault_apn_likes_asked";
static NSString * const USERDEFAULT_APN_POST_ASKED = @"userdefault_apn_post_asked";
static NSString * const USERDEFAULT_APN_UID = @"userdefault_apn_uid";
static NSString * const USERDEFAULT_DECODE_HTML_DATE = @"userdefault_decode_html_date";
static NSString* const USERDEFAULT_DECODE_HTML_CODE = @"userdefault_decode_html_code";

static NSString * const USERDEFAULT_CURRENT_USER= @"userdefault_current_user";
static NSString * const USERDEFAULT_TUTO_SEEN = @"userdefault_tuto_seen";
static NSString * const USERDEFAULT_UPDATE_VER_SKIP = @"userdefault_update_ver_skip";

static NSString* const USERDEFAULT_AUTOSHARE_FB = @"userdefault_autoshare_fb";
static NSString* const USERDEFAULT_AUTOSHARE_TW = @"userdefault_autoshare_tw";
static NSString* const USERDEFAULT_TWITTER_TOK = @"userdefault_twitter_tok";
static NSString* const USERDEFAULT_TWITTER_SEC = @"userdefault_twitter_sec";

static NSString* const USERDEFAULT_ADD_COUNT = @"userdefault_add_count";
static NSString* const USERDEFAULT_PLAY_COUNT = @"userdefault_play_count";
static NSString* const USERDEFAULT_FAVORITES_USERS = @"userdefault_favorites_users";

static NSString* const USERDEFAULT_PREFERENCES_NOTIFICATIONS = @"userdefault_preferences_notifications";
static NSString* const USERDEFAULT_SHUFFLE_MODE = @"userdefault_shuffle_mode";


/************************************* API **********************************************/
static NSString* const API_BASE_URL = @"https://openwhyd.org";

static NSString* const APP_STORE_APP_ID = @"874380201";
static NSString* const APP_DOWNLOAD_LINK = @"http://openwhyd.org";

//LOGIN / REGISTER
static NSString* const API_LOGIN_EMAIL = @"/login?action=login&ajax=1&includeUser=true";
static NSString* const API_FORGOT_PASSWORD = @"/login?action=forgot&ajax=true";
static NSString* const API_REGISTER = @"/register";
static NSString* const API_ONBOARDING = @"/onboarding";
static NSString* const API_LOGIN_FACEBOOK = @"/facebookLogin?action=login&includeUser=true";
static NSString* const API_LINK_FACEBOOK = @"/facebookLogin?action=link";

//USER INFOS
static NSString* const API_USER_UPDATE = @"/api/user";
static NSString* const API_USER_INFOS = @"/api/user?includeSubscr=true&isSubscr=true&countPosts=true&countLikes=true&getVersion=1";
#define API_USER_LIKES(id) [NSString stringWithFormat:@"/u/%@/likes?format=json",(id)]
static NSString* const API_USER_FOLLOW =  @"/api/follow?";
#define API_USER_TRACKS(id) [NSString stringWithFormat:@"/u/%@?format=json",(id)]
#define API_USER_FOLLOWING(id) [NSString stringWithFormat:@"/api/follow/fetchFollowing/%@?isSubscr=true",(id)]
#define API_USER_FOLLOWERS(id) [NSString stringWithFormat:@"/api/follow/fetchFollowers/%@?isSubscr=true",(id)]
static NSString* const API_SEARCH_USER =  @"/search?context=mention";

//PLAY
static NSString* const API_DECODE_SCRIPT_URL = @"http://openwhyd.org/html/decode.html";
#define API_PLAY_COUNT_INCR(id) [NSString stringWithFormat:@"/api/post?action=incrPlayCounter&pId=%@",(id)]


//TRACK
#define API_TRACK_INFO(id) [NSString stringWithFormat:@"/c/%@?format=json",(id)]
static NSString* const API_TRACK_DELETE = @"api/post?action=delete";
#define API_USERS_REPOSTS_POST(id) [NSString stringWithFormat:@"/api/post?action=reposts&pId=%@",(id)]
#define API_USERS_LIKES_POST(id) [NSString stringWithFormat:@"/api/post?action=lovers&pId=%@",(id)]
static NSString* const API_TOGGLE_LIKE = @"/api/post?action=toggleLovePost";
#define API_TRACK_SHARE(id) [NSString stringWithFormat:@"/api/post/%@/sendToUsers",(id)]


//PLAYLIST
static NSString* const API_PLAYLIST = @"/api/playlist";
#define API_PLAYLIST(userId,id) [NSString stringWithFormat:@"u/%@/playlist/%@?format=json&limit=1000",(userId),(id)]

//COMMENT
static NSString* const API_COMMENT_ADD = @"api/post?action=addComment";
static NSString* const API_COMMENT_DELETE = @"api/post?action=deleteComment";

//SEARCH
static NSString* const API_SEARCH_WHYD= @"/search?format=json";
static NSString* const API_SEARCH_YOUTUBE = @"http://gdata.youtube.com/feeds/api/videos?v=2&alt=jsonc&first-index=0&max-results=5";
static NSString* const API_SEARCH_SOUNDCLOUD = @"http://api.soundcloud.com/tracks.json?client_id=76395c48f97de903ff44861e230116bd&limit=5";
static NSString* const API_STREAM = @"/stream?format=json";
static NSString* const API_HOT_ALL = @"/hot?format=json";

//OTHER
#define API_HOT_GENRE(key) [NSString stringWithFormat:@"/hot/%@?format=json",(key)]
static NSString* const API_UPLOAD = @"/upload";
static NSString* const API_NOTIFICATIONS = @"/api/notif";

//MACRO OPEN URL NAVIGATION
#define OPEN_URL_BASE @"whyd://"
#define OPEN_URL_USER(id) [NSString stringWithFormat:@"whyd://user/%@",(id)]


/************************************* NOTIFICATION **********************************************/

static NSString* const APN_EMAIL_SUBSCRIPTION = @"emSub";
static NSString* const APN_PUSH_SUBSCRIPTION = @"mnSub";

static NSString* const APN_EMAIL_ADDYOURTRACK = @"emAdd";
static NSString* const APN_PUSH_ADDYOURTRACK = @"mnAdd";

static NSString* const APN_EMAIL_LIKE = @"emLik";
static NSString* const APN_PUSH_LIKE = @"mnLik";

static NSString* const APN_EMAIL_MENTION = @"emMen";
static NSString* const APN_PUSH_MENTIONN = @"mnMen";

static NSString* const APN_EMAIL_COMMENT = @"emCom";
static NSString* const APN_PUSH_COMMENT = @"mnCom";

static NSString* const APN_EMAIL_FBFRIENDSUBCRIBED= @"emFrd";
static NSString* const APN_PUSH_FBFRIENDSUBCRIBED = @"mnFrd";

static NSString* const APN_EMAIL_ACCEPT= @"emAcc";
static NSString* const APN_PUSH_ACCEPT = @"mnAcc";

static NSString* const APN_PUSH_SEND_TRACK= @"mnSnt";

static NSString* const APN_PUSH_SEND_PLAYLIST = @"mnSnp";




/************************************* FONTS **********************************************/

static NSString* const FONT_AVENIR_NEXT_REGULAR = @"AvenirNext-Regular";
static NSString* const FONT_AVENIR_NEXT_MEDIUM = @"AvenirNext-Medium";
static NSString* const FONT_AVENIR_NEXT_DEMIBOLD = @"AvenirNext-DemiBold";
static const float SIZE_PADDING = 11.0;

static const float SIZE_FONT_6 = 18.0;

static const float SIZE_FONT_5 = 15.0;
static const float SIZE_FONT_4 = 14.0;
static const float SIZE_FONT_3 = 13.0;
static const float SIZE_FONT_2 = 12.0;
static const float SIZE_FONT_1 = 10.5;




#define CORNER_RADIUS 1.5

/************************************* COLORS **********************************************/

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f \
blue:(b)/255.0f alpha:1.0f]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]



#define WDCOLOR_BLUE RGBCOLOR(49, 119, 175)
#define WDCOLOR_BLUE_DARK RGBCOLOR(51, 61, 69)
#define WDCOLOR_BLUE_LIGHT RGBCOLOR(98, 161, 212)
//
#define WDCOLOR_BLACK_TRANSPARENT RGBACOLOR(24, 27, 31,.96)
#define WDCOLOR_BLACK RGBCOLOR(24, 27, 31)
#define WDCOLOR_BLACK_LIGHT RGBCOLOR(90, 99, 110)
#define WDCOLOR_BLACK_LIGHT2 RGBCOLOR(113, 119, 125)
//
#define WDCOLOR_GRAY_DARK2 RGBCOLOR(121, 130, 137)
#define WDCOLOR_GRAY_DARK RGBCOLOR(161, 165, 170)
#define WDCOLOR_GRAY RGBCOLOR(203, 206, 210)
#define WDCOLOR_GRAY_LIGHT RGBCOLOR(211, 215, 218)
#define WDCOLOR_GRAY_LIGHT2 RGBCOLOR(221, 223, 226)
#define WDCOLOR_GRAY_LIGHT_BLUE  RGBCOLOR(226, 232, 235)

#define WDCOLOR_WHITE_DARK RGBCOLOR(237, 240, 241)
#define WDCOLOR_WHITE RGBCOLOR(246, 248, 249)
//
#define WDCOLOR_GREEN RGBCOLOR(62, 173, 85)


////////////

#define WDCOLOR_BLACK_TITLE RGBCOLOR(64, 64, 64)
#define WDCOLOR_GRAY_BORDER RGBCOLOR(217, 223, 227)
#define WDCOLOR_GRAY_BORDER_LIGHT RGBCOLOR(237, 240, 243)

#define WDCOLOR_GRAY_TEXT RGBCOLOR(163,164,166)
#define WDCOLOR_GRAY_TEXT_DARK_MEDIUM RGBCOLOR(146, 147, 149)
#define WDCOLOR_GRAY_TEXT_DARK RGBCOLOR(125,127,129)

#define WDCOLOR_GRAY_BG RGBCOLOR(235, 237, 238)
#define WDCOLOR_GRAY_BG_LIGHT RGBCOLOR(241, 243, 244)
#define WDCOLOR_GRAY_PLACEHOLDER_IMAGE RGBCOLOR(156, 161, 165)
#define WDCOLOR_GRAY_PLACEHOLDER_TEXTVIEW RGBCOLOR(198, 200, 201);
#define WDCOLOR_RED RGBCOLOR(255, 0, 0)

#define UICOLOR_CLEAR [UIColor clearColor]
#define UICOLOR_WHITE [UIColor whiteColor]
#define UICOLOR_BLACK [UIColor blackColor]


/************************************* FLURRY **********************************************/

#define FLURRY_COMMENT_SEND @"comment_send"

#define FLURRY_LIKE_FROM_TRACKCELL_LONGTAP @"like_trackcell_longtap"
#define FLURRY_LIKE_FROM_PLAYER_LONGTAP @"like_player_longtap"
#define FLURRY_LIKE_FROM_TRACK_LONGTAP @"like_track_longtap"
#define FLURRY_LIKE_FROM_TRACK_NABARBUTTON @"like_track_navbar"
#define FLURRY_LIKE_FROM_PLAYER_NABARBUTTON @"like_player_navbar"

//REGISTER
#define FLURRY_REGISTER_FACEBOOK @"register_facebook"
#define FLURRY_REGISTER_EMAIL @"register_email"
#define FLURRY_REGISTER_ACTION @"register_facebook"
#define FLURRY_REGISTER_GENRE_SELECTION @"register_genre_selection"
#define FLURRY_REGISTER_PEOPLE_SUGGESTION @"register_people_selection"

#define FLURRY_TUTO_SKIP @"tuto_skip"
#define FLURRY_TUTO_SUCCESS @"tuto_success"



#define FLURRY_ALLOWNOTIF_POPUP_NO @"allownotif_popup_no"
#define FLURRY_ALLOWNOTIF_NOTIF_NO @"allownotif_notif_no"
#define FLURRY_ALLOWNOTIF_YES @"allownotif_notif_yes"

#define FLURRY_RATE_POPUP_YES @"allownotif_rate_popup_yes"
#define FLURRY_RATE_POPUP_SKIP @"allownotif_rate_popup_skip"

#define FLURRY_UPDATE_SKIP @"update_app_skip"
#define FLURRY_UPDATE_ACCEPTED @"update_app_accepted"


//SHARE
#define FLURRY_SHARE_FROM_TRACKCELL_LONGTAP @"share_track_from_trackcell_longtap"
#define FLURRY_SHARE_FROM_TRACKPAGE_LONGTAP @"share_track_from_trackpage_longtap"
#define FLURRY_SHARE_FROM_TRACKPAGE_NAVBAR @"share_track_from_trackpage_navbar"


#define FLURRY_SHARE_PLAYLIST @"share_playlist"
#define FLURRY_SHARE_TRACK @"share_track"
#define FLURRY_SHARE_WHYD @"share_via_whyd"
#define FLURRY_SHARE_EMAIL @"share_via_email"
#define FLURRY_SHARE_MESSAGE @"share_via_message"
#define FLURRY_SHARE_PASTE_LINK @"share_paste_link"
#define FLURRY_SHARE_FB @"share_via_fb"
#define FLURRY_SHARE_TW @"share_via_tw"


//ADD TRACK

#define FLURRY_ADD_FROM_SEARCH @"add_track_from_search"
#define FLURRY_ADD_FROM_TRACKCELL_LONGTAP @"add_track_from_trackcell_longtap"
#define FLURRY_ADD_FROM_TRACKPAGE_LONGTAP @"add_track_from_trackpage_longtap"
#define FLURRY_ADD_FROM_TRACKPAGE_NAVBAR @"add_track_from_trackpage_navbar"
#define FLURRY_ADD_FROM_PLAYER_NAVBAR @"add_track_from_player_navbar"

//
#define FLURRY_PLAYALL_STREAM @"playall_stream"
#define FLURRY_PLAYALL_HOTTRACK @"playall_hottrack"
#define FLURRY_PLAYALL_PROFIL @"playall_profil"


