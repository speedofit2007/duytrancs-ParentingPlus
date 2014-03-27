//
//  ViewController.m
//  Parenting+
//

#import "LoginViewController.h"
#import "LocalDatabase.h"
#import "DashboardViewController.h"
//#import "Net.h"
//#import "NoteBooks.h"
//#import "OutlineDBFunction.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
// Create new Local DB


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Make sure back button does not show up...
    [self.navigationItem setHidesBackButton:YES];
    /*[[self navigationController] setNavigationBarHidden:YES animated:NO];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg_sky_grass.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [_signupBtn setBackgroundColor:[UIColor orangeColor]];
    [_signupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    */
    // Mask password text box.
    _passwordTxt.secureTextEntry = YES;
    
    // create local database
    // then replace original LocalDB.db with dummy LocalDB.db
    // email:   duy@pdx.edu
    // pass:    12345
    //BOOL success;
    //NSString *temp_id;
    
    //OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    //NoteBooks *mybook = [[NoteBooks alloc]init];
    
    //[ldb setCurrentUser:@"1"];
    //[ldb setCurrentNotebook:@"1"];
    
    //NSDate *date = [mybook getNotebookCreateDate];
  
    if ([[UIScreen mainScreen] bounds].size.height == 480) // for relocate login and sigup with 3.5in screen iphone
    {
        
        [self.usernameTxt setTranslatesAutoresizingMaskIntoConstraints:YES];
        [self.passwordTxt setTranslatesAutoresizingMaskIntoConstraints:YES];
        [self.loginBtn setTranslatesAutoresizingMaskIntoConstraints:YES];
        [self.signupBtn setTranslatesAutoresizingMaskIntoConstraints:YES];
        //[self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        //[self.view setFrame:CGRectMake(0,-25,320,480)];
        [self.usernameTxt setFrame:CGRectMake(50,120,225,30)];
        [self.passwordTxt setFrame:CGRectMake(50,160,225,30)];
        [self.loginBtn setFrame:CGRectMake(50,220,225,30)];
        [self.signupBtn setFrame:CGRectMake(100,400,140,30)];
        
    }

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // auto login called can put anywhere UI team think it works
    LocalDatabase *ldb = [[LocalDatabase alloc]init];
    // @"loginSuccessfulSegue"
    [ldb autoLoginandCallback:^(BOOL success) {
        if (success) {
            [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:self];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
-(IBAction)textFieldReturn:(id)sender
{
    // Does the first textfield have the focus? If yes, go to the next one
    if ([_usernameTxt isFirstResponder])
    {
        [_passwordTxt becomeFirstResponder];
 //       return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_passwordTxt resignFirstResponder];
        NSLog(@"third textfield done");
    }
//    return NO;
}

// hide the keyboard when user taps outside of keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([_usernameTxt isFirstResponder] && [touch view] != _usernameTxt) {
        [_usernameTxt resignFirstResponder];
    }
    if ([_passwordTxt isFirstResponder] && [touch view] != _passwordTxt) {
        [_passwordTxt resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

- (IBAction)loginClk:(id)sender {
    LocalDatabase * ldb = [[LocalDatabase alloc] init];
    if (_usernameTxt.text.length > 0 && _passwordTxt.text.length > 0) {
        [ldb checkLogin:[_usernameTxt text] andPassword:[_passwordTxt text] andCallback:^(BOOL success, NSString * error) {
            if (success) {
                NSLog(@"LoginController: Successful login");
                [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:self]; //Successful login, do segue
            } else {
                if ([error isEqualToString:@"Invalid email or password."]) { // Check for bad credential error
                    _usernameTxt.layer.borderColor = [[UIColor redColor]CGColor];
                    _usernameTxt.layer.borderWidth = 1.0f;
                    _passwordTxt.layer.borderColor = [[UIColor redColor]CGColor];
                    _passwordTxt.layer.borderWidth = 1.0f;
                } else if ([error isEqualToString:@"Connection error."]) { // Check for bad connection error
                    // TODO : Do something here
                }
            }
        }];
    } else { // Empty username or password field
        /* Clear the borders by default, and only light up if there is:
         * A) An empty field
         * B) An invalid field
         * "B)" needs implemented by backend for Checking and the result
         * of the function provided will determine whether or not to change
         * border color.
         */
        _usernameTxt.layer.borderColor = [[UIColor clearColor]CGColor];
        _passwordTxt.layer.borderColor = [[UIColor clearColor]CGColor];
        // If the username textbox is empty, highlight it.
        if (_usernameTxt.text.length == 0)
        {
            _usernameTxt.layer.borderColor = [[UIColor redColor]CGColor];
            _usernameTxt.layer.borderWidth = 1.0f;
        }
        // If the password text box is empty, highlight it.
        if (_passwordTxt.text.length == 0)
        {
            _passwordTxt.layer.borderColor = [[UIColor redColor]CGColor];
            _passwordTxt.layer.borderWidth = 1.0f;
        }
    }
}

- (IBAction)signupClk:(id)sender {
    [self performSegueWithIdentifier:@"signupSegue" sender:self];
}
@end
