//
//  TrackBehaviorViewControllerTutorials.m
//  InitialDesign
//
//  Created by David Wiza on 2/2/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "TrackBehaviorViewControllerTutorials.h"
#import "Tutorials.h"

extern Tutorials *tutorials;

int currentTutorial;
#define NUM_TUTORIALS 2

@interface TrackBehaviorViewControllerTutorials ()

@end

@implementation TrackBehaviorViewControllerTutorials

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [tutorials showTutorialAtX:150 atY:545 withID:TUT_NOTEBOOK_1 inView:self.view withOrientation:POINTING_DOWN withCallback:@selector(showNextTutorial) fromSender:self];
    currentTutorial = 1;
    
}

- (void)showNextTutorial {
    currentTutorial++;
    if (currentTutorial > NUM_TUTORIALS)
        return;
    switch (currentTutorial) {
        case 2:
            [tutorials showTutorialAtX:30 atY:545 withID:TUT_NOTEBOOK_2 inView:self.view withOrientation:POINTING_DOWN withCallback:@selector(showNextTutorial) fromSender:self];
            return;
        case 3:
          /*  [tutorials showTutorialOnControl:self.printEmailTokensRewardsBtn withID:TUT_NOTEBOOK_3 inView:self.view withOrientation:POINTING_DOWN withCallback:@selector(showNextTutorial) fromSender:self]; */
            return;
        default:
            NSLog(@"ERROR: Reached invalid tutorial");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
