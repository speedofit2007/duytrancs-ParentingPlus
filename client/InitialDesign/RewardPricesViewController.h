//
//  RewardPricesViewController.h
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface RewardPricesViewController : UIViewController

// text boxes

// buttons
@property (weak, nonatomic) IBOutlet UIButton *saveAndContinue;

// labels

@property (strong, nonatomic) IBOutlet UILabel *PriceLbl;
@property (strong, nonatomic) IBOutlet UILabel *RewardLbl;

// segue variables

@property (strong, nonatomic) NoteBooks *notebook;


@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIScrollView *nbScrollView;

- (IBAction)closeButton:(id)sender;
- (IBAction)keyboardAdapter: (UITextField*)textfieldName;
- (IBAction)createTextField;
- (IBAction)saveAndContinueClick:(id)sender;
- (void) keyboardHide;
@end

