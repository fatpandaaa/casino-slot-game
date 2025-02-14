//
//  ViewController.h
//  Liberty Bell
//
//  Created by Lehel Medves on 5/24/13.
//  Copyright (c) 2013 Lehel Medves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <Social/Social.h>
#import <StoreKit/StoreKit.h>
#import <iAd/iAd.h>
#import "General.h"
#import "GameMechanics.h"
#import "GameCenterManager.h"
#import "HelpViewController.h"
#import "Audio.h"

#define kLeaderboardID @"com.tom.macau.leaderboard"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@interface ViewController : UIViewController<GameMechanicsDelegate, GKLeaderboardViewControllerDelegate, GameCenterManagerDelegate, HelpViewControllerDelegate, AudioDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, ADBannerViewDelegate,UIAlertViewDelegate>
{
    NSDictionary *config;
    NSDictionary *texts;
    GameMechanics *gameMechanics;
    NSArray *combinations;
    NSArray *reels;
    NSArray *reelViews;
    NSMutableArray *currentSpinCounts;
    NSDictionary *animations;
    NSMutableArray *cards;
    NSMutableArray *currentCards;
    NSDictionary *social;
    NSMutableDictionary *productObjects;
    
    GameCenterManager *gameCenterManager;
    HelpViewController *helpViewController;
    
    BOOL gameCenterLogged;
    BOOL helpViewVisible;
    
    int itemWidth;
    int itemHeight;
    int rowCount;
    int currentlyRotating;
    int currentWins;
    
    GKLocalPlayer *localPlayer;
    Audio *audio;
    
    NSArray *products;
    SKProductsRequest *productsRequest;
    
    NSArray *productLabels;
    NSArray *productButtons;
    NSArray *bulbs;
    
    IBOutlet UIView* reel1;
    IBOutlet UIView* reel2;
    IBOutlet UIView* reel3;
    IBOutlet UIButton *armButton;
    IBOutlet UILabel *winsLabel;
    IBOutlet UILabel *coinsLabel;
    IBOutlet UILabel *creditsLabel;
    IBOutlet UIButton *leaderBoardButton;
    IBOutlet UIButton *helpButton;
    IBOutlet UIButton *musicButton;
    IBOutlet UILabel *winsTitleLabel;
    IBOutlet UILabel *winsTitleLabel2;
    IBOutlet UILabel *coinsTitleLabel;
    IBOutlet UIButton *virtualArmButton;
    IBOutlet UIView *machineView;
    IBOutlet UIView *winsContainer;
    IBOutlet UIView *coinsContainer;
    IBOutlet UIView *helpButtonContainer;
    IBOutlet UIView *leaderboardButtonContainer;
    IBOutlet UIView *armButtonContainer;
    IBOutlet UIImageView *backgroundImage;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *addCoinButton;
    IBOutlet UIButton *addMaxCoinButton;
    IBOutlet UIButton *closeProductsButton;
    IBOutlet UILabel *product1Label;
    IBOutlet UILabel *product2Label;
    IBOutlet UILabel *product3Label;
    IBOutlet UIButton *product1Button;
    IBOutlet UIButton *product2Button;
    IBOutlet UIButton *product3Button;
    IBOutlet UIView *productsView;
    IBOutlet UIButton *productsButton;
    IBOutlet UIView *betContainer;
    IBOutlet UIView *maxBetContainer;
    IBOutlet UILabel *creditsTitleLabel;
    IBOutlet UILabel *buyCreditsTitle;
    IBOutlet UIView *payoutsContainer;
    IBOutlet UIButton *payoutsButton;
    IBOutlet UIButton *payoutsCloseButton;
    IBOutlet UILabel *payoutsLabel;
    IBOutlet UIImageView *vegasLights;
    
    IBOutlet UIImageView *bulbImage1;
    IBOutlet UIImageView *bulbImage2;
    IBOutlet UIImageView *bulbImage3;
    IBOutlet UIImageView *bulbImage4;
    IBOutlet UIImageView *bulbImage5;
    IBOutlet UIImageView *bulbImage6;
    IBOutlet UIImageView *bulbImage7;
    IBOutlet UIImageView *bulbImage8;
    
    IBOutlet ADBannerView *bannerView;
}

- (void) initializeBeforeAnimationPosition;
- (void) initializeStartingAnimation;
- (void) initializeFonts;
- (void) initializeViews;
- (void) initializeAudio;
- (void) initializeGameCenter;
- (void) addToLeaderboard:(int)score;
- (void) initializeVariables;
- (void) initializeReels;
- (void) refreshCoins:(NSNumber *)animated;
- (void) refreshCredits:(NSNumber *)animated;
- (void) refreshWins:(NSNumber *)animated;
- (void) refreshMusicButton;
- (void) rollOneReel:(NSNumber *)reel;
- (void) rollAllReels;
- (void) setNewY:(NSDictionary *)params;
- (void) calculateWin;
- (void) showHideHelpView;
- (void) addWinVisually:(NSNumber *)win;
- (BOOL) getMusicOn;
- (void) setMusicOn:(BOOL)val;
- (void) showHideButtons:(BOOL)show;
- (void) flashWinningCards;
- (void) flashCard:(UIImageView *)image;
- (void) flashLabel:(UILabel *)label;
- (void) activateHelp;
- (void) share:(NSString *)media;
- (void) activateStartingCredits;
- (void) showHideProducts:(BOOL)show;
- (void) showHidePayouts:(BOOL)show;
- (void) initiateProductPurchase:(SKProduct *)prod;
- (void) initializeStore;
- (void) showHideProductButtons:(BOOL)show;
- (void) bulbShow:(NSNumber *)count;
- (void) flashBulb:(NSNumber *)index;
- (void) giveFreeCredits;

- (IBAction) armButtonTapped:(id)sender;
- (IBAction) leaderBoardButtonTapped:(id)sender;
- (IBAction) helpButtonTapped:(id)sender;
- (IBAction) musicButtonTapped:(id)sender;
- (IBAction) facebookButtonTapped:(id)sender;
- (IBAction) twitterButtonTapped:(id)sender;
- (IBAction) addCoinButtonTapped:(id)sender;
- (IBAction) addMaxCoinButtonTapped:(id)sender;
- (IBAction) product1ButtonTapped:(id)sender;
- (IBAction) product2ButtonTapped:(id)sender;
- (IBAction) product3ButtonTapped:(id)sender;
- (IBAction) productsCloseButtonTapped:(id)sender;
- (IBAction) productsButtonTapped:(id)sender;
- (IBAction) payoutsCloseButtonTapped:(id)sender;
- (IBAction) payoutsButtonTapped:(id)sender;

@end
