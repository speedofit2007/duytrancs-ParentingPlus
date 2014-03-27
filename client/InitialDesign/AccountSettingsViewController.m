//
//  AccountSettingsViewController.m
//  Parenting+
//
//  Created by Sean Walsh on 1/7/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "AccountSettingsViewController.h"

NSMutableDictionary *myDic;

@interface AccountSettingsViewController ()

@end

@implementation AccountSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];

    // Mask the password fields
    _currentPassword.secureTextEntry = YES;
    _resetPasswordTxt.secureTextEntry = YES;
    _confirmPasswordTxt.secureTextEntry = YES;
    
    // Example to use function updateUserWithEmail
    //LocalDatabase *ldb = [[LocalDatabase alloc] init];
    //[ldb setDatabasePath];        // This mean set the default database path to our localDB
    //[ldb setCurrentUser:@"1"];    // this will depend on what current user we are working with, in this example will be id = 1
                                    // we also can set currentuser for any other user
    //[ldb updateUsersWithEmail:@"azadi@pdx.edu" andPassword:@"54321"];     // this is how to use function update
    // besides you guys can go ahead and update user, no need to send me anything, just use the function properly
    
    // creating local db
    LocalDatabase *ldb = [[LocalDatabase alloc] init];
    myDic = [ldb getUserInformation];
    // get users first name
     _firstNameTxt.text = myDic[@"first_name"];
    //get users last name
     _lastNameTxt.text = myDic[@"last_name"];
    // get users email
    _emailTxt.text = myDic[@"email"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"backToDashboardSegue"])
        return YES;
    
     // Default case: YES (arbitrary)
    return YES;
}

// hides keyboard after hitting next
-(BOOL) textFieldReturn:(id)sender
{
    // Does the first textfield have the focus? If yes, go to the next one
    if ([_firstNameTxt isFirstResponder])
    {
        [_lastNameTxt becomeFirstResponder];
       return YES;
    }
    if ([_lastNameTxt isFirstResponder])
    {
        [_emailTxt becomeFirstResponder];
       return YES;
    }
    if ([_emailTxt isFirstResponder])
    {
        [_currentPassword becomeFirstResponder];
       return YES;
    }
    if ([_currentPassword isFirstResponder])
    {
        [_resetPasswordTxt becomeFirstResponder];
       return YES;
    }
    if ([_resetPasswordTxt isFirstResponder])
    {
        [_confirmPasswordTxt becomeFirstResponder];
       return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_confirmPasswordTxt resignFirstResponder];
        NSLog(@"All textfields done");
    }
    return NO;
}

// hide the keyboard when user taps outside of keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([_firstNameTxt isFirstResponder] && [touch view] != _firstNameTxt) {
        [_firstNameTxt resignFirstResponder];
    }
    if ([_lastNameTxt isFirstResponder] && [touch view] != _lastNameTxt ) {
        [_lastNameTxt  resignFirstResponder];
    }
    if ([_emailTxt isFirstResponder] && [touch view] != _emailTxt) {
        [_emailTxt resignFirstResponder];
    }
    if ([_currentPassword isFirstResponder] && [touch view] != _currentPassword ) {
        [_currentPassword  resignFirstResponder];
    }
    if ([_resetPasswordTxt isFirstResponder] && [touch view] != _resetPasswordTxt ) {
        [_resetPasswordTxt resignFirstResponder];
    }
    if ([_confirmPasswordTxt isFirstResponder] && [touch view] != _confirmPasswordTxt ) {
        [_confirmPasswordTxt resignFirstResponder];
    }

    [super touchesBegan:touches withEvent:event];
}

- (IBAction)resetTutorialsClick:(id)sender {
    [tutorials reset];
}

- (IBAction)logoutClk:(id)sender {
    NSLog(@"LOGOUT CLICK");
    LocalDatabase *ldb = [[LocalDatabase alloc] init];
    [ldb Logout];
    //[self performSegueWithIdentifier:@"logoutSegue" sender:self];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateClick:(id)sender {
    
    _emailTxt.layer.borderWidth = 0.0f;
    _firstNameTxt.layer.borderWidth = 0.0f;
    _lastNameTxt.layer.borderWidth = 0.0f;
    _currentPassword.layer.borderWidth = 0.0f;
    _resetPasswordTxt.layer.borderWidth = 0.0f;
    _confirmPasswordTxt.layer.borderWidth = 0.0f;
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Password Missmatch"
                          message: @"Please reenter your passwords."
                          delegate: nil
                          cancelButtonTitle: @"Ok, stop bothering me"
                          otherButtonTitles: nil];
    
    LocalDatabase *ldb = [[LocalDatabase alloc] init];
    BOOL success = FALSE;
    
    if ([myDic[@"first_name"] isEqualToString:_firstNameTxt.text] == FALSE ||
        [myDic[@"last_name"] isEqualToString:_lastNameTxt.text] == FALSE ||
        [myDic[@"email"] isEqualToString:_emailTxt.text] == FALSE ) {
        success = [ldb updateFirstLastEmail:_firstNameTxt.text andLast:_lastNameTxt.text andEmail:_emailTxt.text];
    }
    if ([myDic[@"password"] isEqualToString: _currentPassword.text] == TRUE)
    {
        if([_resetPasswordTxt.text isEqualToString: _confirmPasswordTxt.text] == TRUE)
        {
            success = [ldb updatePasswordToNew:_confirmPasswordTxt.text];
            //[ self shouldPerformSegueWithIdentifier: @"backToDashboardSegue" sender:self ];
        }
        else{
            _resetPasswordTxt.layer.borderColor=[[UIColor redColor]CGColor];
            _resetPasswordTxt.layer.borderWidth = 1.0f;
            _confirmPasswordTxt.layer.borderColor=[[UIColor redColor]CGColor];
            _confirmPasswordTxt.layer.borderWidth = 1.0f;
            [alert show];
        }
    }
    if ([myDic[@"password"] isEqualToString: _currentPassword.text] == FALSE)
    {
        _currentPassword.layer.borderColor=[[UIColor redColor]CGColor];
        _currentPassword.layer.borderWidth = 1.0f;
        [alert show];
    }
    if (_emailTxt.text.length < 1)
         {
            _emailTxt.layer.borderColor=[[UIColor redColor]CGColor];
            _emailTxt.layer.borderWidth = 1.0f;

         }
    if (_firstNameTxt.text.length < 1)
        {
            _firstNameTxt.layer.borderColor=[[UIColor redColor]CGColor];
            _firstNameTxt.layer.borderWidth = 1.0f;
        }
    if (_lastNameTxt.text.length < 1)
        {
            _lastNameTxt.layer.borderColor=[[UIColor redColor]CGColor];
            _lastNameTxt.layer.borderWidth = 1.0f;
        }
    [self dismissViewControllerAnimated:YES completion:nil];

    }
 

    // check _currentPassword is equal to myDic[@"password""] or not?
    // YES --> check new password is same as confirmpass
    // YES --> call     success = [ldb updatePasswordToNew:_confirmPasswordTxt];
    

@end
