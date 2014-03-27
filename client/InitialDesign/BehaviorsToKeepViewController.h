//
//  BehaviorsToKeepViewController.h
//  Parenting+
//


#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface BehaviorsToKeepViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *behavior1Txt;
@property (weak, nonatomic) IBOutlet UITextField *behavior2Txt;
@property (weak, nonatomic) IBOutlet UITextField *behavior3Txt;
@property (weak, nonatomic) IBOutlet UIButton *saveAndContinue;
@property (strong, nonatomic) NoteBooks *notebook;
- (IBAction)saveAndContinueClick:(id)sender;
- (IBAction) textfieldChecker: (id)sender;
- (IBAction)keyboardAdapter: (UITextField*)textfieldName;

// Scrollview and Content View
@property (strong, nonatomic) IBOutlet UIScrollView *nbScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;


//labels
@property (strong, nonatomic) IBOutlet UILabel *behaviorsToKeepLabel01;
@property (strong, nonatomic) IBOutlet UILabel *behaviorsToKeepLabel02;
@property (strong, nonatomic) IBOutlet UILabel *behaviorsToKeepLabel03;
- (IBAction)closeButton:(id)sender;

// info button
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
- (IBAction)infoClick:(id)sender;

- (void) keyboardHide;

@end
