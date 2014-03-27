//
//  ThingsToDoInsteadViewController.m
//  Parenting+
//

#import "ThingsToDoInsteadViewController.h"
#import "RulesAndRemindersViewController.h"
#import "InfoViewController.h"

@interface ThingsToDoInsteadViewController () {
    NSString *oldThingToDoInstead1;
    NSString *oldThingToDoInstead2;
    NSString *oldThingToDoInstead3;
    NSString *oldThingToDoInstead4;
    NSMutableArray *oldChangeBHArray;
    NSMutableArray *badBHArray;
}

@end

@implementation ThingsToDoInsteadViewController

BOOL hasSavedThingsToDoInstead = NO;
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
    if (_behavior1Txt.text.length == 0)
    {
        [self fadeTextIn:_behavior2Txt withLabel:nil];
    }
    if (_behavior3Txt.hidden == NO && _behavior3Txt.text.length == 0)
    {
        [self fadeTextIn:_behavior4Txt withLabel:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    // load labels and text boxes based on behaviors to change
    _doInstead1Lbl.text = [NSString stringWithFormat:@"%@%@%@", @"Enter 1 - 2 things your child may do instead of '", _behaviorToChange1, @"':"];
    
    if (_behaviorToChange2.length == 0) {
        _doInstead2Lbl.hidden = YES;
        _behavior3Txt.hidden = YES;
        _behavior4Txt.hidden = YES;
    } else {
        _doInstead2Lbl.text = [NSString stringWithFormat:@"%@%@%@", @"Enter 1 - 2 things your child may do instead of '", _behaviorToChange2, @"':"];
    }
    if ([[_notebook getBehaviorsToDoInstead] count] > 0) {
        [self LoadThingsToDoInstead];
        hasSavedThingsToDoInstead = YES;
    }
    
    //Gesture recogizer to hide keyboard
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(keyboardHide)];
    tapScroll.cancelsTouchesInView = NO;
    [_nbScrollView addGestureRecognizer: tapScroll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)infoClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InfoViewController *controller = (InfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    controller.transition = 3;
    controller.parent = self;
    [self presentViewController:controller animated:YES completion:nil];
}

-(IBAction)keyboardAdapter: (UITextField*)textfieldName
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [textfieldName isFirstResponder])
    {
        //_nbScrollView.frame = CGRectMake(0,(-(textfieldName.frame.origin.y) + 150),320,700);
        [_nbScrollView setContentOffset:CGPointMake(0, ((textfieldName.frame.origin.y) - 100)) animated: YES];
        [UIView commitAnimations];
    }
    if ([[UIScreen mainScreen] bounds].size.height <= 480 && [textfieldName isFirstResponder])
    {
        //[self.view setFrame:CGRectMake(0,(-(textfieldName.frame.origin.y) + 150),320,580)];
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
        //_nbScrollView.frame = CGRectMake(0,0,320, 443);
        [_nbScrollView setContentOffset:CGPointMake(0, 0) animated: YES];
        [UIView commitAnimations];
    }
    else {
        //[self.view setFrame:CGRectMake(0,0,320,410)];
        [UIView commitAnimations];
    }
    
}

// hide the keyboard when user taps outside of keyboard
- (void) keyboardHide
{
    [self.view endEditing:YES];
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.nbScrollView layoutIfNeeded];
    self.nbScrollView.contentSize = self.contentView.bounds.size;
}

// Have the focus go to the next textfield after a user ends editing
- (BOOL)textFieldReturnNext:(id)sender
{
    // Does the first textfield have the focus? If yes, go to the next one
    if ([_behavior1Txt isFirstResponder])
    {
        //[self fadeTextIn:_behavior2Txt withLabel:nil];
        [_behavior2Txt becomeFirstResponder];
        return YES;
    }
    if ([_behavior2Txt isFirstResponder] && _behavior3Txt.hidden == NO)
    {
        [_behavior3Txt becomeFirstResponder];
        return YES;
    }
    if ([_behavior3Txt isFirstResponder])
    {
        //[self fadeTextIn:_behavior4Txt withLabel:nil];
        [_behavior4Txt becomeFirstResponder];
        return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_behavior4Txt resignFirstResponder];
        NSLog(@"last textfield done");
    }
    return NO;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // NOTE: Will need updated when we create next screen.
    if ([identifier isEqualToString:@"saveThingsICanDoInsteadGoToRulesRemindersSegue"])
    {
        // Clear the borders in case there are no errors.
        _behavior1Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        _behavior2Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        _behavior3Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        _behavior4Txt.layer.borderColor = [[UIColor clearColor]CGColor];
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
        /* DEBUGGING CODE
         NSLog(@"%l", _behavior1Txt.text.length);
         NSLog(@"%l", _behavior2Txt.text.length);
         NSLog(@"%l", _behavior3Txt.text.length);
         NSLog(@"%l", _behavior4Txt.text.length);
         return YES;*/
    }
    return NO;
}


// Load the values from the DB to be displayed upon reviewing a notebook.
- (void)LoadThingsToDoInstead
{
    OutlineDBFunction *function = [[OutlineDBFunction alloc]init];
    oldChangeBHArray = [[NSMutableArray alloc]init];
    badBHArray = [[NSMutableArray alloc]init];
    NSMutableArray *behaviorList = [[NSMutableArray alloc] init];
    behaviorList = [function getChangeBehaviorsDisplay];
    //behaviorList = [_notebook getBehaviorsToDoInstead];
    
    oldThingToDoInstead1 = _behavior1Txt.text = behaviorList[0][@"bhname"];
    _behavior2Txt.text = @"";
    _behavior3Txt.text = @"";
    _behavior4Txt.text = @"";
    if ([behaviorList count] > 1) {
        if ([behaviorList[0][@"badBehavior_name"] isEqualToString:behaviorList[1][@"badBehavior_name"]] == TRUE) {
            oldThingToDoInstead2 = _behavior2Txt.text = behaviorList[1][@"bhname"];
            if ([behaviorList count] > 2) oldThingToDoInstead3 = _behavior3Txt.text = behaviorList[2][@"bhname"];
            if ([behaviorList count] > 3) oldThingToDoInstead4 = _behavior4Txt.text = behaviorList[3][@"bhname"];
        } else if ([behaviorList[1][@"bhname"] length] > 0) {
            oldThingToDoInstead3 = _behavior3Txt.text = behaviorList[1][@"bhname"];
            if ([behaviorList count] > 3) oldThingToDoInstead4 = _behavior4Txt.text = behaviorList[2][@"bhname"];
        }
    }
    [oldChangeBHArray addObject:_behavior1Txt.text];
    [oldChangeBHArray addObject:_behavior2Txt.text];
    [oldChangeBHArray addObject:_behavior3Txt.text];
    [oldChangeBHArray addObject:_behavior4Txt.text];
}

- (IBAction)saveAndContinueClick:(id)sender {
    NSMutableArray *newChangeBHArray = [[NSMutableArray alloc]init];
    [newChangeBHArray addObject:_behavior1Txt.text];
    [newChangeBHArray addObject:_behavior2Txt.text];
    [newChangeBHArray addObject:_behavior3Txt.text];
    [newChangeBHArray addObject:_behavior4Txt.text];
    
    [badBHArray addObject:_behaviorToChange1];
    [badBHArray addObject:_behaviorToChange1];
    
    _behaviorToChange2 = _behaviorToChange2? _behaviorToChange2 : @"";
    
    [badBHArray addObject:_behaviorToChange2];
    [badBHArray addObject:_behaviorToChange2];
    
    
    if (hasSavedThingsToDoInstead == NO)
    {
        // this works
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
        [dict1 setObject:_behaviorToChange1 forKey:@"badBehavior_name"];
        [dict1 setObject:_behavior1Txt.text forKey:@"bhname"];
        [array addObject:dict1];
        
        if (_behavior2Txt.text.length > 0) {
            NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
            [dict2 setObject:_behaviorToChange1 forKey:@"badBehavior_name"];
            [dict2 setObject:_behavior2Txt.text forKey:@"bhname"];
            [array addObject:dict2];
        }
        
        if (_behavior3Txt.text.length > 0) {
            NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] init];
            [dict3 setObject:_behaviorToChange2 forKey:@"badBehavior_name"];
            [dict3 setObject:_behavior3Txt.text forKey:@"bhname"];
            [array addObject:dict3];
        }
        
        if (_behavior4Txt.text.length > 0) {
            NSMutableDictionary *dict4 = [[NSMutableDictionary alloc] init];
            [dict4 setObject:_behaviorToChange2 forKey:@"badBehavior_name"];
            [dict4 setObject:_behavior4Txt.text forKey:@"bhname"];
            [array addObject:dict4];
        }
        
        // save things to do instead into database
        _notebook = [_notebook setBehaviorsToDoInsteadFromNotebook:_notebook withChangeBehavior:array];
        hasSavedThingsToDoInstead = YES;
    }
    else
    {
        // Update call to DB
        /*if ([oldThingToDoInstead1 isEqualToString:_behavior1Txt.text] == FALSE && ([oldThingToDoInstead1 length] != 0 || [_behavior1Txt.text length] != 0)) {
         _notebook = [_notebook updateBehaviorsToDoInsteadWithOldName:oldThingToDoInstead1 toNewName:_behavior1Txt.text ofbadBehavior: _behaviorToChange1 fromNotebook:_notebook];
         } if ([oldThingToDoInstead2 isEqualToString:_behavior2Txt.text] == FALSE && ([oldThingToDoInstead2 length] != 0 || [_behavior2Txt.text length] != 0)) {
         _notebook = [_notebook updateBehaviorsToDoInsteadWithOldName:oldThingToDoInstead2 toNewName:_behavior2Txt.text ofbadBehavior: _behaviorToChange1 fromNotebook:_notebook];
         } if ([oldThingToDoInstead3 isEqualToString:_behavior3Txt.text] == FALSE && ([oldThingToDoInstead3 length] != 0 || [_behavior3Txt.text length] != 0)) {
         _notebook = [_notebook updateBehaviorsToDoInsteadWithOldName:oldThingToDoInstead3 toNewName:_behavior3Txt.text ofbadBehavior: _behaviorToChange2 fromNotebook:_notebook];
         } if ([oldThingToDoInstead4 isEqualToString:_behavior4Txt.text] == FALSE && ([oldThingToDoInstead4 length] != 0 || [_behavior4Txt.text length] != 0)) {
         _notebook = [_notebook updateBehaviorsToDoInsteadWithOldName:oldThingToDoInstead4 toNewName:_behavior4Txt.text ofbadBehavior: _behaviorToChange2 fromNotebook:_notebook];
         }*/
        if ([_notebook isTextViewChange:oldChangeBHArray compareTo:newChangeBHArray]) {
            [_notebook updateBehaviorsToDoInsteadWithOldArray:oldChangeBHArray toNewArray:newChangeBHArray ofBadBH:badBHArray fromNotebook:_notebook];
        }
        NSLog(@"updated things to do instead");
        
    }
    
    oldChangeBHArray = [[NSMutableArray alloc]init];
    [oldChangeBHArray addObject:_behavior1Txt.text];
    [oldChangeBHArray addObject:_behavior2Txt.text];
    [oldChangeBHArray addObject:_behavior3Txt.text];
    [oldChangeBHArray addObject:_behavior4Txt.text];
    
    [self shouldPerformSegueWithIdentifier:@"saveThingsICanDoInsteadGoToRulesRemindersSegue" sender:self];
}

- (IBAction)closeButton:(id)sender {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    if ([[segue identifier] isEqualToString:@"saveThingsICanDoInsteadGoToRulesRemindersSegue"])
    {
        RulesAndRemindersViewController *controller = (RulesAndRemindersViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
        controller.behaviorToChange1 = _behaviorToChange1;
        if (_behavior2Txt.text.length != 0) {
            controller.behaviorToChange2 = _behaviorToChange2;
        }
    }
}
@end
