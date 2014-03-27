//
//  DashboardViewControllerTutorials.m
//  Parenting+
//
//  Created by David Wiza on 1/18/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "DashboardViewControllerTutorials.h"
#import "Tutorials.h"
#import "LocalDatabase.h"

extern Tutorials *tutorials;

@interface DashboardViewControllerTutorials ()

@end

@implementation DashboardViewControllerTutorials

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    if ([function getNotebooks].count == 0) {
        [tutorials showTutorialAtX:305 atY:0 withID:TUT_NEED_TO_CREATE_NOTEBOOK inView:self.view withOrientation:POINTING_UP withCallback:NULL fromSender:self];
    } else {
        [tutorials showTutorialAtX:160 atY:50 withID:TUT_EDIT_NOTEBOOK inView:self.view withOrientation:POINTING_UP withCallback:NULL fromSender:self];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.dashboardTableView addGestureRecognizer:tap];
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.dashboardTableView];
    NSIndexPath *indexPath = [self.dashboardTableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath) { //we are in a tableview cell, let the gesture be handled by the view
        recognizer.cancelsTouchesInView = NO;
    } else { // anywhere else, do what is needed for your case
        [tutorials hideTutorial];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
