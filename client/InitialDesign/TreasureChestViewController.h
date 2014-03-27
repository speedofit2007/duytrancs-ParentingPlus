//
//  TreasureChestViewController.h
//  Parenting+
//
//  Created by Sean Walsh on 1/7/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreasureChestViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *TChestTableView;
- (IBAction)goBackToNotebooksBtn:(id)sender;
@end
