//
//  signUpViewController.m
//  Parenting+
//
//  Created by TC on 12/1/13.
//  Copyright (c) 2013 Capstone Team B. All rights reserved.
//

#import "signUpViewController.h"
#import "LocalDatabase.h"
#import "LoginViewController.h"
#import "Net.h"

@interface signUpViewController ()

@end

@implementation signUpViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg_sky_grass.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
     _createButton.backgroundColor = [UIColor orangeColor];
    [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     */
    // Make the password fields be masked.
    _passwordText.secureTextEntry = YES;
    _confirmPasswordText.secureTextEntry = YES;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (IBAction)termsOfAgreement:(id)sender {
    
}

- (IBAction)createButton:(id)sender {
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// makes the screen raise up so that none of the text fields are blocked by the keyboard
-(IBAction)keyboardApdaper: (UITextField*)textfieldName
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.35];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [textfieldName isFirstResponder])
    {
        [self.view setFrame:CGRectMake(0,(-(textfieldName.frame.origin.y) + 150),320,718)];
        [UIView commitAnimations];
    }
    if ([[UIScreen mainScreen] bounds].size.height <= 480 && [textfieldName isFirstResponder])
    {
        [self.view setFrame:CGRectMake(0,(-(textfieldName.frame.origin.y) + 100),320,580)];
        [UIView commitAnimations];
    }
}

// makes the screen return to its normal position after the keyboard has retracted
- (void)keyboardDidHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        [self.view setFrame:CGRectMake(0,0,320,568)];
        [UIView commitAnimations];
    }
    else {
        [self.view setFrame:CGRectMake(0,0,320,480)];
        [UIView commitAnimations];
    }
}

// hides keyboard after hitting next
-(BOOL)textFieldReturn:(id)sender
{
    // Does the first textfield have the focus? If yes, go to the next one
    if ([_firstName isFirstResponder])
    {
        [_lastName becomeFirstResponder];
        return YES;
    }
    if ([_lastName isFirstResponder])
    {
        [_emailText becomeFirstResponder];
        return YES;
    }
    if ([_emailText isFirstResponder])
    {
        [_passwordText becomeFirstResponder];
        return YES;
    }
    if ([_passwordText isFirstResponder])
    {
        [_confirmPasswordText becomeFirstResponder];
        return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_confirmPasswordText resignFirstResponder];
        NSLog(@"last textfield done");
    }
        return NO;
}


// hide the keyboard when user taps outside of keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([_firstName isFirstResponder] && [touch view] != _firstName) {
        [_firstName resignFirstResponder];
    }
    if ([_lastName isFirstResponder] && [touch view] != _lastName) {
        [_lastName resignFirstResponder];
    }
    if ([_emailText isFirstResponder] && [touch view] != _emailText) {
        [_emailText resignFirstResponder];
    }
    if ([_passwordText isFirstResponder] && [touch view] != _passwordText) {
        [_passwordText resignFirstResponder];
    }
    if ([_confirmPasswordText isFirstResponder] && [touch view] != _confirmPasswordText) {
        [_confirmPasswordText resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createClk:(id)sender {
    // Assume all are good, and reset to no border by default.
    _firstName.layer.borderWidth = 0.0f;
    _lastName.layer.borderWidth = 0.0f;
    _emailText.layer.borderWidth = 0.0f;
    _passwordText.layer.borderWidth = 0.0f;
    _confirmPasswordText.layer.borderWidth = 0.0f;
    BOOL foundError = NO;
    BOOL alertBoxShowed = NO;
    
    /* Upon clicking Create, make all
     * fields appear with a red border if the
     * fields are incorrectly entered.
     */
    if (_firstName.text.length < 1)
    {
        _firstName.layer.borderColor=[[UIColor redColor]CGColor];
        _firstName.layer.borderWidth = 1.0f;
        foundError = YES;
    }
    if (_lastName.text.length < 1)
    {
        _lastName.layer.borderColor=[[UIColor redColor]CGColor];
        _lastName.layer.borderWidth = 1.0f;
        foundError = YES;
    }
    
    // Something along the lines of: [A-Za-z0-9]+@[A-Za-z].[A-Za-z]{3}
    if (_emailText.text.length < 1)
    {
        _emailText.layer.borderColor=[[UIColor redColor]CGColor];
        _emailText.layer.borderWidth = 1.0f;
        foundError = YES;
        // Insert alert box to alert user of invalid EMAIL address format.
    } else {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        BOOL isEmail = [emailTest evaluateWithObject:_emailText.text];
        if(!isEmail) {
            _emailText.layer.borderColor=[[UIColor redColor]CGColor];
            _emailText.layer.borderWidth = 1.0f;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            foundError = YES;
            alertBoxShowed = YES;
        }
    }
    
    // Enforce that passwords are at least 6 characters long
    if (_passwordText.text.length < 6 || _passwordText.text.length > 50)
    {
        _passwordText.layer.borderColor=[[UIColor redColor]CGColor];
        _passwordText.layer.borderWidth = 1.0f;
        foundError = YES;
        if (!alertBoxShowed) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your password must be at least 6 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alertBoxShowed = YES;
        }
    }
    if ([_confirmPasswordText.text isEqualToString:_passwordText.text] == NO)
    {
        if (!alertBoxShowed) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Passwords do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alertBoxShowed = YES;
        }
        _confirmPasswordText.layer.borderColor=[[UIColor redColor]CGColor];
        _confirmPasswordText.layer.borderWidth = 1.0f;
        _passwordText.layer.borderColor=[[UIColor redColor]CGColor];
        _passwordText.layer.borderWidth = 1.0f;
        foundError = YES;
    }
    
    // Insert user data into database
    LocalDatabase *ldb = [[LocalDatabase alloc] init];
    Net * sharedNet = [Net sharedNet];
    if ([sharedNet hasConnection] == FALSE) {
        NSLog(@"Failed to sign-up. No internet connection!!!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please be connected to the internet to sign up for an account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else if(!foundError) {
        [ldb signUpNewUser:_firstName.text andLastName:_lastName.text andEmail:_emailText.text andPassword:_passwordText.text andCallback:^(BOOL success, NSArray* errors) {
            if (success) {
                NSLog(@"UI: Apparently signup was good");
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"UI: Signup was bad");
                // TODO : Display the errors somehow
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, it looks like the email address already belongs to an existing account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

@end
