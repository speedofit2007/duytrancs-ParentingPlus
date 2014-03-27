//
//  ObserveAndRewardViewController.h
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface ObserveAndRewardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *time1Txt;
@property (weak, nonatomic) IBOutlet UITextField *time2Txt;
@property (weak, nonatomic) IBOutlet UITextField *time3Txt;
@property (weak, nonatomic) IBOutlet UITextField *time4Txt;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel02;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel03;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel04;
@property (strong, nonatomic) NoteBooks *notebook;
@property (weak, nonatomic) IBOutlet UIButton *saveAndContinue;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
//scroll view
@property (strong, nonatomic) IBOutlet UIScrollView *nbScrollView;
//content view embedded in scroll
@property (strong, nonatomic) IBOutlet UIView *contentView;

-(IBAction)keyboardAdapter: (UITextField*)textfieldName;
- (IBAction)saveAndContinueClick:(id)sender;
- (IBAction)closeButton:(id)sender;

- (IBAction)infoClick:(id)sender;
- (void) keyboardHide;

@end
