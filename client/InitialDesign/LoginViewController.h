//
//  ViewController.h
//  Parenting+
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

// Text field references
@property (weak, nonatomic) IBOutlet UITextField *usernameTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;

// Button references
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signupBtn;

// Button click actions
- (IBAction)loginClk:(id)sender;
- (IBAction)signupClk:(id)sender;
-(IBAction)textFieldReturn:(id)sender;

-(IBAction)keyboardApdaper: (UITextField*)textfieldName;

@end
