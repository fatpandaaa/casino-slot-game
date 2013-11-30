//
//  ViewController.m
//  Liberty Bell
//
//  Created by Lehel Medves on 5/24/13.
//  Copyright (c) 2013 Lehel Medves. All rights reserved.
//

#import "ViewController.h"

#define KTitle @"No Credits"
#define KStoreButton @"STORE"
#define KWaitButton @"WAIT"

@implementation ViewController

@synthesize config;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initializeVariables];
    [self initializeReels];
    [self initializeGameCenter];
    [self initializeViews];
    [self initializeAudio];
    [self initializeFonts];
    [self initializeStore];
    
    [self activateStartingCredits];
    
    [self refreshWins:[NSNumber numberWithBool:NO]];
    [self refreshCoins:[NSNumber numberWithBool:NO]];
    [self refreshCredits:[NSNumber numberWithBool:NO]];
    [self refreshMusicButton];
    
    [self initializeBeforeAnimationPosition];
    
    float delay = [[[config objectForKey:@"variables"] objectForKey:@"initialDelay"] floatValue];
    
    [self performSelector:@selector(initializeStartingAnimation) withObject:nil afterDelay:delay];
}

- (void) initializeStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    products = [config objectForKey:@"products"];
    NSMutableSet *productIdentifiers = [NSMutableSet setWithCapacity:[products count]];
    for (int i = 0; i < [products count]; i++)
    {
        [productIdentifiers addObject:[[products objectAtIndex:i] objectForKey:@"productId"]];
    }
    
    productObjects = [NSMutableDictionary dictionaryWithCapacity:[products count]];
    
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    
    [self showHideProductButtons:NO];
    
    [productsRequest start];
}

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *theseProducts = response.products;
    
    if ([theseProducts count] > 0)
    {
        for (int i = 0; i < [theseProducts count]; i++)
        {
            SKProduct *temp = [theseProducts objectAtIndex:i];
            
            for (int j = 0; j < [products count]; j++)
            {
                NSString *tempId = [[products objectAtIndex:j] objectForKey:@"productId"];

                if ([temp.productIdentifier isEqualToString:tempId])
                {
                    [productObjects setObject:temp forKey:tempId];
                    
                    break;
                }
            }
        }
    }
    
    if ([theseProducts count] == [products count])
    {
        [self showHideProductButtons:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

- (void) requestDidFinish:(SKRequest *)request
{
}

- (void) request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);
}

- (BOOL) canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (void) initializeBeforeAnimationPosition
{
    CGRect frame;
    
    [productsView setAlpha:0.0];
    [payoutsContainer setAlpha:0.0];
    
    float y = 70.0;
    
    for (NSDictionary *temp in combinations)
    {
        NSArray *thisCombination = [temp objectForKey:@"combination"];
        int win = [[temp objectForKey:@"win"] intValue];
        float x = 40.0;
        
        for (NSString *str in thisCombination)
        {
            UIImageView *image;
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@@ipad.png", str]]];
                [image setFrame:CGRectMake(x+20, y+70, 134, 188)];
                x += image.frame.size.width + 50.0;
            }
            else {
                image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", str]]];
                [image setFrame:CGRectMake(x, y, 50, 70)];
                x += image.frame.size.width + 10.0;
            }
            [payoutsContainer addSubview:image];
        }
        
        x += 40.0;
        
        UILabel *thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 50, 70)];
        
        [thisLabel setBackgroundColor:[UIColor clearColor]];
        [thisLabel setTextColor:[UIColor whiteColor]];
        [thisLabel setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:32.0]];
        
        thisLabel.text = [NSString stringWithFormat:@"%ix", win];
        
        [payoutsContainer addSubview:thisLabel];
        
        y += thisLabel.frame.size.height - 20.0;
    }
    
    frame = musicButton.frame;
    frame.origin.x += frame.size.width;
    [musicButton setFrame:frame];
    
    frame = facebookButton.frame;
    frame.origin.x -= frame.size.width;
    [facebookButton setFrame:frame];
    
    frame = twitterButton.frame;
    frame.origin.x -= frame.size.width;
    [twitterButton setFrame:frame];
    
    frame = productsButton.frame;
    frame.origin.x += frame.size.width;
    [productsButton setFrame:frame];
    
    frame = payoutsButton.frame;
    frame.origin.x += frame.size.width;
    [payoutsButton setFrame:frame];
    
    frame = helpButtonContainer.frame;
    frame.origin.x -= frame.size.width;
    [helpButtonContainer setFrame:frame];
    
    frame = leaderboardButtonContainer.frame;
    frame.origin.x += frame.size.width;
    [leaderboardButtonContainer setFrame:frame];
    
    frame = machineView.frame;
    frame.origin.x += frame.size.width;
    [machineView setFrame:frame];
    
    [armButtonContainer setAlpha:0.0];
    [betContainer setAlpha:0.0];
    [maxBetContainer setAlpha:0.0];
    
    [backgroundImage setAlpha:0.0];
}

- (void) initializeStartingAnimation
{
    [audio playFxWhoosh];
    
    [UIView animateWithDuration:[[animations objectForKey:@"machineSlideTime"] floatValue]
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            [backgroundImage setAlpha:1.0];
            
            CGRect frame = machineView.frame;
            frame.origin.x -= frame.size.width;
            [machineView setFrame:frame];            
        }
        completion:^(BOOL finished){
            [audio playFxSlide];
            
            [UIView animateWithDuration:[[animations objectForKey:@"headerSlideTime"] floatValue]
                delay:0.0
                options:UIViewAnimationOptionCurveEaseOut
                animations:^{
                    CGRect frame = helpButtonContainer.frame;
                    frame.origin.x += frame.size.width;
                    [helpButtonContainer setFrame:frame];
                    
                    frame = leaderboardButtonContainer.frame;
                    frame.origin.x -= frame.size.width;
                    [leaderboardButtonContainer setFrame:frame];
                }
                completion:^(BOOL finished){
                    
                    BOOL musicOn = [self getMusicOn];
                    
                    if (musicOn)
                    {
                        [audio startNextSong];
                    }
                    
                    [audio playFxSlide];
                    
                    [UIView animateWithDuration:[[animations objectForKey:@"sideButtonsSlideTime"] floatValue]
                        delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            CGRect frame;
                            
                            frame = musicButton.frame;
                            frame.origin.x -= frame.size.width;
                            [musicButton setFrame:frame];
                            
                            frame = facebookButton.frame;
                            frame.origin.x += frame.size.width;
                            [facebookButton setFrame:frame];
                            
                            frame = twitterButton.frame;
                            frame.origin.x += frame.size.width;
                            [twitterButton setFrame:frame];
                            
                            frame = productsButton.frame;
                            frame.origin.x -= frame.size.width;
                            [productsButton setFrame:frame];
                            
                            frame = payoutsButton.frame;
                            frame.origin.x -= frame.size.width;
                            [payoutsButton setFrame:frame];
                        }
                        completion:^(BOOL finished){
                            
                            float duration = [[animations objectForKey:@"footerFadeTime"] floatValue];
                            float delay = [[animations objectForKey:@"footerFadeDelay"] floatValue];
                            
                            [audio performSelector:@selector(playFxPop) withObject:nil afterDelay:0];
                            [audio performSelector:@selector(playFxPop) withObject:nil afterDelay:delay];
                            [audio performSelector:@selector(playFxPop) withObject:nil afterDelay:(2 * delay)];
                            
                            [UIView animateWithDuration:duration
                                delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                                animations:^{
                                    [betContainer setAlpha:1.0];
                                }
                                completion:^(BOOL finished){
                                }
                             ];
                            [UIView animateWithDuration:duration
                                delay:delay
                                options:UIViewAnimationOptionCurveEaseOut
                                animations:^{
                                    [maxBetContainer setAlpha:1.0];
                                }
                                completion:^(BOOL finished){
                                }
                             ];
                            [UIView animateWithDuration:duration
                                delay:(2 * delay)
                                options:UIViewAnimationOptionCurveEaseOut
                                animations:^{
                                    [armButtonContainer setAlpha:1.0];
                                }
                                completion:^(BOOL finished){
                                    [self activateHelp];
                                }
                             ];
                        }
                     ];
                }
             ];
        }
     ];
}

- (void) activateHelp
{
    NSNumber *firstRun = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"];
    
    BOOL isThisTheFirstRun = YES;
    
    if (firstRun != nil)
    {
        isThisTheFirstRun = [firstRun boolValue];
    }
    
    if (isThisTheFirstRun)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"firstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self helpButtonTapped:helpButton];
    }
}

- (void) activateStartingCredits
{
    NSNumber *firstRun = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstRunCredits"];
    
    BOOL isThisTheFirstRun = YES;
    
    if (firstRun != nil)
    {
        isThisTheFirstRun = [firstRun boolValue];
    }
    
    if (isThisTheFirstRun)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"firstRunCredits"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        int startingCredits = [[[config objectForKey:@"variables"] objectForKey:@"startingCredits"] intValue];
        
        [gameMechanics increaseCredits:startingCredits];
        
        [self refreshCredits:[NSNumber numberWithBool:NO]];
    }
    
    CGRect frame = bannerView.frame;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    frame.origin.y = bounds.size.height;
    
    bannerView.delegate = self;
    [bannerView setFrame:frame];
}

- (void) initializeFonts
{
    [winsTitleLabel setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:winsTitleLabel.font.pointSize]];
    [winsTitleLabel2 setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:winsTitleLabel2.font.pointSize]];
    [coinsTitleLabel setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:coinsTitleLabel.font.pointSize]];
    [creditsTitleLabel setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:creditsTitleLabel.font.pointSize]];
    [buyCreditsTitle setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:buyCreditsTitle.font.pointSize]];
    [payoutsLabel setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:payoutsLabel.font.pointSize]];
    
    [coinsLabel setFont:[UIFont fontWithName:@"LiberationSansNarrow" size:coinsLabel.font.pointSize]];
    [winsLabel setFont:[UIFont fontWithName:@"LiberationSansNarrow" size:winsLabel.font.pointSize]];
    [creditsLabel setFont:[UIFont fontWithName:@"LiberationSansNarrow" size:creditsLabel.font.pointSize]];
    
    for (UILabel *temp in productLabels)
    {
        [temp setFont:[UIFont fontWithName:@"SteelfishRg-Regular" size:temp.font.pointSize]];
    }
}

- (void) initializeAudio
{
    audio = [[Audio alloc] init];
    audio.mainViewDelegate = self;
    
    [audio initializeBackgroundMusic];
    [audio initializeSoundEffects];
}

- (void) initializeViews
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
         helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController-Ipad" bundle:[NSBundle mainBundle]];
    }
    else {
         helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:[NSBundle mainBundle]];
    }
    helpViewController.mainViewDelegate = self;
    
    [helpViewController.view setAlpha:0.0];
    
    [self.view addSubview:helpViewController.view];
    
    [vegasLights setAlpha:0.0];
}

- (void) showHideHelpView
{
    float duration = [[animations objectForKey:@"helpFadeTime"] floatValue];
    
    if (!helpViewVisible)
    {
        [audio playFxWhoosh];
        
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                [helpViewController.view setAlpha:1.0];
            }
            completion:^(BOOL finished){
            }
        ];
    }
    else
    {
        [audio playFxWhoosh];
        
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                [helpViewController.view setAlpha:0.0];
            }
            completion:^(BOOL finished){
            }
         ];
    }
    
    helpViewVisible = !helpViewVisible;
}

- (void) initializeGameCenter
{
    if ([GameCenterManager isGameCenterAvailable])
    {
        gameCenterManager = [[GameCenterManager alloc] init];
        
        [gameCenterManager setDelegate:self];
        [gameCenterManager authenticateLocalUser];
    }
    else
    {
        // The current device does not support Game Center.
    }
}

- (void) addToLeaderboard:(int)score
{
    if (gameCenterLogged)
    {
        NSArray *arr = [[NSArray alloc] initWithObjects:localPlayer.playerID, nil];
        
        GKLeaderboard *board = [[GKLeaderboard alloc] initWithPlayerIDs:arr];
        
        if (board != nil)
        {
            board.timeScope = GKLeaderboardTimeScopeAllTime;
            board.range = NSMakeRange(1, 1);
            board.category = kLeaderboardID;
            
            [board loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
                if (error != nil)
                {
                    // handle the error.
                }
                else
                {
                    if (scores == nil) scores = 0;
                    
                    int64_t newScore = ((GKScore*)[scores objectAtIndex:0]).value + score;
                    
                    [gameCenterManager reportScore:newScore forCategory:kLeaderboardID];
                }
            }];
        }
    }
}

- (void) initializeVariables
{
    config = [General readConfig];
    
    reels = [config objectForKey:@"reels"];
    combinations = [config objectForKey:@"combinations"];
    animations = [config objectForKey:@"animations"];
    
    texts = [config objectForKey:@"texts"];
    
    productLabels = [NSArray arrayWithObjects:product1Label, product2Label, product3Label, nil];
    
    productButtons = [NSArray arrayWithObjects:product1Button, product2Button, product3Button, nil];
    
    rowCount = [[config objectForKey:@"rowCount"] intValue];
    
    itemWidth = [[config objectForKey:@"itemWidth"] intValue];
    itemHeight = [[config objectForKey:@"itemHeight"] intValue];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        itemWidth=itemWidth*2.3;
        itemHeight=itemHeight*2.1;
    }
    
    gameMechanics = [[GameMechanics alloc] init];
    gameMechanics.mainViewDelegate = self;
    
    reelViews = [NSArray arrayWithObjects:reel1, reel2, reel3, nil];
    
    currentSpinCounts = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0; i < [reels count]; i++)
    {
        [currentSpinCounts insertObject:[NSNumber numberWithInt:0] atIndex:i];
    }
    
    gameCenterLogged = NO;
    helpViewVisible = NO;
    
    social = [config objectForKey:@"social"];
    
    bulbs = [NSArray arrayWithObjects:bulbImage1, bulbImage2, bulbImage3, bulbImage4, bulbImage5, bulbImage6, bulbImage7, bulbImage8, nil];
    
    for (UIImageView *temp in bulbs)
    {
        [temp setAlpha:0.0];
    }
    
    currentWins = 0;
}

- (void) showHideProductButtons:(BOOL)show
{
    float duration = [[[config objectForKey:@"variables"] objectForKey:@"productButtonFadeTime"] floatValue];
    
    for (int i = 0; i < [productButtons count]; i++)
    {
        UIButton *temp = (UIButton *)[productButtons objectAtIndex:i];
        
        if (show)
        {
            [UIView animateWithDuration:duration
                delay:0.0
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                    [temp setAlpha:1.0];
                }
                completion:^(BOOL finished){
                }
             ];
        }
        else
        {
            [UIView animateWithDuration:duration
                delay:0.0
                options:UIViewAnimationOptionCurveEaseOut
                animations:^{
                    [temp setAlpha:0.0];
                }
                completion:^(BOOL finished){
                }
             ];
        }
    }
}

- (void) initializeReels
{
    cards = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0; i < [reels count]; i++)
    {
        UIView *currentReel = [reelViews objectAtIndex:i];
        
        currentCards = [NSMutableArray arrayWithCapacity:(rowCount + 2)];
        
        for (int j = 0; j < [[reels objectAtIndex:i] count] + 2; j++)
        {
            int rowToUse = j % [[reels objectAtIndex:i] count];
            
            UIImageView *currentImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, j * itemHeight, itemWidth, itemHeight)];
            
            NSString *currentItem = [[reels objectAtIndex:i] objectAtIndex:rowToUse];
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                 [currentImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@@ipad.png", currentItem]]];
            }
            else {
                 [currentImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", currentItem]]];
            }
            [currentReel addSubview:currentImage];
            [currentCards addObject:currentImage];
        }
        
        int rand = arc4random() % rowCount;
        CGRect frame = currentReel.frame;
        
        frame.origin.y = -rand * itemHeight;
        
        [currentReel setFrame:frame];
        
        [cards insertObject:currentCards atIndex:i];
    }
}

- (void) rollOneReel:(NSNumber *)reel
{
    currentlyRotating++;
    
    UIView *thisReel = [reelViews objectAtIndex:[reel intValue]];
    
    int spinCount = 0;
    float duration = [[animations objectForKey:[NSString stringWithFormat:@"spinTime%i", [reel intValue] + 1] ] floatValue];
    
    float S = [[currentSpinCounts objectAtIndex:[reel intValue]] intValue]; // number of spins
    float A = duration / S; // average spin time
    float C = [[animations objectForKey:@"spinSpeedDiversityPercentage"] floatValue]; // maximum deviation
    
    float a = (2 * A * C) / (S - 1);
    float b = A  - A * C - (2 * A * C / (S - 1));
    
    while (spinCount <= S)
    {
        spinCount++;
        
        duration = a * spinCount + b;
        
        int currentY = thisReel.frame.origin.y;
        int newY = currentY - itemHeight;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:newY], thisReel, [NSNumber numberWithFloat:duration], nil] forKeys:[NSArray arrayWithObjects:@"newY", @"view", @"duration", nil]];
        
        [self performSelectorOnMainThread:@selector(setNewY:) withObject:params waitUntilDone:NO];
        
        [NSThread sleepForTimeInterval:duration];
    }
    
    [audio playFxReelStop];
    
    currentlyRotating--;
    
    if (currentlyRotating == 0)
    {
        [audio stopFxReelClick];
        
        [self performSelectorOnMainThread:@selector(calculateWin) withObject:nil waitUntilDone:NO];
    }
}

- (void) flashBulb:(NSNumber *)index
{
    UIImageView *img = (UIImageView *)[bulbs objectAtIndex:[index intValue]];
    float duration = [[[config objectForKey:@"variables"] objectForKey:@"bulbFadeTime"] floatValue];
    
    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
            [img setAlpha:1.0];
            [vegasLights setAlpha:1.0];
        }
        completion:^(BOOL finished){
            [UIView animateWithDuration:duration
                delay:0.0
                options:UIViewAnimationOptionCurveEaseOut
                animations:^{
                    [img setAlpha:0.0];
                    [vegasLights setAlpha:0.0];
                }
                completion:^(BOOL finished){
                }
            ];
        }
     ];
}

- (void) bulbShow:(NSNumber *)count
{
    int total = [count intValue];
    int counter = -1;
    float duration = [[[config objectForKey:@"variables"] objectForKey:@"bulbFadeTime"] floatValue];
    
    for (int i = 0; i < total; i++)
    {
        counter++;
        
        if (counter >= 8)
        {
            counter = 0;
        }
        
        [self performSelectorOnMainThread:@selector(flashBulb:) withObject:[NSNumber numberWithInt:counter] waitUntilDone:NO];
        
        [NSThread sleepForTimeInterval:(2 * duration)];
    }
}

- (void) calculateWin
{
    BOOL isWin = NO;
    NSMutableArray *currentConfiguration = [NSMutableArray arrayWithCapacity:[reelViews count]];
    
    currentCards = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0; i < [reelViews count]; i++)
    {
        UIView *currentReel = [reelViews objectAtIndex:i];
        
        int currentY = currentReel.frame.origin.y;
        int position = abs((currentY / itemHeight) % rowCount);
        
        [currentCards addObject:[[cards objectAtIndex:i] objectAtIndex:position]];
        
        NSString *thisTile = [[reels objectAtIndex:i] objectAtIndex:position];
        
        [currentConfiguration insertObject:thisTile atIndex:i];
    }
    
    int match = [gameMechanics getCombination:[NSArray arrayWithArray:currentConfiguration]];
    
    //match = 2;
    
    if (match != -1)
    {
        BOOL jackpot = [[[combinations objectAtIndex:match] objectForKey:@"jackpot"] boolValue];
        int win = [[[combinations objectAtIndex:match] objectForKey:@"win"] intValue] * [gameMechanics getCoinsUsed];
        
        if (jackpot)
        {
            float delay = [[[config objectForKey:@"variables"] objectForKey:@"jackpotDelay"] floatValue];
            
            [audio playFxCheers];
            
            [audio performSelector:@selector(playFxJackpot) withObject:nil afterDelay:delay];
            
            [self performSelectorInBackground:@selector(bulbShow:) withObject:[NSNumber numberWithInt:96]];
        }
        else
        {
            [audio playFxWinningCombination];
            
            [self performSelectorInBackground:@selector(bulbShow:) withObject:[NSNumber numberWithInt:32]];
        }
        
        [self performSelectorInBackground:@selector(addWinVisually:) withObject:[NSNumber numberWithInt:win]];
        
        [self addToLeaderboard:win];
        isWin = YES;
        //NSLog(@"%@", [combinations objectAtIndex:match]);
    }
    
    [gameMechanics removeCoins];
    
    [self refreshCoins:[NSNumber numberWithBool:NO]];
    if (!isWin) {
         [self performSelectorOnMainThread:@selector(checkForCredits) withObject:nil waitUntilDone:NO];
    }
    [self showHideButtons:YES];
}

- (void) giveFreeCredits
{
    //freeCreditsPerDay
    
    NSDate *now = [NSDate date];
    NSDate *last = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastFreeCreditsDate"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setLocale:[NSLocale systemLocale]];
    
    NSString *today = [formatter stringFromDate:now];
    NSString *lastDate = [formatter stringFromDate:last];
    
    if ((lastDate == nil) || (![lastDate isEqualToString:today]))
    {
        int freeCredits = [[[config objectForKey:@"variables"] objectForKey:@"freeCreditsPerDay"] intValue];
        
        [gameMechanics increaseCredits:freeCredits];
        
        [self refreshCredits:[NSNumber numberWithBool:NO]];
        
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"lastFreeCreditsDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *alertTitle = [[config objectForKey:@"texts"] objectForKey:@"freeCreditsTitle"];
        NSString *alertText = [[config objectForKey:@"texts"] objectForKey:@"freeCreditsText"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void) showHideButtons:(BOOL)show
{
    float duration = [[animations objectForKey:@"buttonFadeTime"] floatValue];
    
    if (!show)
    {
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                [helpButton setAlpha:0.0];
                [leaderBoardButton setAlpha:0.0];
                [armButton setAlpha:0.0];
                [addCoinButton setAlpha:0.0];
                [addMaxCoinButton setAlpha:0.0];
            }
            completion:^(BOOL finished){
                [virtualArmButton setEnabled:NO];
            }
         ];
    }
    else
    {
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                [helpButton setAlpha:1.0];
                [leaderBoardButton setAlpha:1.0];
                [armButton setAlpha:1.0];
                [addCoinButton setAlpha:1.0];
                [addMaxCoinButton setAlpha:1.0];
            }
            completion:^(BOOL finished){
                [virtualArmButton setEnabled:YES];
            }
         ];
    }
}

- (void) bannerViewDidLoadAd:(ADBannerView *)banner
{
    CGRect frame = bannerView.frame;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    frame.origin.y = bounds.size.height - frame.size.height;
    
    [bannerView setFrame:frame];
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
}

- (void) flashWinningCards
{
    for (int i = 0; i < [currentCards count]; i++)
    {
        UIImageView *temp = [currentCards objectAtIndex:i];
        
        float delay = [[animations objectForKey:@"cardFlashDelay"] floatValue];
        
        [self performSelector:@selector(flashCard:) withObject:temp afterDelay:(i * delay)];
    }
}

- (void) addWinVisually:(NSNumber *)win
{
    float initialDelay = [[[config objectForKey:@"variables"] objectForKey:@"coinDropInitialDelay"] floatValue];
    float cardsDelay = [[animations objectForKey:@"delayAfterFlashingCards"] floatValue];
    
    [NSThread sleepForTimeInterval:initialDelay];
    
    [self performSelectorOnMainThread:@selector(flashWinningCards) withObject:nil waitUntilDone:NO];
    
    [NSThread sleepForTimeInterval:cardsDelay];
    
    int currentWin = [win intValue];
    float delay = [[[config objectForKey:@"variables"] objectForKey:@"coinDropDelay"] floatValue];
    
    for (int i = 0; i < currentWin; i += 5)
    {
        int toAdd = 5;
        
        currentWins += toAdd;
        
        if (currentWins > currentWin)
        {
            toAdd -= currentWins - currentWin;
            
            currentWins = currentWin;
        }
        
        [gameMechanics addWin:toAdd];
        [gameMechanics increaseCredits:toAdd];
        
        [audio playFxCoinDropping];
        
        [self performSelectorOnMainThread:@selector(refreshWins:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(refreshCredits:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        
        [NSThread sleepForTimeInterval:delay];
    }
}

- (void) setNewY:(NSDictionary *)params;
{
    float newY = [[params objectForKey:@"newY"] intValue];
    float duration = [[params objectForKey:@"duration"] floatValue];
    UIView *view = [params objectForKey:@"view"];
    CGRect frame;
    
    if (-newY >= (rowCount + 1) * itemHeight)
    {
        frame = view.frame;
        
        frame.origin.y += rowCount * itemHeight;
        
        [view setFrame:frame];
        
        newY += rowCount * itemHeight;
    }
    
    frame = view.frame;
    
    frame.origin.y = newY;
    
    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveLinear
        animations:^{
            [view setFrame:frame];
        }
        completion:^(BOOL finished){
        }
    ];
}

- (void) rollAllReels
{
    currentlyRotating = 0;
    
    for (int i = 0; i < [reelViews count]; i++)
    {
        int min = [[[[config objectForKey:@"spins"] objectAtIndex:i] objectForKey:@"min"] intValue];
        int max = [[[[config objectForKey:@"spins"] objectAtIndex:i] objectForKey:@"max"] intValue];
        
        int rand = (arc4random() % (max - min + 1)) + min;
        
        [currentSpinCounts replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:rand]];
    }
    
    [audio playFxReelClick];
    
    for (int i = 0; i < [reelViews count]; i++)
    {
        [self performSelectorInBackground:@selector(rollOneReel:) withObject:[NSNumber numberWithInt:i]];
    }
}

- (void) refreshCoins:(NSNumber *)animated
{
    int coins = [gameMechanics getCoinsUsed];
    
    [coinsLabel setText:[NSString stringWithFormat:@"%i", coins]];
    
    if ([animated boolValue])
    {
        [self flashLabel:coinsLabel];
    }
}

- (void) refreshCredits:(NSNumber *)animated
{
    int credits = [gameMechanics getCredits];
    [creditsLabel setText:[NSString stringWithFormat:@"%i", credits]];
    
    if ([animated boolValue])
    {
        [self flashLabel:creditsLabel];
    }
}

- (void) flashLabel:(UILabel *)label
{
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:label.frame];
    
    duplicateLabel.text = label.text;
    duplicateLabel.textColor = [UIColor whiteColor];
    duplicateLabel.font = label.font;
    duplicateLabel.backgroundColor = [UIColor clearColor];
    duplicateLabel.textAlignment = label.textAlignment;
    
    [label.superview addSubview:duplicateLabel];
    
    float duration = [[animations objectForKey:@"numberHighlightTime"] floatValue];
    float scale = [[animations objectForKey:@"numberHighlightScale"] floatValue];
    
    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            [duplicateLabel setTransform:CGAffineTransformScale(duplicateLabel.transform, scale, scale)];
            [duplicateLabel setAlpha:0.0];
        }
        completion:^(BOOL finished){
            [duplicateLabel removeFromSuperview];
        }
     ];
}

- (void) flashCard:(UIImageView *)image
{
    UIImageView *duplicateImage = [[UIImageView alloc] initWithFrame:image.frame];
    
    duplicateImage.backgroundColor = [UIColor clearColor];
    [duplicateImage setImage:image.image];
    
    [image.superview.superview.superview addSubview:duplicateImage];
    
    CGRect frame = duplicateImage.frame;
    
    frame.origin.x += image.superview.frame.origin.x + image.superview.superview.frame.origin.x;
    frame.origin.y = image.superview.superview.frame.origin.y;
    
    [duplicateImage setFrame:frame];
    
    float duration = [[animations objectForKey:@"imageHighlightTime"] floatValue];
    float scale = [[animations objectForKey:@"imageHighlightScale"] floatValue];
    
    [audio playFxAppear];
    
    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            [duplicateImage setTransform:CGAffineTransformScale(duplicateImage.transform, scale, scale)];
            [duplicateImage setAlpha:0.0];
        }
        completion:^(BOOL finished){
        [duplicateImage removeFromSuperview];
        }
     ];
}

- (void) refreshWins:(NSNumber *)animated
{
    //int wins = [gameMechanics getWins];
    
    //[winsLabel setText:[NSString stringWithFormat:@"%i", wins]];
    
    [winsLabel setText:[NSString stringWithFormat:@"%i", currentWins]];
    
    if ([animated boolValue])
    {
        [self performSelectorOnMainThread:@selector(flashLabel:) withObject:winsLabel waitUntilDone:NO];
    }
}

- (IBAction) leaderBoardButtonTapped:(id)sender
{
    if (gameCenterLogged)
    {
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        
        if (leaderboardController != NULL)
        {
            leaderboardController.category = kLeaderboardID;
            
            leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderboardController.leaderboardDelegate = self;
            
            [audio playFxWhoosh];
            
            [self presentViewController:leaderboardController animated:YES completion:nil];
        }
    }
}

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [audio playFxWhoosh];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) processGameCenterAuth: (NSError*) error
{
    if (error == nil)
    {
        gameCenterLogged = YES;
        localPlayer = [GKLocalPlayer localPlayer];
    }
}

- (void) showGameCenterLogin:(UIViewController *)viewcontroller
{
    [self presentViewController:viewcontroller animated:YES completion:nil];
}

- (void) scoreReported: (NSError*) error
{
    //NSLog(@"%@", error);
}

- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error
{
    
}

- (void) setMusicOn:(BOOL)val
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:val] forKey:@"music"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) getMusicOn
{
    NSObject *musicOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"music"];
    
    BOOL valueToUse = YES;
    
    if (musicOn != nil)
    {
        valueToUse = [(NSNumber *)musicOn boolValue];
    }
    
    return valueToUse;
}

- (void) refreshMusicButton
{
    BOOL valueToUse = [self getMusicOn];
    
    if (valueToUse)
    {
        [musicButton setSelected:YES];
    }
    else
    {
        [musicButton setSelected:NO];
    }
}

- (IBAction) musicButtonTapped:(id)sender
{
    BOOL valueToUse = [self getMusicOn];
    
    valueToUse = !valueToUse;
    
    [self setMusicOn:valueToUse];
    
    [self refreshMusicButton];
    
    if (valueToUse)
    {
        [audio startNextSong];
    }
    else
    {
        [audio stopBackgroundSound];
    }
}

-(void)checkForCredits{
    if ([gameMechanics getCredits] == 0) {
        [self addAlertView];
    }
}
-(void)addAlertView{
    NSString *creditMessage = [config objectForKey:@"creditMessage"];
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:KTitle
                              message:creditMessage
                              delegate:self
                              cancelButtonTitle:KStoreButton
                              otherButtonTitles:KWaitButton, nil];
    [alertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self productsButtonTapped:self];
    }else if (buttonIndex == 1){
        
    }
}

- (IBAction) armButtonTapped:(id)sender
{
    currentWins = 0;
    
    [self refreshWins:[NSNumber numberWithBool:NO]];
    
    int currentCredits = [gameMechanics getCredits];
    
        int singleBetValue = [[[config objectForKey:@"variables"] objectForKey:@"singleBetValue"] intValue];
        
        if (currentCredits < singleBetValue)
        {
            return;
        }
        
        float delay = [[[config objectForKey:@"variables"] objectForKey:@"reelRotationDelay"] floatValue];
        
        [self showHideButtons:NO];
        
        if ([gameMechanics getCoinsUsed] == 0)
        {
            [gameMechanics addCoinsUsed:singleBetValue];
            
            [audio playFxInsertCoin];
            
            [self refreshCoins:[NSNumber numberWithBool:YES]];
        }
        
        int creditsDropped = [gameMechanics getCoinsUsed];
        
        [gameMechanics decreaseCredits:creditsDropped];
        
        [self refreshCredits:[NSNumber numberWithBool:YES]];
        
        [audio performSelector:@selector(playFxArmPulled) withObject:nil afterDelay:0.0];
        
        [self performSelector:@selector(rollAllReels) withObject:nil afterDelay:delay];
}
- (IBAction) helpButtonTapped:(id)sender
{
    [self showHideHelpView];
}

- (IBAction) facebookButtonTapped:(id)sender
{
    [self share:SLServiceTypeFacebook];
}

- (IBAction) twitterButtonTapped:(id)sender
{
    [self share:SLServiceTypeTwitter];
}

- (void) share:(NSString *)media
{
    SLComposeViewController *socialView = [SLComposeViewController composeViewControllerForServiceType:media];
    
    [socialView setInitialText:[social objectForKey:@"socialText"]];
    [socialView addURL:[NSURL URLWithString:[social objectForKey:@"socialLink"]]];
    [socialView addImage:[UIImage imageNamed:@"Default@2x.png"]];
    
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result)
    {
        
        [socialView dismissViewControllerAnimated:YES completion:nil];
        
        switch(result)
        {
            case SLComposeViewControllerResultDone:
            {
                NSString *title = [social objectForKey:@"socialThankYouTitle"];
                NSString *message = [social objectForKey:@"socialThankYouMessage"];
                
                UIAlertView *messageView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [messageView show];
                
                break;
            }
            case SLComposeViewControllerResultCancelled:
            {
            }
            default:
            {
                break;
            }
        }};
    
    [socialView setCompletionHandler:completionHandler];
    
    [self presentViewController:socialView animated:YES completion:^(){
    }];
}

- (IBAction) addCoinButtonTapped:(id)sender
{
    int maxBetValue = [[[config objectForKey:@"variables"] objectForKey:@"maxBetValue"] intValue];
    int singleBetValue = [[[config objectForKey:@"variables"] objectForKey:@"singleBetValue"] intValue];
    
    int currentCredits = [gameMechanics getCredits];
    int currentCoins = [gameMechanics getCoinsUsed];
    
        if ((currentCoins < maxBetValue) && (currentCoins + singleBetValue <= currentCredits))
        {
            [gameMechanics addCoinsUsed:singleBetValue];
            
            [audio playFxInsertCoin];
            
            [self refreshCoins:[NSNumber numberWithBool:YES]];
        }
}

- (IBAction) addMaxCoinButtonTapped:(id)sender
{
    int maxBetValue = [[[config objectForKey:@"variables"] objectForKey:@"maxBetValue"] intValue];
    int currentCredits = [gameMechanics getCredits];
        if (currentCredits >= maxBetValue)
        {
            [gameMechanics removeCoins];
            [gameMechanics addCoinsUsed:maxBetValue];
            
            [audio playFxInsertCoin];
            
            [self refreshCoins:[NSNumber numberWithBool:YES]];
        }
}

- (void) showHideProducts:(BOOL)show
{
    float duration = [[animations objectForKey:@"productsFadeTime"] floatValue];
    
    if (show)
    {
        [audio playFxWhoosh];
        
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                [productsView setAlpha:1.0];
            }
            completion:^(BOOL finished){
            }
         ];
    }
    else
    {
        [audio playFxWhoosh];
        
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                [productsView setAlpha:0.0];
            }
            completion:^(BOOL finished){
            }
         ];
    }
}

- (void) showHidePayouts:(BOOL)show
{
    float duration = [[animations objectForKey:@"payoutsFadeTime"] floatValue];
    
    if (show)
    {
        [audio playFxWhoosh];
        
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                [payoutsContainer setAlpha:1.0];
            }
            completion:^(BOOL finished){
            }
         ];
    }
    else
    {
        [audio playFxWhoosh];
        
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                [payoutsContainer setAlpha:0.0];
            }
            completion:^(BOOL finished){
            }
         ];
    }
}

- (void) initiateProductPurchase:(SKProduct *)prod
{
    [self showHideProductButtons:NO];
    
    SKPayment *payment = [SKPayment paymentWithProduct:prod];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction) product1ButtonTapped:(id)sender
{
    [self initiateProductPurchase:[productObjects objectForKey:@"credit_pack_1"]];
}

- (IBAction) product2ButtonTapped:(id)sender
{
    [self initiateProductPurchase:[productObjects objectForKey:@"credit_pack_2"]];
}

- (IBAction) product3ButtonTapped:(id)sender
{
    [self initiateProductPurchase:[productObjects objectForKey:@"credit_pack_3"]];
}

- (IBAction) productsCloseButtonTapped:(id)sender
{
    [self showHideProducts:NO];
}

- (IBAction) payoutsCloseButtonTapped:(id)sender
{
    [self showHidePayouts:NO];
}

- (IBAction) productsButtonTapped:(id)sender
{
    [self showHideProducts:YES];
}

- (IBAction) payoutsButtonTapped:(id)sender
{
    [self showHidePayouts:YES];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
}

// enable purchased features

- (void) provideContent:(NSString *)productId
{
    for (NSDictionary *temp in products)
    {
        if ([[temp objectForKey:@"productId"] isEqualToString:productId])
        {
            [gameMechanics addCredits:[[temp objectForKey:@"credits"] intValue]];
            
            [self refreshCredits:[NSNumber numberWithInt:[gameMechanics getCredits]]];
            
            NSString *alertTitle = [texts objectForKey:@"productsAlertTitle"];
            NSString *alertText = [texts objectForKey:@"productsAlertText"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil];
            
            [alert show];
        }
    }
}

// removes the transaction from the queue and posts a notification with the transaction result

- (void) finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
    
    [self showHideProductButtons:YES];
}

// called when the transaction was successful

- (void) completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

// called when a transaction has been restored and successfully completed

- (void) restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

// called when a transaction has failed

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        [self showHideProductButtons:YES];
    }
}

// called when the transaction status is updated

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
