//
//  HelpViewController.h
//  Liberty Bell
//
//  Created by Lehel Medves on 5/26/13.
//  Copyright (c) 2013 Lehel Medves. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HelpViewControllerDelegate <NSObject>

- (void) showHideHelpView;

@end

@interface HelpViewController : UIViewController{
    
    IBOutlet UIButton *closeButton;
    IBOutlet UILabel *pullLabel;
    IBOutlet UILabel *buyCreditsLabel;
    IBOutlet UILabel *yourCombinationLabel;
    
    id <HelpViewControllerDelegate> mainViewDelegate;
    
}

- (void) initializeFonts;

- (IBAction) closeButtonTapped:(id)sender;

@property (nonatomic, retain) id <HelpViewControllerDelegate> mainViewDelegate;

@end
