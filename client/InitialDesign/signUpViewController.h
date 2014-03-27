//
//  signUpViewController.h
//  Parenting+
//
//  Created by TC on 12/1/13.
//  Copyright (c) 2013 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface signUpViewController : UIViewController
- (IBAction)createClk:(id)sender;

// TextField References
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordText;
-(BOOL)textFieldReturn:(id)sender;

// Switch references
@property (weak, nonatomic) IBOutlet UISwitch *termsOfAgreement;

// Switch actions
- (IBAction)termsOfAgreement:(id)sender;

// Button references
@property (weak, nonatomic) IBOutlet UIButton *createButton;

// Button click actions
- (IBAction)createButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
-(IBAction)keyboardApdaper: (UITextField*)textfieldName;
@end
