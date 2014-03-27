//
//  BehaviorsViewControllerTutorials.m
//  InitialDesign
//
//  Created by David Wiza on 2/16/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "TrackingBehaviorViewControllerTutorials.h"
#import "Tutorials.h"

extern Tutorials *tutorials;

int currentTutorial;

@interface TrackingBehaviorViewControllerTutorials ()

@end

@implementation TrackingBehaviorViewControllerTutorials

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
    [tutorials showTutorialAtX:70 atY:115 withID:TUT_BEHAVIORS_1 inView:self.tableView withOrientation:POINTING_UP withCallback:@selector(showNextTutorial) fromSender:self];
    currentTutorial = 1;
}

- (void)showNextTutorial
{
    int x;
    int y;
    currentTutorial++;
    switch (currentTutorial) {
        case 2:
            x = self.currBalanceLbl.frame.origin.x + 5;
            y = self.currBalanceLbl.frame.origin.y;
            [tutorials showTutorialAtX:x atY:y withID:TUT_BEHAVIORS_2 inView:self.view withOrientation:POINTING_DOWN withCallback:@selector(showNextTutorial) fromSender:self];
            break;
        case 3:
            [tutorials showTutorialOnControl:self.stickerScrollView withID:TUT_BEHAVIORS_3 inView:self.view withOrientation:POINTING_DOWN withCallback:NULL fromSender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
