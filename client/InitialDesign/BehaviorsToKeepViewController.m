//
//  BehaviorsToKeepViewController.m
//  Parenting+
//

#import "BehaviorsToKeepViewController.h"
#import "BehaviorsToChangeViewController.h"
#import "InfoViewController.h"

@interface BehaviorsToKeepViewController () {
    NSString *oldBehaviorToKeep1;
    NSString *oldBehaviorToKeep2;
    NSString *oldBehaviorToKeep3;
    NSMutableArray *oldKeepBHArray;
    NSMutableArray *newKeepBHArray;
}

@end

@implementation BehaviorsToKeepViewController

BOOL hasSavedBehaviorsToKeep = NO;

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.nbScrollView layoutIfNeeded];
    self.nbScrollView.contentSize = self.contentView.bounds.size;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) fadeTextIn: (UITextField *)textFieldName withLabel:(UILabel *)labelName
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    [textFieldName setAlpha:1];
    [labelName setAlpha:1];
    [UIView commitAnimations];
}

-(void) fadeTextOut: (UITextField *)textFieldName withLabel:(UILabel *)labelName
{
    [UITextField beginAnimations:nil context:NULL];
    [UITextField setAnimationDuration: .5];
    [textFieldName setAlpha:0];
    [labelName setAlpha:0];
    [UITextField commitAnimations];
}

- (IBAction) textfieldChecker: (id)sender
{
    
    if (_behavior2Txt.text.length == 0)
    {
        [self fadeTextIn:_behavior2Txt withLabel:_behaviorsToKeepLabel02];
    }
    if (_behavior3Txt.text.length == 0 && [_behavior2Txt isFirstResponder])
    {
        [self fadeTextIn:_behavior3Txt withLabel:_behaviorsToKeepLabel03];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    if ([[_notebook getBehaviorsToKeep] count] > 0) {
        [self LoadCurrentBehaviorToKeep];
        hasSavedBehaviorsToKeep = YES;
    }
    
    if (_behavior2Txt.text.length == 0)
    {
        [_behaviorsToKeepLabel02 setAlpha:0];
        [_behavior2Txt setAlpha:0];
    }
    if (_behavior3Txt.text.length == 0)
    {
        [_behaviorsToKeepLabel03 setAlpha:0];
        [_behavior3Txt setAlpha:0];
    }
    
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(keyboardHide)];
    tapScroll.cancelsTouchesInView = NO;
    [_nbScrollView addGestureRecognizer: tapScroll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //[_infoButton addTarget:self action:@selector(tappedInfoButton:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)tappedInfoButton:(id)sender forEvent:(UIEvent *)event
 {
 NSMutableArray *examples = [[NSMutableArray alloc] initWithObjects:@"Behavior 1",@"Behavior 2", nil];
 NSString *exampleMsg = [[NSString alloc] init];
 for (NSString *example in examples) {
 exampleMsg = [NSString stringWithFormat:@"%@\n%@", exampleMsg, example];
 }
 
 // confirm if user wants to redeem a reward
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Examples:" message:exampleMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [alert show];
 }*/

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"saveBehaviorsToKeepGoToBehaviorsToChangeSegue"])
    {
        // Clear the borders in case there are no errors.
        _behavior1Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        _behavior2Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        _behavior3Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        
        if (_behavior1Txt.text.length > 0)
        {
            return YES;
        }
        else
        {
            // Set borders on the offending controls that need rectified.
            if (_behavior1Txt.text.length == 0)
            {
                _behavior1Txt.layer.borderColor = [[UIColor redColor]CGColor];
                _behavior1Txt.layer.borderWidth = 1.0f;
            }
            return NO;
        }
    }
    return NO;
}

-(IBAction)keyboardAdapter: (UITextField*)textfieldName
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [textfieldName isFirstResponder])
    {
        [_nbScrollView setContentOffset:CGPointMake(0, 50) animated: YES];
        [UIView commitAnimations];
    }
    if ([[UIScreen mainScreen] bounds].size.height <= 480 && [textfieldName isFirstResponder])
    {
        // enter code for iphone 3.5 in
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

        [_nbScrollView setContentOffset:CGPointMake(0, 0) animated: YES];
        [UIView commitAnimations];
    }
    else {
         // enter code for iphone 3.5 in
        [UIView commitAnimations];
    }
    
}

// Have the focus go to the next textfield after a user ends editing
- (BOOL)textFieldReturnNext:(id)sender
{
    // Does the first textfield have the focus? If yes, go to the next one
    if ([_behavior1Txt isFirstResponder])
    {
        [_behavior2Txt becomeFirstResponder];
        return YES;
    }
    if ([_behavior2Txt isFirstResponder])
    {
        [self fadeTextIn:_behavior3Txt withLabel:_behaviorsToKeepLabel03];
        [_behavior3Txt becomeFirstResponder];
        return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_behavior3Txt resignFirstResponder];
        NSLog(@"third textfield done");
    }
    return NO;
}

// hide the keyboard when user taps outside of keyboard
- (void) keyboardHide
{
    [self.view endEditing:YES];
}

// Load the values from the DB to be displayed upon reviewing a notebook.
- (void)LoadCurrentBehaviorToKeep
{
    NSMutableArray *KeepBHList = [[NSMutableArray alloc] init];
    oldKeepBHArray = [[NSMutableArray alloc] init];
    OutlineDBFunction *function = [[OutlineDBFunction alloc]init];
    KeepBHList = [function getGoodBehaviorsLastest];
    _behavior2Txt.text = _behavior3Txt.text = @"";
    if ([KeepBHList[0][@"bhname"] length] > 0) {
        _behavior1Txt.text = KeepBHList[0][@"bhname"];
    }
    if ([KeepBHList count] > 1) {
        _behavior2Txt.text = KeepBHList[1][@"bhname"];
    }
    if ([KeepBHList count] > 2) {
        _behavior3Txt.text = KeepBHList[2][@"bhname"];
    }
    [oldKeepBHArray addObject:_behavior1Txt.text];
    [oldKeepBHArray addObject:_behavior2Txt.text];
    [oldKeepBHArray addObject:_behavior3Txt.text];
}

- (IBAction)saveAndContinueClick:(id)sender {
    newKeepBHArray = [[NSMutableArray alloc]init];
    [newKeepBHArray addObject:_behavior1Txt.text];
    [newKeepBHArray addObject:_behavior2Txt.text];
    [newKeepBHArray addObject:_behavior3Txt.text];
    
    if (hasSavedBehaviorsToKeep == NO)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
        [dict1 setObject:_behavior1Txt.text forKey:@"bhname"];
        [array addObject:dict1];
        
        if (_behavior2Txt.text.length != 0) {
            NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
            [dict2 setObject:_behavior2Txt.text forKey:@"bhname"];
            [array addObject:dict2];
        }
        
        if (_behavior3Txt.text.length != 0) {
            NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] init];
            [dict3 setObject:_behavior3Txt.text forKey:@"bhname"];
            [array addObject:dict3];
        }
        
        // save behaviors to keep into database
        _notebook = [_notebook setBehaviorsToKeepFromNotebook:_notebook withGoodBehavior:array];
        hasSavedBehaviorsToKeep = YES;
    }
    
    else {
        /*if ([oldBehaviorToKeep1 isEqualToString:_behavior1Txt.text] == FALSE && ([oldBehaviorToKeep1 length] != 0 || [_behavior1Txt.text length] != 0)) {
         _notebook = [_notebook updateGoodBehaviorWithOldName:oldBehaviorToKeep1 toNewName:_behavior1Txt.text fromNotebook:_notebook];
         } if ([oldBehaviorToKeep2 isEqualToString:_behavior2Txt.text] == FALSE && ([oldBehaviorToKeep2 length] != 0 || [_behavior2Txt.text length] != 0)) {
         _notebook = [_notebook updateGoodBehaviorWithOldName:oldBehaviorToKeep2 toNewName:_behavior2Txt.text fromNotebook:_notebook];
         } if ([oldBehaviorToKeep3 isEqualToString:_behavior3Txt.text] == FALSE && ([oldBehaviorToKeep3 length] != 0 || [_behavior3Txt.text length] != 0)) {
         _notebook = [_notebook updateGoodBehaviorWithOldName:oldBehaviorToKeep3 toNewName:_behavior3Txt.text fromNotebook:_notebook];
         }*/
        if ([_notebook isTextViewChange:oldKeepBHArray compareTo:newKeepBHArray]) {
            [_notebook updateGoodBehaviorWithOldArray:oldKeepBHArray toNewArray:newKeepBHArray fromNotebook:_notebook];
        }
    }
    
    oldKeepBHArray = [[NSMutableArray alloc]init];
    [oldKeepBHArray addObject:_behavior1Txt.text];
    [oldKeepBHArray addObject:_behavior2Txt.text];
    [oldKeepBHArray addObject:_behavior3Txt.text];
    
    [self shouldPerformSegueWithIdentifier:@"saveBehaviorsToKeepGoToBehaviorsToChangeSegue" sender:self];
}

- (IBAction)infoClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InfoViewController *controller = (InfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    controller.transition = 1;
    controller.parent = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    if ([[segue identifier] isEqualToString:@"saveBehaviorsToKeepGoToBehaviorsToChangeSegue"])
    {
        BehaviorsToChangeViewController *controller = (BehaviorsToChangeViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
    }
}

- (IBAction)closeButton:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
