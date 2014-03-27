//
//  RulesAndRemindersViewController.h
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface RulesAndRemindersViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *rule1Txt;
@property (weak, nonatomic) IBOutlet UITextField *rule2Txt;
@property (weak, nonatomic) IBOutlet UIButton *saveAndContinue;
@property (strong, nonatomic) IBOutlet UILabel *reminderLbl1;
@property (strong, nonatomic) IBOutlet UILabel *reminderLbl2;

@property (strong, nonatomic) NSString *behaviorToChange1;
@property (strong, nonatomic) NSString *behaviorToChange2;
@property (strong, nonatomic) NoteBooks *notebook;
@property (strong, nonatomic) IBOutlet UIScrollView *nbScrollView;

@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)saveAndContinueClick:(id)sender;
- (IBAction)closeButton:(id)sender;
- (IBAction)infoClick:(id)sender;
- (void)keyboardDidHide:(NSNotification *)notification;
- (void) keyboardHide;

@end
