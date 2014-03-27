//
//  RewardPricesViewControllerTutorials.m
//  Parenting+
//
//  Created by David Wiza on 1/25/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "RewardPricesViewControllerTutorials.h"

@interface RewardPricesViewControllerTutorials ()

@end

bool touchShouldHideTutorial = false;

@implementation RewardPricesViewControllerTutorials

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
    [tutorials showTutorialOnControl:self.RewardLbl withID:TUT_REWARD_PRICES_1 inView:self.contentView withOrientation:POINTING_NONE withCallback:@selector(showTutorialTwo) fromSender:self];
}

- (void) keyboardHide
{
    [super keyboardHide];
    if (touchShouldHideTutorial) {
        [tutorials hideTutorial];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (touchShouldHideTutorial) {
        [tutorials hideTutorial];
    }
}

- (void)showTutorialTwo
{
    int total = (int) (self.notebook.getBehaviorsCheckinTime.count * (self.notebook.getBehaviorsToChange.count + self.notebook.getBehaviorsToDoInstead.count + self.notebook.getBehaviorsToKeep.count));
    [tutorials showCustomTutorialOnControl:self.RewardLbl withText:[NSString stringWithFormat:@"With the number of behaviors and check-in times you've entered, your child can earn up to %d tokens per day or %d tokens per week.", total, total*7] nView:self.contentView withOrientation:POINTING_NONE withCallback:@selector(showTutorialThree) fromSender:self];
}

- (void)showTutorialThree
{
    [tutorials showTutorialAtX:230 atY:105  withID:TUT_REWARD_PRICES_2 inView:self.contentView withOrientation:POINTING_UP withCallback:NULL fromSender:self];
    touchShouldHideTutorial = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
