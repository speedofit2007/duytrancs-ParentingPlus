//
//  BehaviorsToChangeViewController.m
//  Parenting+
//
// CAN'T ADD THE BOOL TO THIS CLASS WITHOUT LINKER ERROR...

#import "BehaviorsToChangeViewController.h"
#import "ThingsToDoInsteadViewController.h"
#import "InfoViewController.h"

@interface BehaviorsToChangeViewController (){
    NSString *oldBehaviorToChange1;
    NSString *oldBehaviorToChange2;
    NSMutableArray *oldBadBHArray;
}

@end

@implementation BehaviorsToChangeViewController

BOOL hasSavedBehaviorsToChange = NO;

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
    if ([_behavior1Txt isFirstResponder])
    {
        [self fadeTextIn:_behavior2Txt withLabel:_behaviorLabel02];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    if ([[_notebook getBehaviorsToChange] count] > 0) {
        [self LoadCurrentBehaviorToChange];
        hasSavedBehaviorsToChange = YES;
    }
    
    if (_behavior2Txt.text.length == 0)
    {
        [_behaviorLabel02 setAlpha:0];
        [_behavior2Txt setAlpha:0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //Gesture recogizer to hide keyboard
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(keyboardHide)];
    tapScroll.cancelsTouchesInView = NO;
    [_nbScrollview addGestureRecognizer: tapScroll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.nbScrollview layoutIfNeeded];
    self.nbScrollview.contentSize = self.contentView.bounds.size;
}

- (IBAction)infoClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InfoViewController *controller = (InfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    controller.transition = 2;
    controller.parent = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"saveBehaviorsToChangeGoToThingsToDoInsteadSegue"])
    {
        // Clear the borders in case there are no errors.
        _behavior1Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        _behavior2Txt.layer.borderColor = [[UIColor clearColor]CGColor];
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

// makes the screen raise up so that none of the text fields are blocked by the keyboard
-(IBAction)keyboardAdapter: (UITextField*)textfieldName
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [textfieldName isFirstResponder])
    {

        [_nbScrollview setContentOffset:CGPointMake(0, 50) animated: YES];
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

        [_nbScrollview setContentOffset:CGPointMake(0, 0) animated: YES];
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
        [self fadeTextIn:_behavior2Txt withLabel:_behaviorLabel02];
        [_behavior2Txt becomeFirstResponder];
        return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        
        [_behavior2Txt resignFirstResponder];
        NSLog(@"last textfield done");
    }
    return NO;
}

// hide the keyboard when user taps outside of keyboard
- (void) keyboardHide
{
    [self.view endEditing:YES];
}


// Load the values from the DB to be displayed upon reviewing a notebook.
- (void)LoadCurrentBehaviorToChange
{
    NSMutableArray *behaviorList = [[NSMutableArray alloc] init];
    oldBadBHArray = [[NSMutableArray alloc]init];
    OutlineDBFunction *function = [[ OutlineDBFunction alloc]init];
    //behaviorList = [_notebook getBehaviorsToChange];
    behaviorList = [function getBadBehaviorsLastest];
    _behavior1Txt.text = _behavior2Txt.text = @"";
    if ([behaviorList count] > 0) oldBehaviorToChange1 = _behavior1Txt.text = behaviorList[0][@"name"];
    if ([behaviorList count] > 1) oldBehaviorToChange2 = _behavior2Txt.text = behaviorList[1][@"name"];
    [oldBadBHArray addObject:_behavior1Txt.text];
    [oldBadBHArray addObject:_behavior2Txt.text];
}

- (IBAction)saveAndContinueClick:(id)sender {
    NSMutableArray *newBadBHArray = [[NSMutableArray alloc]init];
    [newBadBHArray addObject:_behavior1Txt.text];
    [newBadBHArray addObject:_behavior2Txt.text];
    
    if (hasSavedBehaviorsToChange == NO)
    {
        // this works, but we need to pass each behavior to change all the way
        // to the view controller which loads reminders
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
        [dict1 setObject:_behavior1Txt.text forKey:@"name"];
        [array addObject:dict1];
        
        if (_behavior2Txt.text.length != 0) {
            NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
            [dict2 setObject:_behavior2Txt.text forKey:@"name"];
            [array addObject:dict2];
        }
        
        // save behaviors to change into database
        _notebook = [_notebook setBehaviorsToChangeFromNotebook:_notebook withBadBehavior:array];
        hasSavedBehaviorsToChange = YES;
    }
    else
    {
        /*if ([oldBehaviorToChange1 isEqualToString:_behavior1Txt.text] == FALSE && ([oldBehaviorToChange1 length] != 0 || [_behavior1Txt.text length] != 0)) {
         _notebook = [_notebook updateBadBehaviorWithOldName:oldBehaviorToChange1 toNewName:_behavior1Txt.text fromNotebook:_notebook];
         } if ([oldBehaviorToChange2 isEqualToString:_behavior2Txt.text] == FALSE && ([oldBehaviorToChange2 length] != 0 || [_behavior2Txt.text length] != 0)) {
         _notebook = [_notebook updateBadBehaviorWithOldName:oldBehaviorToChange2 toNewName:_behavior2Txt.text fromNotebook:_notebook];
         }*/
        if ([_notebook isTextViewChange:oldBadBHArray compareTo:newBadBHArray]) {
            [_notebook updateBadBehaviorWithOldArray:oldBadBHArray toNewArray:newBadBHArray fromNotebook:_notebook];
        }
    }
    
    oldBadBHArray = [[NSMutableArray alloc]init];
    [oldBadBHArray addObject:_behavior1Txt.text];
    [oldBadBHArray addObject:_behavior2Txt.text];
    
    [self shouldPerformSegueWithIdentifier:@"saveBehaviorsToChangeGoToThingsToDoInsteadSegue" sender:self];
}

- (IBAction)closeButton:(id)sender {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"saveBehaviorsToChangeGoToThingsToDoInsteadSegue"])
    {
        ThingsToDoInsteadViewController *controller = (ThingsToDoInsteadViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
        controller.behaviorToChange1 = _behavior1Txt.text;
        if (_behavior2Txt.text.length != 0) {
            controller.behaviorToChange2 = _behavior2Txt.text;
        }
    }
}
@end
