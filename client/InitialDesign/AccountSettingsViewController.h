//
//  AccountSettingsViewController.h
//  Parenting+
//
//  Created by Sean Walsh on 1/7/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalDatabase.h"
#import "Tutorials.h"

extern Tutorials *tutorials;

@interface AccountSettingsViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetTutorialsBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutBtn;
- (IBAction)logoutClk:(id)sender;

- (IBAction)updateClick:(id)sender;
- (IBAction)resetTutorialsClick:(id)sender;
- (BOOL)textFieldReturn:(id)sender;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@property (strong, nonatomic) IBOutlet UITextField *firstNameTxt;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTxt;
@property (strong, nonatomic) IBOutlet UITextField *emailTxt;
@property (strong, nonatomic) IBOutlet UITextField *currentPassword;
@property (strong, nonatomic) IBOutlet UITextField *resetPasswordTxt;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTxt;


@end
