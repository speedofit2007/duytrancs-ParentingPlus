//
//  ObserveAndRewardViewController.m
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "ObserveAndRewardViewController.h"
#import "RewardsToEarnViewController.h"
#import "InfoViewController.h"


@interface ObserveAndRewardViewController ()
{
    NSString *oldTime1;
    NSString *oldTime2;
    NSString *oldTime3;
    NSString *oldTime4;
}
@end

@implementation ObserveAndRewardViewController

BOOL hasSavedObserveAndReward = NO;

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
    if ([_time1Txt isFirstResponder])
    {
        [self fadeTextIn:_time2Txt withLabel:_timeLabel02];
    }
    if ([_time2Txt isFirstResponder])
    {
        [self fadeTextIn:_time3Txt withLabel:_timeLabel03];
    }
    if ([_time3Txt isFirstResponder])
    {
        [self fadeTextIn:_time4Txt withLabel:_timeLabel04];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    if ([[_notebook getBehaviorsCheckinTime] count] > 0) {
        [self LoadBehaviorsCheckinTime];
        hasSavedObserveAndReward = YES;
    }
    
    if (_time2Txt.text.length == 0)
    {
        [_timeLabel02 setAlpha:0];
        [_time2Txt setAlpha:0];
    }
    if (_time3Txt.text.length == 0)
    {
        [_timeLabel03 setAlpha:0];
        [_time3Txt setAlpha:0];
    }
    if (_time4Txt.text.length == 0)
    {
        [_timeLabel04 setAlpha:0];
        [_time4Txt setAlpha:0];
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
    controller.transition = 5;
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
    if ([_time1Txt isFirstResponder])
    {
        [self fadeTextIn:_time2Txt withLabel:_timeLabel02];
        [_time2Txt becomeFirstResponder];
        return YES;
    }
    if ([_time2Txt isFirstResponder])
    {
        [self fadeTextIn:_time3Txt withLabel:_timeLabel03];
        [_time3Txt becomeFirstResponder];
        return YES;
    }
    if ([_time3Txt isFirstResponder])
    {
        [self fadeTextIn:_time4Txt withLabel:_timeLabel04];
        [_time4Txt becomeFirstResponder];
        return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_time4Txt resignFirstResponder];
        NSLog(@"last textfield done");
    }
    return NO;
}

- (void)LoadBehaviorsCheckinTime
{
    NSMutableArray *timeList = [[NSMutableArray alloc]init];
    timeList = [_notebook getBehaviorsCheckinTime];
    _time2Txt.text = _time3Txt.text = _time4Txt.text = @"";
    if ([timeList[0][@"timeperiod"] length] > 0) oldTime1 = _time1Txt.text = timeList[0][@"timeperiod"];
    if ([timeList count] > 1) oldTime2 = _time2Txt.text = timeList[1][@"timeperiod"];
    if ([timeList count] > 2) oldTime3 = _time3Txt.text = timeList[2][@"timeperiod"];
    if ([timeList count] > 3) oldTime4 = _time4Txt.text = timeList[3][@"timeperiod"];
}

- (IBAction)saveAndContinueClick:(id)sender {
    
    if (hasSavedObserveAndReward == NO)
    {
        // this works
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
        [dict1 setObject:_time1Txt.text forKey:@"timeperiod"];
        [array addObject:dict1];
        
        if (_time2Txt.text.length > 0) {
            NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
            [dict2 setObject:_time2Txt.text forKey:@"timeperiod"];
            [array addObject:dict2];
        }
        
        if (_time3Txt.text.length > 0) {
            NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] init];
            [dict3 setObject:_time3Txt.text forKey:@"timeperiod"];
            [array addObject:dict3];
        }
        
        if (_time4Txt.text.length > 0) {
            NSMutableDictionary *dict4 = [[NSMutableDictionary alloc] init];
            [dict4 setObject:_time4Txt.text forKey:@"timeperiod"];
            [array addObject:dict4];
        }
        _notebook = [_notebook setBehaviorsCheckinTimeFromNotebook:_notebook withTime:array];
        
        hasSavedObserveAndReward = YES;

        NSLog(@"saved reward times for first time");
    }
    else
    {
        // this is not working, but it should be
        if ([oldTime1 isEqualToString:_time1Txt.text] == FALSE && ([oldTime1 length] != 0 || [_time1Txt.text length] != 0)) {
            _notebook = [_notebook updateBehaviorsCheckinTimeWithOldTime:oldTime1 toNewTime:_time1Txt.text fromNotebook:_notebook];
        }
        if ([oldTime2 isEqualToString:_time2Txt.text] == FALSE && ([oldTime2 length] != 0 || [_time2Txt.text length] != 0)){
            _notebook = [_notebook updateBehaviorsCheckinTimeWithOldTime:oldTime2 toNewTime:_time2Txt.text fromNotebook:_notebook];
        }
        if ([oldTime3 isEqualToString:_time3Txt.text] == FALSE && ([oldTime3 length] != 0 || [_time3Txt.text length] != 0)){
            _notebook = [_notebook updateBehaviorsCheckinTimeWithOldTime:oldTime3 toNewTime:_time3Txt.text fromNotebook:_notebook];
        }
        if ([oldTime4 isEqualToString:_time4Txt.text] == FALSE && ([oldTime4 length] != 0 || [_time4Txt.text length] != 0)){
            _notebook = [_notebook updateBehaviorsCheckinTimeWithOldTime:oldTime4 toNewTime:_time4Txt.text fromNotebook:_notebook];
        }
        NSLog(@"updating reward times");

    }
    
    if (_time1Txt.text.length > 0) {
        oldTime1 = _time1Txt.text;
    } if (_time2Txt.text.length > 0) {
        oldTime2 = _time2Txt.text;
    } if (_time3Txt.text.length > 0) {
        oldTime3 = _time3Txt.text;
    } if (_time4Txt.text.length > 0) {
        oldTime4 = _time4Txt.text;
    }
    
    [self shouldPerformSegueWithIdentifier:@"saveObserveRewardBehaviorGoToRewardsToEarnSegue" sender:self];
}

- (IBAction)closeButton:(id)sender {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    // NOTE: Will need updated when we create next screen.
    if ([identifier isEqualToString:@"saveObserveRewardBehaviorGoToRewardsToEarnSegue"])
    {
        // Clear the borders in case there are no errors.
        _time1Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        if (_time1Txt.text.length > 0)
        {
            return YES;
        }
        else
        {
            // Set borders on the offending controls that need rectified.
            if (_time1Txt.text.length == 0)
            {
                _time1Txt.layer.borderColor = [[UIColor redColor]CGColor];
                _time1Txt.layer.borderWidth = 1.0f;
            }
            return NO;
        }
    }
    
    return YES;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    if ([[segue identifier] isEqualToString:@"saveObserveRewardBehaviorGoToRewardsToEarnSegue"])
    {
        RewardsToEarnViewController *controller = (RewardsToEarnViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
    }
}
@end
