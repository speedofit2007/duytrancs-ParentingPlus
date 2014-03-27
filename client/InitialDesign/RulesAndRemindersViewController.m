//
//  RulesAndRemindersViewController.m
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "RulesAndRemindersViewController.h"
#import "ObserveAndRewardViewController.h"
#import "InfoViewController.h"


@interface RulesAndRemindersViewController ()
{
    NSString *oldRules1;
    NSString *oldRules2;
}
@end

@implementation RulesAndRemindersViewController

BOOL hasSavedRulesAndReminders = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    if ([[_notebook getBehaviorsToChange] count] > 0) {
        if ([[_notebook getBehaviorsToChange][0][@"reminders"] length] > 0) {
            [self LoadRules];
            hasSavedRulesAndReminders = YES;
        }
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
    controller.transition = 4;
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
    if ([_rule1Txt isFirstResponder])
    {
        [_rule2Txt becomeFirstResponder];
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_rule2Txt resignFirstResponder];
        NSLog(@"last textfield done");
    }
    return NO;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // NOTE: Will need updated when we create next screen.
    if ([identifier isEqualToString:@"saveRules&RemindersGoToObserve&RewardSegue"])
    {
        // Clear the borders in case there are no errors.
        _rule1Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        if (_rule1Txt.text.length > 0)
        {
            return YES;
        }
        else
        {
            // Set borders on the offending controls that need rectified.
            if (_rule1Txt.text.length == 0)
            {
                _rule1Txt.layer.borderColor = [[UIColor redColor]CGColor];
                _rule1Txt.layer.borderWidth = 1.0f;
            }
            return NO;
        }
    }
    return NO;
}

// Load the values from the DB to be displayed upon reviewing a notebook.
- (void)LoadRules
{
    NSMutableArray *rulesList = [[NSMutableArray alloc]init];
    OutlineDBFunction *function = [[OutlineDBFunction alloc]init];
    rulesList = [function getBadBehaviorsLastest];
    _rule1Txt.text = _rule2Txt.text = @"";
    if ([rulesList count] > 0) oldRules1 = _rule1Txt.text = rulesList[0][@"reminders"];
    if ([rulesList count] > 1) oldRules2 = _rule2Txt.text = rulesList[1][@"reminders"];
}

- (IBAction)saveAndContinueClick:(id)sender {
    
    if (_behaviorToChange2.length == 0) {
        _rule2Txt.hidden = YES;
        _reminderLbl2.hidden = YES;
    }
    
    if (hasSavedRulesAndReminders == NO) {
        
        //NSMutableArray *arraybadBehavior = [[NSMutableArray alloc] init];
        
        //NSMutableArray *arraybadBehavior = [_notebook getBehaviorsToChangeFromNotebook:_notebook];
        //[arraybadBehavior[0] setObject:_rule1Txt.text forKey:@"reminders"];
        _notebook = [_notebook updateBadBehaviorWithNewBehavior:_behaviorToChange1 fromOldRule: oldRules1 toNewRule:_rule1Txt.text fromNotebook:_notebook];
        if (_rule2Txt.text.length > 0) {
            //[arraybadBehavior[1] setObject:_rule2Txt.text forKey:@"reminders"];
            _notebook = [_notebook updateBadBehaviorWithNewBehavior:_behaviorToChange2 fromOldRule: oldRules2 toNewRule:_rule2Txt.text fromNotebook:_notebook];
        }
        // save rules into database
        hasSavedRulesAndReminders = YES;
        //[_notebook setBehaviorsToChangeFromNotebook:_notebook withBadBehavior:arraybadBehavior];
    }
    
    else {
        if ([oldRules1 isEqualToString:_rule1Txt.text] == FALSE && ([oldRules1 length] != 0 || [_rule1Txt.text length] != 0)) {
            _notebook = [_notebook updateBadBehaviorWithNewBehavior:_behaviorToChange1 fromOldRule: oldRules1 toNewRule:_rule1Txt.text fromNotebook:_notebook];
        }
        if ([oldRules2 isEqualToString:_rule2Txt.text] == FALSE && ([oldRules2 length] != 0 || [_rule2Txt.text length] != 0)){
            _notebook = [_notebook updateBadBehaviorWithNewBehavior:_behaviorToChange2 fromOldRule: oldRules2 toNewRule:_rule2Txt.text fromNotebook:_notebook];
        }
    }
    
    if (_rule1Txt.text.length > 0) {
        oldRules1 = [NSString stringWithFormat:@"%@", _rule1Txt.text];
    }
    if (_rule2Txt.text.length > 0) {
        oldRules2 = [NSString stringWithFormat:@"%@", _rule2Txt.text];
    }
    
    [self shouldPerformSegueWithIdentifier:@"saveRules&RemindersGoToObserve&RewardSegue" sender:self];
}

- (IBAction)closeButton:(id)sender {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    if ([[segue identifier] isEqualToString:@"saveRules&RemindersGoToObserve&RewardSegue"])
    {
        ObserveAndRewardViewController *controller = (ObserveAndRewardViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
    }
}

@end
