//
//  BehaviorsToChangeViewController.h
//  Parenting+
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface BehaviorsToChangeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *behavior1Txt;
@property (weak, nonatomic) IBOutlet UITextField *behavior2Txt;
@property (weak, nonatomic) IBOutlet UIButton *saveAndContinue;
@property (strong, nonatomic) IBOutlet UILabel *behaviorLabel02;
@property (strong, nonatomic) NoteBooks *notebook;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

//scroll view
@property (strong, nonatomic) IBOutlet UIScrollView *nbScrollview;

//content view inside scrollview
@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)saveAndContinueClick:(id)sender;

- (IBAction)closeButton:(id)sender;

-(IBAction)keyboardAdapter: (UITextField*)textfieldName;

- (IBAction)infoClick:(id)sender;

- (void) keyboardHide;

@end
