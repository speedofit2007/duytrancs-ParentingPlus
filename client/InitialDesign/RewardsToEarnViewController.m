//
//  RewardsToEarnViewController.m
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "RewardsToEarnViewController.h"
#import "RewardPricesViewController.h"
#import "InfoViewController.h"

@interface RewardsToEarnViewController ()
{
    NSString *oldreward1;
    NSString *oldreward2;
    NSString *oldreward3;
    NSString *oldreward4;
    NSString *oldreward5;
    NSString *oldreward6;
    NSString *oldreward7;
    NSString *oldreward8;
    int textFieldNumber;
    int rectPosX;
    int rectPosY;
    NSMutableArray *oldrewardsArray;
}

@end

@implementation RewardsToEarnViewController

BOOL hasSavedRewardsToEarn = NO;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    if ([[_notebook getRewards] count] > 0) {
        
        oldrewardsArray = [_notebook getRewards];
        
        for (UITextField *field in _contentView.subviews)
        {
            if ([field isKindOfClass:[UITextField class]])
            {
                field.text = nil;
                [field setAlpha:0];
            }
        }
        rectPosY = 40;
        [self LoadRewardList2];
        hasSavedRewardsToEarn = YES;
    }
    else
    {
        rectPosY = 35;
        for (UITextField *field in _contentView.subviews)
        {
            if ([field isKindOfClass:[UITextField class]])
            {
                textFieldNumber++;
                rectPosY = rectPosY + 40;
            }
        }

    }
    
    //Gesture recogizer to hide keyboard
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(keyboardHide)];
    tapScroll.cancelsTouchesInView = NO;
    [_nbScrollView addGestureRecognizer: tapScroll];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

- (IBAction)infoClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InfoViewController *controller = (InfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    controller.transition = 6;
    controller.parent = self;
    [self presentViewController:controller animated:YES completion:nil];
}

-(IBAction)keyboardAdapter: (UITextField*)textfieldName
{
    
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [textfieldName isFirstResponder])
    {
        [_nbScrollView setContentOffset:CGPointMake(0, ((textfieldName.frame.origin.y) - 150)) animated: NO];

    }
    if([[UIScreen mainScreen] bounds].size.height <= 480 && [textfieldName isFirstResponder])
    {
        // add stuff for iphone 3.5in or iphone great than 4in
        //[UIView commitAnimations];
    }
}

// makes the screen return to its normal position after the keyboard has retracted
- (void)keyboardDidHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        [_nbScrollView setContentOffset:CGPointMake(0, 20) animated: YES];
        //[UIView commitAnimations];
    }
    else {
        // add stuff for iphone 3.5in or iphone great than 4in
        //[UIView commitAnimations];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    int tagNum = textField.tag;
    tagNum = tagNum + 1;

    [[self.view viewWithTag:tagNum] becomeFirstResponder];
    
    //[textField resignFirstResponder];
    return NO;
}

// hide the keyboard when user taps outside of keyboard
- (void) keyboardHide
{
    [self.view endEditing:YES];
}

-(IBAction) nextTextfield: (UITextField *) textField
{
    int tagNum = textField.tag;
    tagNum = tagNum + 1;
    
    [[self.view viewWithTag:tagNum] becomeFirstResponder];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.nbScrollView layoutIfNeeded];
    self.nbScrollView.contentSize = self.contentView.bounds.size;
}

// work in progress!
- (IBAction)createTextField
{
        rectPosY = rectPosY + 40;
        [self createTextField2:rectPosY];
}

- (IBAction)createTextFieldCheck: (UITextField *) textfield
{
    if (textfield.tag == textFieldNumber)
    {
        rectPosY = rectPosY + 40;
        [self createTextField2:rectPosY];
    }
    else
    {
        
    }
}

-(void)createTextFieldWithText: (NSString *) textToAdd
{
    rectPosY = rectPosY + 40;
    [self createTextField2WithText: rectPosY: textToAdd];
}

-(void)createTextField2: (int)withYPos
{
    textFieldNumber++;
    CGRect rect = CGRectMake(20, (withYPos), 280, 30);
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    //textField = [[UITextField alloc] initWithFrame:rect];
    textField.tag = textFieldNumber;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.backgroundColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:14.0];
    textField.font = [UIFont fontWithName:@"Helvetica Neue" size: 14.0 ];
    textField.placeholder = [NSString stringWithFormat:@"Enter Reward %d", textFieldNumber ];
    textField.returnKeyType = UIReturnKeyNext;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [textField addTarget:self action: @selector(createTextFieldCheck:) forControlEvents:UIControlEventEditingDidBegin];
    [textField addTarget:self action: @selector(keyboardAdapter:) forControlEvents:UIControlEventEditingDidBegin];
    [textField addTarget:self action: @selector(nextTextfield:) forControlEvents:UIControlEventEditingDidEndOnExit];
    _nbScrollView.contentSize = CGSizeMake(320, rectPosY + 100);
    _contentView.frame = CGRectMake(0, 0, 320, _nbScrollView.frame.size.height + 250);
    [textField setAlpha:0];
    [_contentView addSubview:textField];
    [self fadeTextIn:textField withLabel:nil];
    
}

-(void)createTextField2WithText: (int)withYPos: (NSString *)andTextToAdd
{
    textFieldNumber++;
    CGRect rect = CGRectMake(20, (withYPos), 280, 30);
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    //textField = [[UITextField alloc] initWithFrame:rect];
    textField.tag = textFieldNumber;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.backgroundColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:14.0];
    textField.font = [UIFont fontWithName:@"Helvetica Neue" size: 14.0 ];
    textField.placeholder = [NSString stringWithFormat:@"Enter Reward %d", textFieldNumber ];
    textField.returnKeyType = UIReturnKeyNext;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    [textField addTarget:self action: @selector(createTextFieldCheck:) forControlEvents:UIControlEventEditingDidBegin];
    [textField addTarget:self action: @selector(keyboardAdapter:) forControlEvents:UIControlEventEditingDidBegin];
    [textField addTarget:self action: @selector(nextTextfield:) forControlEvents:UIControlEventEditingDidEndOnExit];
    _nbScrollView.contentSize = CGSizeMake(320, rectPosY + 100);
    _contentView.frame = CGRectMake(0, 0, 320, _nbScrollView.frame.size.height + 250);
    [textField setAlpha:0];
    [_contentView addSubview:textField];
    [self fadeTextIn:textField withLabel:nil];
    textField.text = andTextToAdd;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)saveAllTextFields
{
    NSMutableArray *txtArray = [[NSMutableArray alloc] init];
    
    for (UITextField *field in _contentView.subviews)
    {
        if ([field isKindOfClass:[UITextField class]] && field.text.length > 0)
        {
            [txtArray addObject: field.text];
            NSLog(@"saved reward");
        }
    }
    
    NSEnumerator *oldRewards = [oldrewardsArray objectEnumerator];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id textField in txtArray) {
        if (!([textField isEqualToString:[oldRewards nextObject][@"reward_name"]]))
        {
            NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
            [dict1 setObject:textField forKey:@"reward_name"];
            [array addObject:dict1];
        }
    }
    
    _notebook = [_notebook setRewardsFromNotebook:_notebook andReward:array];
    hasSavedRewardsToEarn = YES;
    oldrewardsArray = array;
}

- (void) updateRewardField
{
    NSMutableArray *txtArray = [[NSMutableArray alloc] init];
    BOOL change = FALSE;
    for (UITextField *field in _contentView.subviews)
    {
        if ([field isKindOfClass:[UITextField class]] && field.text.length > 0)
        {
            [txtArray addObject: field.text];
            NSLog(@"saved reward");
        }
    }
    
    NSEnumerator *oldRewards = [oldrewardsArray objectEnumerator];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (txtArray.count > oldrewardsArray.count) {
        for (int i=oldrewardsArray.count; i < txtArray.count; i++){
            NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
            [dict1 setObject:@"" forKey:@"reward_name"];
            [oldrewardsArray addObject:dict1];
        }
    }
    
    for (id textField in txtArray) {
        NSString *oldname = [NSString stringWithString:[oldRewards nextObject][@"reward_name"]];
        if (!([textField isEqualToString:oldname]))
        {
            _notebook = [_notebook updateRewardWithOldName:oldname toNewName:textField fromNotebook:_notebook];
            change = TRUE;
        }
        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
        [dict1 setObject:textField forKey:@"reward_name"];
        [array addObject:dict1];
    }
    
    if (change == TRUE) oldrewardsArray = array;
}

- (void)LoadRewardList2
{
    NSMutableArray *rewardList = [[NSMutableArray alloc] init];
    rewardList = [_notebook getRewards];
    
    for (id obj in rewardList)
    {
        [self createTextFieldWithText:obj[@"reward_name"]];
    }
}

/*
- (void)LoadRewardList
{
    NSMutableArray *rewardList = [[NSMutableArray alloc] init];
    rewardList = [_notebook getRewards];
    _reward2Txt.text = _reward3Txt.text = _reward4Txt.text = _reward5Txt.text = @"";
    _reward6Txt.text = _reward7Txt.text = _reward8Txt.text = @"";
    if ([rewardList[0][@"reward_name"] length] > 0) oldreward1 = _reward1Txt.text = rewardList[0][@"reward_name"];
    if ([rewardList count] > 1) oldreward2 = _reward2Txt.text = rewardList[1][@"reward_name"];
    if ([rewardList count] > 2) oldreward3 = _reward3Txt.text = rewardList[2][@"reward_name"];
    if ([rewardList count] > 3) oldreward4 = _reward4Txt.text = rewardList[3][@"reward_name"];
    if ([rewardList count] > 4) oldreward5 = _reward5Txt.text = rewardList[4][@"reward_name"];
    if ([rewardList count] > 5) oldreward6 = _reward6Txt.text = rewardList[5][@"reward_name"];
    if ([rewardList count] > 6) oldreward7 = _reward7Txt.text = rewardList[6][@"reward_name"];
    if ([rewardList count] > 7) oldreward8 = _reward8Txt.text = rewardList[7][@"reward_name"];
    
}
 */

- (IBAction)saveAndContinueClick:(id)sender {
    
    /* if (hasSavedRewardsToEarn == NO)
     {
     // no function call is needed here according to Duy's database functions - Neil
     NSMutableArray *txtArray = [[NSMutableArray alloc] init];
     if (_reward1Txt.text.length > 0)[txtArray addObject:_reward1Txt.text];
     if (_reward2Txt.text.length > 0)[txtArray addObject:_reward2Txt.text];
     if (_reward3Txt.text.length > 0)[txtArray addObject:_reward3Txt.text];
     if (_reward4Txt.text.length > 0)[txtArray addObject:_reward4Txt.text];
     if (_reward5Txt.text.length > 0)[txtArray addObject:_reward5Txt.text];
     if (_reward6Txt.text.length > 0)[txtArray addObject:_reward6Txt.text];
     if (_reward7Txt.text.length > 0)[txtArray addObject:_reward7Txt.text];
     if (_reward8Txt.text.length > 0)[txtArray addObject:_reward8Txt.text];
     
     NSMutableArray *array = [[NSMutableArray alloc] init];
     for (id obj in txtArray) {
     NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
     [dict1 setObject:obj forKey:@"reward_name"];
     [array addObject:dict1];
     }
     
     _notebook = [_notebook setRewardsFromNotebook:_notebook andReward:array];
     
     hasSavedRewardsToEarn = YES;
     
     
     
     NSLog(@"saved rewards for first time");
     }
     else
     {
     /*
     //[self saveAllTextFields];
     
     // no function call is needed here according to Duy's database functions - Neil
     
     if ([oldreward1 isEqualToString:_reward1Txt.text] == FALSE) {
     _notebook = [_notebook updateRewardWithOldName:oldreward1 toNewName:_reward1Txt.text fromNotebook:_notebook];
     }
     if ([oldreward2 isEqualToString:_reward2Txt.text] == FALSE && ([oldreward2 length] != 0 || [_reward2Txt.text length] != 0)) {
     _notebook = [_notebook updateRewardWithOldName:oldreward2 toNewName:_reward2Txt.text fromNotebook:_notebook];
     }
     if ([oldreward3 isEqualToString:_reward3Txt.text] == FALSE && ([oldreward3 length] != 0 || [_reward3Txt.text length] != 0)) {
     _notebook = [_notebook updateRewardWithOldName:oldreward3 toNewName:_reward3Txt.text fromNotebook:_notebook];
     }
     if ([oldreward4 isEqualToString:_reward4Txt.text] == FALSE && ([oldreward4 length] != 0 || [_reward4Txt.text length] != 0)) {
     _notebook = [_notebook updateRewardWithOldName:oldreward4 toNewName:_reward4Txt.text fromNotebook:_notebook];
     }
     if ([oldreward5 isEqualToString:_reward5Txt.text] == FALSE && ([oldreward5 length] != 0 || [_reward5Txt.text length] != 0)) {
     _notebook = [_notebook updateRewardWithOldName:oldreward5 toNewName:_reward5Txt.text fromNotebook:_notebook];
     }
     if ([oldreward6 isEqualToString:_reward6Txt.text] == FALSE && ([oldreward6 length] != 0 || [_reward6Txt.text length] != 0)) {
     _notebook = [_notebook updateRewardWithOldName:oldreward6 toNewName:_reward6Txt.text fromNotebook:_notebook];
     }
     if ([oldreward7 isEqualToString:_reward7Txt.text] == FALSE && ([oldreward7 length] != 0 || [_reward7Txt.text length] != 0)) {
     _notebook = [_notebook updateRewardWithOldName:oldreward7 toNewName:_reward7Txt.text fromNotebook:_notebook];
     }
     if ([oldreward8 isEqualToString:_reward8Txt.text] == FALSE && ([oldreward8 length] != 0 || [_reward8Txt.text length] != 0)) {
     _notebook = [_notebook updateRewardWithOldName:oldreward8 toNewName:_reward8Txt.text fromNotebook:_notebook];
     }
     hasSavedRewardsToEarn = YES;
     NSLog(@"updated rewards");
     }
     if (_reward1Txt.text > 0) {
     oldreward1 = _reward1Txt.text;
     }
     if (_reward2Txt.text > 0) {
     oldreward2 = _reward2Txt.text;
     }
     if (_reward3Txt.text > 0) {
     oldreward3 = _reward3Txt.text;
     }
     if (_reward4Txt.text > 0) {
     oldreward4 = _reward4Txt.text;
     }
     if (_reward5Txt.text > 0) {
     oldreward5 = _reward5Txt.text;
     }
     if (_reward6Txt.text > 0) {
     oldreward6 = _reward6Txt.text;
     }
     if (_reward7Txt.text > 0) {
     oldreward7 = _reward7Txt.text;
     }
     if (_reward8Txt.text > 0) {
     oldreward8 = _reward8Txt.text;
     }
     
     [self saveAllTextFields2];
     }
     */
    
    if (hasSavedRewardsToEarn == NO) // first time create rewards for this notebook
    {
        [self saveAllTextFields];
    }
    if (hasSavedRewardsToEarn == YES)
    {
        [self updateRewardField];
    }
    
    [self shouldPerformSegueWithIdentifier:@"saveRewardsToEarnGoToRewardPrices" sender:self];
}

- (IBAction)closeButton:(id)sender {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"saveRewardsToEarnGoToRewardPrices"])
    {
        // Clear the borders in case there are no errors.
        _reward1Txt.layer.borderColor = [[UIColor clearColor]CGColor];
        if (_reward1Txt.text.length > 0)
        {
            return YES;
        }
        if (hasSavedRewardsToEarn == YES && _reward1Txt.alpha == 0)
        {
            return YES;
        }
        else
        {
            // Set borders on the offending controls that need rectified.
            if (_reward1Txt.text.length == 0)
            {
                _reward1Txt.layer.borderColor = [[UIColor redColor]CGColor];
                _reward1Txt.layer.borderWidth = 1.0f;
            }
            if (_reward2Txt.text.length == 0)
            {
                _reward2Txt.layer.borderColor = [[UIColor redColor]CGColor];
                _reward2Txt.layer.borderWidth = 1.0f;
            }
            if (_reward3Txt.text.length == 0)
            {
                _reward3Txt.layer.borderColor = [[UIColor redColor]CGColor];
                _reward3Txt.layer.borderWidth = 1.0f;
            }
            return NO;
        }
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    if ([[segue identifier] isEqualToString:@"saveRewardsToEarnGoToRewardPrices"])
    {
         RewardPricesViewController *controller = (RewardPricesViewController*)segue.destinationViewController;
        /*
        controller.reward1 = _reward1Txt.text;
        controller.reward2 = _reward2Txt.text;
        controller.reward3 = _reward3Txt.text;
        controller.reward4 = _reward4Txt.text;
        controller.reward5 = _reward5Txt.text;
        controller.reward6 = _reward6Txt.text;
        controller.reward7 = _reward7Txt.text;
        controller.reward8 = _reward8Txt.text;
        */
        
        controller.notebook = _notebook;
    }
}

@end