//
//  RewardsViewControllerTutorials.m
//  InitialDesign
//
//  Created by David Wiza on 2/16/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "RewardsViewControllerTutorials.h"
#import "Tutorials.h"

extern Tutorials *tutorials;

@interface RewardsViewControllerTutorials ()

@end

@implementation RewardsViewControllerTutorials

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
    [tutorials showTutorialAtX:280 atY:65 withID:TUT_REWARD inView:self.view withOrientation:POINTING_UP withCallback:@selector(showNextTutorial) fromSender:self];
}

- (void)showNextTutorial {
    [tutorials showTutorialAtX:200 atY:450 withID:TUT_CHEST inView:self.view withOrientation:POINTING_DOWN withCallback:NULL fromSender:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
