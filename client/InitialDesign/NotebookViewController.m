//
//  NotebookViewController.m
//  Parenting+
//
//  Created by Sean Walsh on 1/6/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "NotebookViewController.h"
#import "NoteBooks.h"

@interface NotebookViewController ()

@end

@implementation NotebookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The selector for what to do when a tabBarItem is selected.
- (void)tabClicked:(long)index {
    switch (index) {
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
        default:
            break;
    }
}

// Called automatically when a tabBarItem is selected.
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)tabItem {
    NSLog(@"didSelectItem: %ld", (long)tabItem.tag);
    [self tabClicked:tabItem.tag];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // If we need a DB
    // LocalDatabase *ldb = [[LocalDatabase alloc] init];
    if ([identifier isEqualToString:@"BehaviorListSegue"])    
        return YES;
    if ([identifier isEqualToString:@"notebookSettingsSegue"])
        return YES;
    if ([identifier isEqualToString:@"infoViewSegue"])
        return YES;
    if ([identifier isEqualToString:@"rewardsSegue"])
        return YES;
    // Default case: YES (arbitrary)*/
    return YES;
}

@end
