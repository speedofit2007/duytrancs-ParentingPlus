//
//  NotebookViewController.h
//  Parenting+s
//
//  Created by Sean Walsh on 1/6/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface NotebookViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *notebookSettingsItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *InfoItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *rewardsItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *behaviorsItem;

@property (strong, nonatomic) NoteBooks *notebook;

@end
