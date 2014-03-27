//
//  RewardPricesViewController.m
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "RewardPricesViewController.h"
#import "CompleteSetupViewController.h"

@interface RewardPricesViewController ()
{
    NSString *oldPrice1;
    NSString *oldPrice2;
    NSString *oldPrice3;
    NSString *oldPrice4;
    NSString *oldPrice5;
    NSString *oldPrice6;
    NSString *oldPrice7;
    NSString *oldPrice8;
    
    int textFieldNumber;
    int rectPosX;
    int rectPosY;
    NSMutableArray *oldrewardsArray;
}
@end

@implementation RewardPricesViewController

BOOL hasSavedRewardPrices = NO;
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
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    oldrewardsArray = [function getRewards];
    
    if ([[_notebook getRewards] count] > 0) {
        if ([[_notebook getRewards][0][@"price"] length] > 0) {
            hasSavedRewardPrices = YES;
        }
        rectPosY = 40;
        [self LoadRewardList2];
    }
    else
    {
        rectPosY = 20;
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)keyboardAdapter: (UITextField*)textfieldName
{
    
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [textfieldName isFirstResponder])
    {
        [_nbScrollView setContentOffset:CGPointMake(0, ((textfieldName.frame.origin.y) - 200)) animated: YES];

    }
    if([[UIScreen mainScreen] bounds].size.height <= 480 && [textfieldName isFirstResponder])
    {
        // add stuff for iphone 3.5in or iphone great than 4in
    }
}

// makes the screen return to its normal position after the keyboard has retracted
- (void)keyboardDidHide:(NSNotification *)notification
{
    
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        [_nbScrollView setContentOffset:CGPointMake(0, 20) animated: YES];

    }
    else {
        // add stuff for iphone 3.5in or iphone great than 4in
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createTextFieldWithText: (NSString *) textToAdd: (NSString *)withLabel
{
    rectPosY = rectPosY + 40;
    [self createTextField2WithText: rectPosY: textToAdd: withLabel];
}

-(void)createTextField2WithText: (int)withYPos: (NSString *)andTextToAdd: (NSString *)withLabel
{
    //create label
    CGRect labelrect = CGRectMake(20, (withYPos), 125, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:labelrect];
    label.text = withLabel;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica Neue" size: 14.0 ];
    [_contentView addSubview:label];
    
    textFieldNumber++;
    CGRect rect = CGRectMake(200, (withYPos), 90, 30);
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    //textField = [[UITextField alloc] initWithFrame:rect];
    textField.tag = textFieldNumber;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.backgroundColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:12.0];
    textField.font = [UIFont fontWithName:@"Helvetica Neue" size: 12.0 ];
    textField.placeholder = [NSString stringWithFormat:@"Enter Price %d", textFieldNumber ];
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    [textField addTarget:self action: @selector(keyboardAdapter:) forControlEvents:UIControlEventEditingDidBegin];
    
    _nbScrollView.contentSize = CGSizeMake(320, rectPosY + 100);
    _contentView.frame = CGRectMake(0, 0, 320, _nbScrollView.frame.size.height + 150);
    [textField setAlpha:0];
    [_contentView addSubview:textField];
    [self fadeTextIn:textField withLabel:nil];
    textField.text = andTextToAdd;
    
}

- (void)saveAllTextFields
{
    NSMutableArray *txtArray = [[NSMutableArray alloc] init];
    
    for (UITextField *field in _contentView.subviews)
    {
        if ([field isKindOfClass:[UITextField class]] && field.text.length > 0)
        {
            [txtArray addObject: field.text];
            NSLog(@"saved price");
        }
    }
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    oldrewardsArray = [function getRewards];
    NSEnumerator *oldRewards = [oldrewardsArray objectEnumerator];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id textField in txtArray) {
        
        NSString *oldname = [NSString stringWithString:[oldRewards nextObject][@"reward_name"]];
        _notebook = [_notebook updateRewardPriceWithName:oldname toNewPrice:textField fromNotebook:_notebook];
      
    }
    hasSavedRewardPrices = YES;
    oldrewardsArray = array;
}

- (void)LoadRewardList2
{
    NSMutableArray *rewardList = [[NSMutableArray alloc] init];
    rewardList = [_notebook getRewards];
    
    for (id obj in rewardList)
    {
        [self createTextFieldWithText:obj[@"price"]: obj[@"reward_name"]];
    }
}

- (IBAction)closeButton:(id)sender {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)saveAndContinueClick:(id)sender {
    
    [self shouldPerformSegueWithIdentifier:@"saveRewardPricesGoToCompleteNotebook" sender:self];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    int textFieldNum = 0;
    int textFieldNumCheck = 0;
    // NOTE: Will need updated when we create next screen.
    if ([identifier isEqualToString:@"saveRewardPricesGoToCompleteNotebook"])
    {
        
        for (UITextField *field in _contentView.subviews)
        {
            field.layer.borderColor = [[UIColor clearColor]CGColor];
            
            if ([field isMemberOfClass:[UITextField class]] && field.text.length > 0 && field.tag >= 1)
            {
                textFieldNum = textFieldNum + 1;
                textFieldNumCheck++;
                
            }
            
            if ([field isMemberOfClass:[UITextField class]] && field.text.length == 0 && field.tag >= 1)
            {
                field.layer.borderColor = [[UIColor redColor]CGColor];
                field.layer.borderWidth = 1.0f;
                textFieldNumCheck++;
                
                NSLog(@"NO");
                
            }
            
        }
        
        if (textFieldNum == textFieldNumCheck)
        {
            [self saveAllTextFields];
            NSLog(@"YES");
            
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    return NO;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue    
    if ([[segue identifier] isEqualToString:@"saveRewardPricesGoToCompleteNotebook"])
    {
        CompleteSetupViewController *controller = (CompleteSetupViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
    }
}
@end
