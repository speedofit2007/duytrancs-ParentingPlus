//
//  ThingsToDoInsteadViewController.h
//  Parenting+
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface ThingsToDoInsteadViewController : UIViewController

// UI components
@property (weak, nonatomic) IBOutlet UILabel *doInstead1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *doInstead2Lbl;
@property (weak, nonatomic) IBOutlet UITextField *behavior1Txt;
@property (weak, nonatomic) IBOutlet UITextField *behavior2Txt;
@property (weak, nonatomic) IBOutlet UITextField *behavior3Txt;
@property (weak, nonatomic) IBOutlet UITextField *behavior4Txt;
@property (weak, nonatomic) IBOutlet UIButton *saveAndContinue;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

// segue variables
@property (strong, nonatomic) NSString *behaviorToChange1;
@property (strong, nonatomic) NSString *behaviorToChange2;
@property (strong, nonatomic) NoteBooks *notebook;

//scroll view
@property (strong, nonatomic) IBOutlet UIScrollView *nbScrollView;
//content view embedded into scrollview
@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)saveAndContinueClick:(id)sender;
- (void) keyboardHide;

- (IBAction)closeButton:(id)sender;

-(IBAction)keyboardAdapter: (UITextField*)textfieldName;

- (IBAction)infoClick:(id)sender;

@end
