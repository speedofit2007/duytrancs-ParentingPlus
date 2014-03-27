//
//  RulesAndRemindersViewControllerTutorials.m
//  Parenting+
//
//  Created by David Wiza on 1/25/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "RulesAndRemindersViewControllerTutorials.h"

@interface RulesAndRemindersViewControllerTutorials ()

@end

@implementation RulesAndRemindersViewControllerTutorials

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
    [tutorials showTutorialOnControl:self.rule1Txt withID:TUT_RULES_AND_REMINDERS inView:self.contentView withOrientation:POINTING_UP withCallback:NULL fromSender:self];
}

- (void) keyboardHide
{
    [super keyboardHide];
    [tutorials hideTutorial];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
	[tutorials hideTutorial];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
