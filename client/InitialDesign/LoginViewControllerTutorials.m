//
//  LoginViewControllerTutorials.m
//  Parenting+s
//
//  Created by David Wiza on 12/22/13.
//  Copyright (c) 2013  Capstone Team B. All rights reserved.
//

#import "LoginViewControllerTutorials.h"
#import "Tutorials.h"

extern Tutorials *tutorials;

@interface LoginViewControllerTutorials ()

@end

@implementation LoginViewControllerTutorials

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
    [tutorials showTutorialOnControl:self.signupBtn withID:TUT_FIRST_TIME inView:self.view withOrientation:POINTING_DOWN withCallback:NULL fromSender:self];
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
