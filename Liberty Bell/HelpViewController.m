//
//  HelpViewController.m
//  Liberty Bell
//
//  Created by Lehel Medves on 5/26/13.
//  Copyright (c) 2013 Lehel Medves. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController

@synthesize mainViewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initializeFonts
{
    [buyCreditsLabel setFont:[UIFont fontWithName:@"LiberationSansNarrow" size:buyCreditsLabel.font.pointSize]];
    [yourCombinationLabel setFont:[UIFont fontWithName:@"LiberationSansNarrow" size:yourCombinationLabel.font.pointSize]];
    [pullLabel setFont:[UIFont fontWithName:@"LiberationSansNarrow" size:pullLabel.font.pointSize]];
}

- (IBAction) closeButtonTapped:(id)sender
{
    [mainViewDelegate showHideHelpView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeFonts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
