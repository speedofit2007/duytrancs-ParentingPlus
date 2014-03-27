//
//  BehaviorsViewController.m
//  Parenting+
//
//  Created by Sean Walsh on 1/6/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "BehaviorsViewController.h"
#import "NoteBooks.h"
#import "LocalDatabase.h"
#import "OutlineDBFunction.h"
#import "PickBehaviorDateToLoadViewController.h"

@interface BehaviorsViewController ()

@end

@implementation BehaviorsViewController

NoteBooks *notebook;
LocalDatabase *ldb;

NSMutableArray *behaviorToKeepStatsFromDB;
NSMutableArray *behaviorToChangeStatsFromDB;
NSMutableArray *checkInTimes;
// Default sticker.
NSString *stickerToPlace = @"sticker01.png";

NSInteger tokensEarnedToday;
NSInteger currentTokenBalance;

bool manuallyLock = false;
bool notebookLocked = false;
bool toggleFlag = false;

/*
 * tokenStickerSlot tracks tokens earned in groups of 4 times per category, as listed below.
 * [0-3] relates to Behavior To Keep #1
 * [4-7] relates to Behavior To Keep #2
 * [8-11] relates to Behavior To Keep #3
 * [12-15] relates to Things To Do Instead #1 (for Behavior To Change #1)
 * [16-19] relates to Things To Do Instead #2 (for Behavior To Change #1)
 * [20-23] relates to Things To Do Instead #3 (for Behavior To Change #2)
 * [24-27] relates to Things To Do Instead #4 (for Behavior To Change #2)
 * [28-31] relates to Behavior To Change #1
 * [32-35] relates to Behavior To Change #2
 * 0 means that there is no token earned for that category.
 * 1 means that the token is earned for that category.
 */
NSString *tokenStickerSlot[36];
NSDate *currDate;
NSDateFormatter *dateFormatter;
NSString *dateString;
NSString *currNumberOfTokens;
OutlineDBFunction *function;

- (void)viewDidLoad
{
    // Comments in place because DB select is not functional at the moment. Upon DB working, comments can be uncommented and functionality should work seamlessly.
    [super viewDidLoad];
    [self initializeScrollView];
//    _behaviorToKeepTitleLabel.textColor = [UIColor greenColor];
    // Hide the navigation bar.
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    // Set the fonts for the labels.
    [self setFonts];
    
    // By default, initialize all stickers to unearned, then grab the value from the DB.
    for (int i = 0; i < 36; i++)
        tokenStickerSlot[i] = @"no-sticker-100px.png";
    
    // Initialize DB functionality.
    [self initializeDB];
    
    [self setAllLabelsAndValues];
}

- (void) initializeDB
{
    notebook = [[NoteBooks alloc] init];
    ldb = [[LocalDatabase alloc] init];
    notebook = [notebook getWholeClassNotebooksFromNotebookID:[ldb getCurrentNotebook]];
    function = [[OutlineDBFunction alloc]init];
    
    currentTokenBalance = [notebook getTokenBalance];
    tokensEarnedToday = 10 - [notebook dailyTokenBalanceWhen:dateString];
}

- (void) adjustLabelsForOneBTK
{
    _behaviorsToChangeLabel.frame = [self newLabelLocationWithName:_behaviorsToChangeLabel andYOffset:125];
    _behaviorToChange1.frame = [self newLabelLocationWithName:_behaviorToChange1 andYOffset:125];
    _lessOftenNotAtAllLabel1.frame = [self newLabelLocationWithName:_lessOftenNotAtAllLabel1 andYOffset:125];
    _lessOftenNotAtAllOneTimeOne.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeOne andYOffset:125];
    _lessOftenNotAtAllOneTimeTwo.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeTwo andYOffset:125];
    _lessOftenNotAtAllOneTimeThree.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeThree andYOffset:125];
    _lessOftenNotAtAllOneTimeFour.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeFour andYOffset:125];
    
    _thingToDoInsteadOfFirstBehaviorToChange2.frame = [self newLabelLocationWithName:_thingToDoInsteadOfFirstBehaviorToChange2 andYOffset:125];

    _checkInTimeNumberOneForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberOne andYOffset:125];
    _checkInTimeNumberTwoForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberOne andYOffset:125];
    _checkInTimeNumberThreeForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberOne andYOffset:125];
    _checkInTimeNumberFourForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberOne andYOffset:125];
    
    _thingToDoInsteadOfFirstBehaviorToChange1.frame = [self newLabelLocationWithName:_thingToDoInsteadOfFirstBehaviorToChange1 andYOffset:125];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberTwo andYOffset:125];
    _checkInTimeNumberTwoForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberTwo andYOffset:125];
    _checkInTimeNumberThreeForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberTwo andYOffset:125];
    _checkInTimeNumberFourForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberTwo andYOffset:125];
    
    _behaviorToChange2.frame = [self newLabelLocationWithName:_behaviorToChange2 andYOffset:125];
    _lessOftenNotAtAllLabel2.frame = [self newLabelLocationWithName:_lessOftenNotAtAllLabel2 andYOffset:125];
    
    _lessOftenNotAtAllTwoTimeOne.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeOne andYOffset:125];
    _lessOftenNotAtAllTwoTimeTwo.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeTwo andYOffset:125];
    _lessOftenNotAtAllTwoTimeThree.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeThree andYOffset:125];
    _lessOftenNotAtAllTwoTimeFour.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeFour andYOffset:125];
    
    _thingToDoInsteadOfSecondBehaviorToChange1.frame = [self newLabelLocationWithName:_thingToDoInsteadOfFirstBehaviorToChange1 andYOffset:125];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberThree andYOffset:125];
    _checkInTimeNumberTwoForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberThree andYOffset:125];
    _checkInTimeNumberThreeForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberThree andYOffset:125];
    _checkInTimeNumberFourForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberThree andYOffset:125];
    
    _thingToDoInsteadOfSecondBehaviorToChange2.frame = [self newLabelLocationWithName:_thingToDoInsteadOfSecondBehaviorToChange2 andYOffset:125];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberFour andYOffset:125];
    _checkInTimeNumberTwoForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberFour andYOffset:125];
    _checkInTimeNumberThreeForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberFour andYOffset:125];
    _checkInTimeNumberFourForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberFour andYOffset:125];
}

- (void) adjustLabelsForTwoBTK
{
    _behaviorsToChangeLabel.frame = [self newLabelLocationWithName:_behaviorsToChangeLabel andYOffset:60];
    _behaviorToChange1.frame = [self newLabelLocationWithName:_behaviorToChange1 andYOffset:60];
    _lessOftenNotAtAllLabel1.frame = [self newLabelLocationWithName:_lessOftenNotAtAllLabel1 andYOffset:60];
    _lessOftenNotAtAllOneTimeOne.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeOne andYOffset:60];
    _lessOftenNotAtAllOneTimeTwo.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeTwo andYOffset:60];
    _lessOftenNotAtAllOneTimeThree.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeThree andYOffset:60];
    _lessOftenNotAtAllOneTimeFour.frame = [self newImageLocationWithName:_lessOftenNotAtAllOneTimeFour andYOffset:60];
    
    _thingToDoInsteadOfFirstBehaviorToChange2.frame = [self newLabelLocationWithName:_thingToDoInsteadOfFirstBehaviorToChange2 andYOffset:60];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberOne andYOffset:60];
    _checkInTimeNumberTwoForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberOne andYOffset:60];
    _checkInTimeNumberThreeForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberOne andYOffset:60];
    _checkInTimeNumberFourForThingToDoInsteadNumberOne.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberOne andYOffset:60];
    
    _thingToDoInsteadOfFirstBehaviorToChange1.frame = [self newLabelLocationWithName:_thingToDoInsteadOfFirstBehaviorToChange1 andYOffset:60];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberTwo andYOffset:60];
    _checkInTimeNumberTwoForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberTwo andYOffset:60];
    _checkInTimeNumberThreeForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberTwo andYOffset:60];
    _checkInTimeNumberFourForThingToDoInsteadNumberTwo.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberTwo andYOffset:60];
    
    _behaviorToChange2.frame = [self newLabelLocationWithName:_behaviorToChange2 andYOffset:60];
    _lessOftenNotAtAllLabel2.frame = [self newLabelLocationWithName:_lessOftenNotAtAllLabel2 andYOffset:60];

    _lessOftenNotAtAllTwoTimeOne.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeOne andYOffset:60];
    _lessOftenNotAtAllTwoTimeTwo.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeTwo andYOffset:60];
    _lessOftenNotAtAllTwoTimeThree.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeThree andYOffset:60];
    _lessOftenNotAtAllTwoTimeFour.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeFour andYOffset:60];
 
    _thingToDoInsteadOfSecondBehaviorToChange1.frame = [self newLabelLocationWithName:_thingToDoInsteadOfSecondBehaviorToChange1 andYOffset:60];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberThree andYOffset:60];
    _checkInTimeNumberTwoForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberThree andYOffset:60];
    _checkInTimeNumberThreeForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberThree andYOffset:60];
    _checkInTimeNumberFourForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberThree andYOffset:60];
    
    _thingToDoInsteadOfSecondBehaviorToChange2.frame = [self newLabelLocationWithName:_thingToDoInsteadOfSecondBehaviorToChange2 andYOffset:60];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberFour andYOffset:60];
    _checkInTimeNumberTwoForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberFour andYOffset:60];
    _checkInTimeNumberThreeForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberFour andYOffset:60];
    _checkInTimeNumberFourForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberFour andYOffset:60];
}

- (void) adjustLabelsForOneTTDI
{
    _behaviorToChange2.frame = [self newLabelLocationWithName:_behaviorToChange2 andYOffset:120];
    _lessOftenNotAtAllLabel2.frame = [self newLabelLocationWithName:_lessOftenNotAtAllLabel2 andYOffset:120];
    
    _lessOftenNotAtAllTwoTimeOne.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeOne andYOffset:120];
    _lessOftenNotAtAllTwoTimeTwo.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeTwo andYOffset:120];
    _lessOftenNotAtAllTwoTimeThree.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeThree andYOffset:120];
    _lessOftenNotAtAllTwoTimeFour.frame = [self newImageLocationWithName:_lessOftenNotAtAllTwoTimeFour andYOffset:120];
    
    _checkInTimeNumberOneForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberThree andYOffset:120];
    _checkInTimeNumberTwoForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberThree andYOffset:120];
    _checkInTimeNumberThreeForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberThree andYOffset:120];
    _checkInTimeNumberFourForThingToDoInsteadNumberThree.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberThree andYOffset:120];

    _checkInTimeNumberOneForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberOneForThingToDoInsteadNumberThree andYOffset:120];
    _checkInTimeNumberTwoForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberTwoForThingToDoInsteadNumberThree andYOffset:120];
    _checkInTimeNumberThreeForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberThreeForThingToDoInsteadNumberThree andYOffset:120];
    _checkInTimeNumberFourForThingToDoInsteadNumberFour.frame = [self newImageLocationWithName:_checkInTimeNumberFourForThingToDoInsteadNumberFour andYOffset:120];
}

- (CGRect) newImageLocationWithName:(UIImageView *)name andYOffset:(int)offset
{
    CGRect rect = CGRectMake(name.frame.origin.x, name.frame.origin.y-offset, name.frame.size.width, name.frame.size.height);
    return rect;
}

- (CGRect) newLabelLocationWithName:(UILabel *)name andYOffset:(int)offset
{
    CGRect rect = CGRectMake(name.frame.origin.x, name.frame.origin.y-offset, name.frame.size.width, name.frame.size.height);
    return rect;
}

- (void) setAllLabelsAndValues
{
    // Track today's date for update functions.
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    _currDate = [NSDate date];

    if (_dateFromModal == nil)
    {
        dateString = [dateFormatter stringFromDate:_currDate];
    }
    else
    {
       _currDate = _dateFromModal;
        dateString = [dateFormatter stringFromDate:_dateFromModal];
    }
    _behaviorDataForDateLbl.text = [NSString stringWithFormat:@"Behavior Data For: %@", dateString];

    // Behaviors To Keep (Will return NSString) - for getting the sticker from the DB.
    [self getBehaviorDataFromDB];
    
    // Initialize all the stickers...
    [self initializeBehaviorsToKeep];
    [self initializeBehaviorsToChange];
    [self initializeThingsToDoInstead];
    
    // Set the names of the behaviors and things to do instead...
    [self setRequiredLabelValues];
    
    // Check which variables have been requested for followup by the user.
    [self checkWhichLabelsToDisplay];
    
    // This ensures that the user cannot try to assign a sticker without selecting one first.
    [self setDefaultSticker];
    
    [self updateTokenLabels];
}

- (void) initializeBehaviorsToKeep
{
    //------------ BEHAVIORS TO KEEP -------------
    // Behavior To Keep #1
    if ([behaviorToKeepStatsFromDB count] > 0)
    {
        if (behaviorToKeepStatsFromDB[0][@"time1"] != nil)
        {
            _checkInTimeNumberOneForBehaviorToKeepNumberOne.image = [UIImage imageNamed:behaviorToKeepStatsFromDB[0][@"time1"]];
            tokenStickerSlot[0] = behaviorToKeepStatsFromDB[0][@"time1"];
        }
        if (behaviorToKeepStatsFromDB[0][@"time2"] != nil)
        {
            _checkInTimeNumberTwoForBehaviorToKeepNumberOne.image = [UIImage imageNamed: behaviorToKeepStatsFromDB[0][@"time2"]];
            tokenStickerSlot[1] = behaviorToKeepStatsFromDB[0][@"time2"];
        }
        if (behaviorToKeepStatsFromDB[0][@"time3"] != nil)
        {
            _checkInTimeNumberThreeForBehaviorToKeepNumberOne.image = [UIImage imageNamed:behaviorToKeepStatsFromDB[0][@"time3"]];
            tokenStickerSlot[2] = behaviorToKeepStatsFromDB[0][@"time3"];
        }
        if (behaviorToKeepStatsFromDB[0][@"time4"] != nil)
        {
            _checkInTimeNumberFourForBehaviorToKeepNumberOne.image = [UIImage imageNamed:behaviorToKeepStatsFromDB[0][@"time4"]];
            tokenStickerSlot[3] = behaviorToKeepStatsFromDB[0][@"time4"];
        }
    }
    
    // Behavior To Keep #2
    if ([behaviorToKeepStatsFromDB count] > 1)
    {
        if (behaviorToKeepStatsFromDB[1][@"time1"] != nil)
        {
            _checkInTimeNumberOneForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:behaviorToKeepStatsFromDB[1][@"time1"]];
            tokenStickerSlot[4] = behaviorToKeepStatsFromDB[1][@"time1"];
        }
        if (behaviorToKeepStatsFromDB[1][@"time2"] != nil)
        {
            _checkInTimeNumberTwoForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:behaviorToKeepStatsFromDB[1][@"time2"]];
            tokenStickerSlot[5] = behaviorToKeepStatsFromDB[1][@"time2"];
        }
        if (behaviorToKeepStatsFromDB[1][@"time3"] != nil)
        {
            _checkInTimeNumberThreeForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:behaviorToKeepStatsFromDB[1][@"time3"]];
            tokenStickerSlot[6] = behaviorToKeepStatsFromDB[1][@"time3"];
        }
        if (behaviorToKeepStatsFromDB[1][@"time4"] != nil)
        {
            _checkInTimeNumberFourForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:behaviorToKeepStatsFromDB[1][@"time4"]];
            tokenStickerSlot[7] = behaviorToKeepStatsFromDB[1][@"time4"];
        }
    }
    
    // Behavior To Keep #3
    if ([behaviorToKeepStatsFromDB count] > 2)
    {
        if (behaviorToKeepStatsFromDB[2][@"time1"] != nil)
        {
            _checkInTimeNumberOneForBehaviorToKeepNumberThree.image = [UIImage imageNamed: behaviorToKeepStatsFromDB[2][@"time1"]];
            tokenStickerSlot[8] = behaviorToKeepStatsFromDB[2][@"time1"];
        }
        if (behaviorToKeepStatsFromDB[2][@"time1"] != nil)
        {
            _checkInTimeNumberTwoForBehaviorToKeepNumberThree.image = [UIImage imageNamed: behaviorToKeepStatsFromDB[2][@"time2"]];
            tokenStickerSlot[9] = behaviorToKeepStatsFromDB[2][@"time2"];
        }
        if (behaviorToKeepStatsFromDB[2][@"time1"] != nil)
        {
            _checkInTimeNumberThreeForBehaviorToKeepNumberThree.image = [UIImage imageNamed: behaviorToKeepStatsFromDB[2][@"time3"]];
            tokenStickerSlot[10] = behaviorToKeepStatsFromDB[2][@"time3"];
        }
        if (behaviorToKeepStatsFromDB[2][@"time1"] != nil)
        {
            _checkInTimeNumberFourForBehaviorToKeepNumberThree.image = [UIImage imageNamed: behaviorToKeepStatsFromDB[2][@"time4"]];
            tokenStickerSlot[11] = behaviorToKeepStatsFromDB[2][@"time4"];
        }
    }
}

- (void)initializeBehaviorsToChange
{
    //-------LESS OFTEN/NOT AT ALL-------------
    if ([behaviorToChangeStatsFromDB count] > 0)
    {
        if (behaviorToChangeStatsFromDB[0][@"time1"] != nil)
        {
        _lessOftenNotAtAllOneTimeOne.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[0][@"time1"]];
        tokenStickerSlot[28] = behaviorToChangeStatsFromDB[0][@"time1"];
        }
        if (behaviorToChangeStatsFromDB[0][@"time2"] != nil)
        {
        _lessOftenNotAtAllOneTimeTwo.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[0][@"time2"]];
        tokenStickerSlot[29] = behaviorToChangeStatsFromDB[0][@"time2"];
        }
        if (behaviorToChangeStatsFromDB[0][@"time3"] != nil)
        {
            _lessOftenNotAtAllOneTimeThree.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[0][@"time3"]];
            tokenStickerSlot[30] = behaviorToChangeStatsFromDB[0][@"time3"];
        }
        if (behaviorToChangeStatsFromDB[0][@"time4"] != nil)
        {
            _lessOftenNotAtAllOneTimeFour.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[0][@"time4"]];
            tokenStickerSlot[31] = behaviorToChangeStatsFromDB[0][@"time4"];
        }
    }
    
    if ([behaviorToChangeStatsFromDB count] > 3)
    {
        if (behaviorToChangeStatsFromDB[3][@"time1"] != nil)
        {
            _lessOftenNotAtAllTwoTimeOne.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[3][@"time1"]];
            tokenStickerSlot[32] = behaviorToChangeStatsFromDB[3][@"time1"];
        }
        if (behaviorToChangeStatsFromDB[3][@"time2"] != nil)
        {
            _lessOftenNotAtAllTwoTimeTwo.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[3][@"time2"]];
            tokenStickerSlot[33] = behaviorToChangeStatsFromDB[3][@"time2"];
        }
        if (behaviorToChangeStatsFromDB[3][@"time3"] != nil)
        {
            _lessOftenNotAtAllTwoTimeThree.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[3][@"time3"]];
            tokenStickerSlot[34] = behaviorToChangeStatsFromDB[3][@"time3"];
        }
        if (behaviorToChangeStatsFromDB[3][@"time4"] != nil)
        {
            _lessOftenNotAtAllTwoTimeFour.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[3][@"time4"]];
            tokenStickerSlot[35] = behaviorToChangeStatsFromDB[3][@"time4"];
        }
    }
}

- (void)initializeThingsToDoInstead
{
    //--------THINGS TO DO INSTEAD-------------
    // Things to Do Instead #1
    if ([behaviorToChangeStatsFromDB[1] count] > 1)
    {
        if (behaviorToChangeStatsFromDB[1][@"time1"] != nil)
        {
            _checkInTimeNumberOneForThingToDoInsteadNumberOne.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[1][@"time1"]];
            tokenStickerSlot[12] = behaviorToChangeStatsFromDB[1][@"time1"];
        }
        if (behaviorToChangeStatsFromDB[1][@"time2"] != nil)
        {
            _checkInTimeNumberTwoForThingToDoInsteadNumberOne.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[1][@"time2"]];
            tokenStickerSlot[13] = behaviorToChangeStatsFromDB[1][@"time2"];
        }
        if (behaviorToChangeStatsFromDB[1][@"time3"] != nil)
        {
            _checkInTimeNumberThreeForThingToDoInsteadNumberOne.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[1][@"time3"]];
            tokenStickerSlot[14] = behaviorToChangeStatsFromDB[1][@"time3"];
        }
        if (behaviorToChangeStatsFromDB[1][@"time4"] != nil)
        {
            _checkInTimeNumberFourForThingToDoInsteadNumberOne.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[1][@"time4"]];
            tokenStickerSlot[15] = behaviorToChangeStatsFromDB[1][@"time4"];
        }
    }
    
    // Things to Do Instead #2
    if ([behaviorToChangeStatsFromDB count] > 2)
    {
        if (behaviorToChangeStatsFromDB[2][@"time1"] != nil)
        {
            _checkInTimeNumberOneForThingToDoInsteadNumberTwo.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[2][@"time1"]];
            tokenStickerSlot[16] = behaviorToChangeStatsFromDB[2][@"time1"];
        }
        if (behaviorToChangeStatsFromDB[2][@"time2"] != nil)
        {
            _checkInTimeNumberTwoForThingToDoInsteadNumberTwo.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[2][@"time2"]];
            tokenStickerSlot[17] = behaviorToChangeStatsFromDB[2][@"time2"];
        }
        if (behaviorToChangeStatsFromDB[2][@"time3"] != nil)
        {
            _checkInTimeNumberThreeForThingToDoInsteadNumberTwo.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[2][@"time3"]];
            tokenStickerSlot[18] = behaviorToChangeStatsFromDB[2][@"time3"];
        }
        if (behaviorToChangeStatsFromDB[2][@"time4"] != nil)
        {
            _checkInTimeNumberFourForThingToDoInsteadNumberTwo.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[2][@"time4"]];
            tokenStickerSlot[19] = behaviorToChangeStatsFromDB[2][@"time4"];
        }
    }

    // Things to Do Instead #3
    if ([behaviorToChangeStatsFromDB count] > 4)
    {
        if (behaviorToChangeStatsFromDB[4][@"time1"] != nil)
        {
            _checkInTimeNumberOneForThingToDoInsteadNumberThree.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[4][@"time1"]];
            tokenStickerSlot[20] = behaviorToChangeStatsFromDB[4][@"time1"];
        }
        if (behaviorToChangeStatsFromDB[4][@"time2"] != nil)
        {
            _checkInTimeNumberTwoForThingToDoInsteadNumberThree.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[4][@"time2"]];
            tokenStickerSlot[21] = behaviorToChangeStatsFromDB[4][@"time2"];
        }
        if (behaviorToChangeStatsFromDB[4][@"time3"] != nil)
        {
            _checkInTimeNumberThreeForThingToDoInsteadNumberThree.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[4][@"time3"]];
            tokenStickerSlot[22] = behaviorToChangeStatsFromDB[4][@"time3"];
        }
        if (behaviorToChangeStatsFromDB[4][@"time4"] != nil)
        {
            _checkInTimeNumberFourForThingToDoInsteadNumberThree.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[4][@"time4"]];
            tokenStickerSlot[23] = behaviorToChangeStatsFromDB[4][@"time4"];
        }
    }
    
    // Things to Do Instead #4
    if ([behaviorToChangeStatsFromDB count] > 5)
    {
        if (behaviorToChangeStatsFromDB[5][@"time1"] != nil)
        {
            _checkInTimeNumberOneForThingToDoInsteadNumberFour.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[5][@"time1"]];
            tokenStickerSlot[24] = behaviorToChangeStatsFromDB[5][@"time1"];
        }
        if (behaviorToChangeStatsFromDB[5][@"time2"] != nil)
        {
            _checkInTimeNumberTwoForThingToDoInsteadNumberFour.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[5][@"time2"]];
            tokenStickerSlot[25] = behaviorToChangeStatsFromDB[5][@"time2"];
        }
        if (behaviorToChangeStatsFromDB[5][@"time3"] != nil)
        {
            _checkInTimeNumberThreeForThingToDoInsteadNumberFour.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[5][@"time3"]];
            tokenStickerSlot[26] = behaviorToChangeStatsFromDB[5][@"time3"];
        }
        if (behaviorToChangeStatsFromDB[5][@"time4"] != nil)
        {
            _checkInTimeNumberFourForThingToDoInsteadNumberFour.image = [UIImage imageNamed: behaviorToChangeStatsFromDB[5][@"time4"]];
            tokenStickerSlot[27] = behaviorToChangeStatsFromDB[5][@"time4"];
        }
    }
}

- (void) setDefaultSticker
{
    // Highlight default sticker.
    _stickerOne.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerOne.layer.borderWidth = 1.0f;
}

- (void)initializeScrollView
{
    _myScrollView.scrollEnabled = YES;
    _myScrollView.contentSize = CGSizeMake(320,600);
    _stickerScrollView.scrollEnabled = YES;
    _stickerScrollView.contentSize = CGSizeMake(500,50);
}

- (void)setFonts
{
    _thingToDoInsteadOfFirstBehaviorToChange1.font = [UIFont fontWithName:@"Helvetica Neue Light Italic" size:17];
    _thingToDoInsteadOfFirstBehaviorToChange2 .font = [UIFont fontWithName:@"Helvetica Neue Light Italic" size:17];
    _thingToDoInsteadOfSecondBehaviorToChange1.font = [UIFont fontWithName:@"Helvetica Neue Light Italic" size:17];
    _thingToDoInsteadOfSecondBehaviorToChange2.font = [UIFont fontWithName:@"Helvetica Neue Light Italic" size:17];
}

- (void)getBehaviorDataFromDB
{
    behaviorToKeepStatsFromDB = [function getTrackGoodBehaviorsWhen:dateString];
    behaviorToChangeStatsFromDB = [function getTrackThingsToDoInsteadWhen:dateString];
    checkInTimes = [notebook getBehaviorsCheckinTime];
}

- (void)updateTokenLabels
{
    _tokenBalanceLbl.text = [NSString stringWithFormat:@"%ld", currentTokenBalance];
    _dailyTokensLbl.text = [NSString stringWithFormat:@"%ld", tokensEarnedToday];
}

- (void) setRequiredLabelValues
{
    _behaviorToKeep1.text = [behaviorToKeepStatsFromDB[0][@"bhname"] capitalizedString];
    _behaviorToChange1.text = [behaviorToChangeStatsFromDB[0][@"badBehavior_name"] capitalizedString];
    _thingToDoInsteadOfFirstBehaviorToChange1.text = [behaviorToChangeStatsFromDB[1][@"bhname"] capitalizedString];
}

- (void) checkWhichLabelsToDisplay
{
    // Some of these may be or may not be null. Need to add checks to know which labels should be visible or hidden, and also which labels to update with data or not.
    if ([behaviorToKeepStatsFromDB count] > 1)
    {
        _behaviorToKeep2.text = [behaviorToKeepStatsFromDB[1][@"bhname"] capitalizedString];
        _behaviorToKeep2.hidden = NO;
    }
    if ([behaviorToKeepStatsFromDB count] > 2)
    {
        _behaviorToKeep3.text = [behaviorToKeepStatsFromDB[2][@"bhname"] capitalizedString];
        _behaviorToKeep3.hidden = NO;
    }
    
    // Check optional things to do instead #2 for behavior to change #1.
    if ([behaviorToChangeStatsFromDB count] > 2) {
        if ([behaviorToChangeStatsFromDB[1][@"badBehavior_name"] isEqualToString:behaviorToChangeStatsFromDB[1][@"badBehavior_name"]]) {
            _thingToDoInsteadOfFirstBehaviorToChange2.text = [behaviorToChangeStatsFromDB[2][@"bhname"] capitalizedString];
            _thingToDoInsteadOfFirstBehaviorToChange2.hidden = NO;
            if ([behaviorToChangeStatsFromDB count] > 3) {
                _behaviorToChange2.text = behaviorToChangeStatsFromDB[3][@"badBehavior_name"];
                _behaviorToChange2.hidden = NO;
                _lessOftenNotAtAllTwoTimeOne.hidden = NO;
                _checkInTimeNumberOneForThingToDoInsteadNumberThree.hidden = NO;
                _checkInTimeNumberOneForThingToDoInsteadNumberFour.hidden = NO;
                if ([behaviorToChangeStatsFromDB count] > 4) {
                    _thingToDoInsteadOfSecondBehaviorToChange1.text = [behaviorToChangeStatsFromDB[4][@"bhname"] capitalizedString];
                    _thingToDoInsteadOfSecondBehaviorToChange1.hidden = NO;
                }
                if ([behaviorToChangeStatsFromDB count] > 5) {
                    _thingToDoInsteadOfSecondBehaviorToChange2.text = [behaviorToChangeStatsFromDB[5][@"bhname"] capitalizedString];
                    _thingToDoInsteadOfSecondBehaviorToChange2.hidden = NO;
                }
                _behaviorToChange2.hidden = NO;
                _lessOftenNotAtAllLabel2.hidden = NO;
            }
        }
        else {
            _behaviorToChange2.text = behaviorToChangeStatsFromDB[1][@"badBehavior_name"];
            _behaviorToChange2.hidden = NO;
            _thingToDoInsteadOfSecondBehaviorToChange1.text = [behaviorToChangeStatsFromDB[1][@"bhname"] capitalizedString];
            _thingToDoInsteadOfSecondBehaviorToChange1.hidden = NO;
            if ([behaviorToChangeStatsFromDB count] > 2) {
                _thingToDoInsteadOfSecondBehaviorToChange2.text = [behaviorToChangeStatsFromDB[2][@"bhname"] capitalizedString];
                _thingToDoInsteadOfSecondBehaviorToChange2.hidden = NO;
            }
        }
    }
    switch ([checkInTimes count])
    {
        case 4:
            [self showTime:4];
        case 3:
            [self showTime:3];
        case 2:
        {
            [self showTime:2];
            break;
        }
    }
    if (_behaviorToKeep2.hidden == YES)
        [self adjustLabelsForOneBTK];
    else if (_behaviorToKeep3.hidden == YES)
    {
        [self adjustLabelsForTwoBTK];
        _checkInTimeNumberOneForBehaviorToKeepNumberThree.hidden = YES;
        _checkInTimeNumberTwoForBehaviorToKeepNumberThree.hidden = YES;
    }
    if (_thingToDoInsteadOfFirstBehaviorToChange2.hidden == YES)
        [self adjustLabelsForOneTTDI];
}

- (void) showTime:(int)time
{
    if (time == 2)
    {
        _checkInTimeNumberTwoForBehaviorToKeepNumberOne.hidden = NO;
        _checkInTimeNumberOneForBehaviorToKeepNumberTwo.hidden = NO;
        _checkInTimeNumberTwoForBehaviorToKeepNumberTwo.hidden = NO;
        _checkInTimeNumberOneForBehaviorToKeepNumberThree.hidden = NO;
        _checkInTimeNumberTwoForBehaviorToKeepNumberThree.hidden = NO;
        _checkInTimeNumberTwoForThingToDoInsteadNumberOne.hidden = NO;
        _checkInTimeNumberOneForThingToDoInsteadNumberTwo.hidden = NO;
        _checkInTimeNumberTwoForThingToDoInsteadNumberTwo.hidden = NO;
        _checkInTimeNumberTwoForThingToDoInsteadNumberThree.hidden = NO;
        _checkInTimeNumberTwoForThingToDoInsteadNumberFour.hidden = NO;
        _lessOftenNotAtAllOneTimeTwo.hidden = NO;
        _lessOftenNotAtAllTwoTimeTwo.hidden = NO;
    }
    else if (time == 3)
    {
        _checkInTimeNumberThreeForBehaviorToKeepNumberOne.hidden = NO;
        _checkInTimeNumberThreeForBehaviorToKeepNumberTwo.hidden = NO;
        _checkInTimeNumberThreeForBehaviorToKeepNumberThree.hidden = NO;
        _checkInTimeNumberThreeForThingToDoInsteadNumberOne.hidden = NO;
        _checkInTimeNumberThreeForThingToDoInsteadNumberTwo.hidden = NO;
        _checkInTimeNumberThreeForThingToDoInsteadNumberThree.hidden = NO;
        _checkInTimeNumberThreeForThingToDoInsteadNumberFour.hidden = NO;
        _lessOftenNotAtAllOneTimeThree.hidden = NO;
        _lessOftenNotAtAllTwoTimeThree.hidden = NO;
    }
    else if (time == 4)
    {
        _checkInTimeNumberFourForBehaviorToKeepNumberOne.hidden = NO;
        _checkInTimeNumberFourForBehaviorToKeepNumberTwo.hidden = NO;
        _checkInTimeNumberFourForBehaviorToKeepNumberThree.hidden = NO;
        _checkInTimeNumberFourForThingToDoInsteadNumberOne.hidden = NO;
        _checkInTimeNumberFourForThingToDoInsteadNumberTwo.hidden = NO;
        _checkInTimeNumberFourForThingToDoInsteadNumberThree.hidden = NO;
        _checkInTimeNumberFourForThingToDoInsteadNumberFour.hidden = NO;
        _lessOftenNotAtAllOneTimeFour.hidden = NO;
        _lessOftenNotAtAllTwoTimeFour.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The selector for what to do when a tabBarItem is selected.
- (void)tabClicked:(long)index {
    switch (index) {
        case 1:
        {
            [self shouldPerformSegueWithIdentifier:@"behaviorsListSegue" sender:self];
            break;
        }
        case 2:
        {
            [self shouldPerformSegueWithIdentifier:@"rewardsSegue" sender:self];
            break;
        }
        case 3:
        {
            [self shouldPerformSegueWithIdentifier:@"infoViewSegue" sender:self];
            break;
        }
        case 4:
        {
            [self shouldPerformSegueWithIdentifier:@"notebookSettingsSegue" sender:self];
            break;
        }
        default:
            break;
    }
}
// Called automatically when a tabBarItem is selected.
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)tabItem {
    NSLog(@"didSelectItem: %ld", (long)tabItem.tag);
    [self tabClicked:tabItem.tag];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

- (void) noStickerChosen
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No sticker chosen"
                                                    message:@"Please choose a sticker first."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) clearBorders
{
    _stickerOne.layer.borderColor = [[UIColor clearColor]CGColor];
    _stickerTwo.layer.borderColor = [[UIColor clearColor]CGColor];
    _stickerThree.layer.borderColor = [[UIColor clearColor]CGColor];
    _stickerFour.layer.borderColor = [[UIColor clearColor]CGColor];
    _stickerFive.layer.borderColor = [[UIColor clearColor]CGColor];
    _stickerSix.layer.borderColor = [[UIColor clearColor]CGColor];
    _stickerSeven.layer.borderColor = [[UIColor clearColor]CGColor];
    _stickerEight.layer.borderColor = [[UIColor clearColor]CGColor];
}

- (IBAction) stickerOneTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerOne.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerOne.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker01.png";
}

- (IBAction) stickerTwoTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerTwo.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerTwo.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker02.png";
}

- (IBAction) stickerThreeTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerThree.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerThree.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker03.png";
}

- (IBAction) stickerFourTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerFour.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerFour.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker04.png";
}

- (IBAction) stickerFiveTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerFive.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerFive.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker05.png";
}

- (IBAction) stickerSixTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerSix.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerSix.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker06.png";
}

- (IBAction) stickerSevenTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerSeven.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerSeven.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker07.png";
}

- (IBAction) stickerEightTapped:(UITapGestureRecognizer *)sender
{
    [self clearBorders];
    _stickerEight.layer.borderColor = [[UIColor blackColor]CGColor];
    _stickerEight.layer.borderWidth = 1.0f;
    stickerToPlace = @"sticker08.png";
}

- (void) updateDBWithBehaviorToKeepNumber:(int)behaviorNumber
{
    // tokenStickerSlot will hold the name of the sticker...
    int offset = 4*(behaviorNumber-1);
    // This is calling the DB function...
    [function setTrackGoodBehaviorWithTime:dateString
                         andGoodBehaviorid:behaviorToKeepStatsFromDB[behaviorNumber-1][@"id"]
                                  andTime1:tokenStickerSlot[0+offset]
                                  andTime2:tokenStickerSlot[1+offset]
                                  andTime3:tokenStickerSlot[2+offset]
                                  andTime4:tokenStickerSlot[3+offset]];
    [self updateTokenLabels];
}

- (void) updateDBWithThingToDoInstead:(int)index
{
    int offset = 0;
    int num = 1;
    if (index == 2)
        offset = 4;
    else if (index == 3)
        offset = 8;
    else if (index == 4)
        offset = 12;
    else    // Acts as catch-all in case of corner case...
        return;
    [function setTrackChangeBehaviorWithTime:dateString
                         andChangeBehaviorId:behaviorToChangeStatsFromDB[num][@"id"]
                                    andTime1:tokenStickerSlot[offset+12]
                                    andTime2:tokenStickerSlot[offset+13]
                                    andTime3:tokenStickerSlot[offset+14]
                                    andTime4:tokenStickerSlot[offset+15]];
    [self updateTokenLabels];
}

- (void) updateDBWithLessOftenOrNotAtAll:(int)num
{
    int offset = 0;
    if (num == 1)
        num = 0;    // Set to 0 to be consistent with array.
    if (num == 2)
    {
        num = 3;    // Set to 3 to be consistent with array.
        offset = 4;
    }
    [function setTrackChangeBehaviorWithTime:dateString
                         andChangeBehaviorId:behaviorToChangeStatsFromDB[num][@"id"]
                                    andTime1:tokenStickerSlot[offset+28]
                                    andTime2:tokenStickerSlot[offset+29]
                                    andTime3:tokenStickerSlot[offset+30]
                                    andTime4:tokenStickerSlot[offset+31]];
}

- (void) updateImage:(UIImageView *)img
{
    img.image = [UIImage imageNamed:@"no-sticker-100px.png"];
    toggleFlag = false;
}

- (void) processStickerAddedWithEntryNumber:(int)arrayEntryNumber andBehaviorToKeep:(int)behaviorToKeepNumber
{
    if (stickerToPlace == nil)
    {
        [self noStickerChosen];
        return;
    }
    if ([tokenStickerSlot[arrayEntryNumber] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
        {
            [notebook updateTokenBalanceWith:1];
            currentTokenBalance++;
            tokensEarnedToday++;
            [self updateTokenLabels];
        }
    else
        toggleFlag = true;
    tokenStickerSlot[arrayEntryNumber] = stickerToPlace;
    [self updateDBWithBehaviorToKeepNumber:behaviorToKeepNumber];
}

- (void) processStickerAddedWithEntryNumber:(int)arrayEntryNumber andThingToDoInstead:(int)thingsToDoInsteadNumber andBehaviorToChange:(int)behaviorToChangeNumber andCheckIn:(UIImageView*)checkIn
{
    if (stickerToPlace == nil)
    {
        [self noStickerChosen];
        return;
    }
    checkIn.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[arrayEntryNumber] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10){
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[arrayEntryNumber] = stickerToPlace;
    if (thingsToDoInsteadNumber == 1)
        [self updateDBWithThingToDoInstead:1];
    else if (thingsToDoInsteadNumber == 2)
        [self updateDBWithThingToDoInstead:2];
    else if (thingsToDoInsteadNumber == 3)
        [self updateDBWithThingToDoInstead:3];
    else if (thingsToDoInsteadNumber == 4)
        [self updateDBWithThingToDoInstead:4];
}

- (IBAction)behaviorToKeepOneTimeOneTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberOneForBehaviorToKeepNumberOne.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:0 andBehaviorToKeep:1];
    if (toggleFlag == true)
        [self updateImage:_checkInTimeNumberOneForBehaviorToKeepNumberOne];
}

- (IBAction)behaviorToKeepOneTimeTwoTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberTwoForBehaviorToKeepNumberOne.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:1 andBehaviorToKeep:1];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberTwoForBehaviorToKeepNumberOne];
}

- (IBAction)behaviorToKeepOneTimeThreeTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberThreeForBehaviorToKeepNumberOne.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:2 andBehaviorToKeep:1];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberThreeForBehaviorToKeepNumberOne];
}

- (IBAction)behaviorToKeepOneTimeFourTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberFourForBehaviorToKeepNumberOne.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:3 andBehaviorToKeep:1];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberFourForBehaviorToKeepNumberOne];
}

- (IBAction)behaviorToKeepTwoTimeOneTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberOneForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:4 andBehaviorToKeep:2];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberOneForBehaviorToKeepNumberTwo];
}

- (IBAction)behaviorToKeepTwoTimeTwoTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberTwoForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:5 andBehaviorToKeep:2];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberTwoForBehaviorToKeepNumberTwo];
}

- (IBAction)behaviorToKeepTwoTimeThreeTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberThreeForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:6 andBehaviorToKeep:2];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberThreeForBehaviorToKeepNumberTwo];
}

- (IBAction)behaviorToKeepTwoTimeFourTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberFourForBehaviorToKeepNumberTwo.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:7 andBehaviorToKeep:2];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberFourForBehaviorToKeepNumberTwo];
}

- (IBAction)behaviorToKeepThreeTimeOneTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberOneForBehaviorToKeepNumberThree.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:8 andBehaviorToKeep:3];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberOneForBehaviorToKeepNumberThree];
}

- (IBAction)behaviorToKeepThreeTimeTwoTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberTwoForBehaviorToKeepNumberThree.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:9 andBehaviorToKeep:3];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberTwoForBehaviorToKeepNumberThree];
}

- (IBAction)behaviorToKeepThreeTimeThreeTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberThreeForBehaviorToKeepNumberThree.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:10 andBehaviorToKeep:3];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberThreeForBehaviorToKeepNumberThree];
}

- (IBAction)behaviorToKeepThreeTimeFourTapped:(UITapGestureRecognizer *)sender
{
    _checkInTimeNumberFourForBehaviorToKeepNumberThree.image = [UIImage imageNamed:stickerToPlace];
    [self processStickerAddedWithEntryNumber:11 andBehaviorToKeep:3];
    if (toggleFlag == true)
        [self updateImage: _checkInTimeNumberFourForBehaviorToKeepNumberThree];
}

- (IBAction)thingsToDoInsteadOneTimeOneTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:12 andThingToDoInstead:1 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberOneForThingToDoInsteadNumberOne];
}

- (IBAction)thingsToDoInsteadOneTimeTwoTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:13 andThingToDoInstead:1 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberTwoForThingToDoInsteadNumberOne];
}

- (IBAction)thingsToDoInsteadOneTimeThreeTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:14 andThingToDoInstead:1 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberThreeForThingToDoInsteadNumberOne];
}

- (IBAction)thingsToDoInsteadOneTimeFourTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:15 andThingToDoInstead:1 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberFourForThingToDoInsteadNumberOne];
}

- (IBAction)saveBtnClick:(id)sender {
    [self shouldPerformSegueWithIdentifier:@"chooseDateSegue" sender:self];
}

- (IBAction)thingsToDoInsteadTwoTimeOneTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:16 andThingToDoInstead:2 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberOneForThingToDoInsteadNumberTwo];
}

- (IBAction)thingsToDoInsteadTwoTimeTwoTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:17 andThingToDoInstead:2 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberTwoForThingToDoInsteadNumberTwo];
}

- (IBAction)thingsToDoInsteadTwoTimeThreeTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:18 andThingToDoInstead:2 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberThreeForThingToDoInsteadNumberTwo];
}

- (IBAction)thingsToDoInsteadTwoTimeFourTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:19 andThingToDoInstead:2 andBehaviorToChange:1 andCheckIn:_checkInTimeNumberFourForThingToDoInsteadNumberTwo];
}

- (IBAction)thingsToDoInsteadThreeTimeOneTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:20 andThingToDoInstead:3 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberOneForThingToDoInsteadNumberThree];
}

- (IBAction)thingsToDoInsteadThreeTimeTwoTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:21 andThingToDoInstead:3 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberTwoForThingToDoInsteadNumberThree];
}

- (IBAction)thingsToDoInsteadThreeTimeThreeTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:22 andThingToDoInstead:3 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberThreeForThingToDoInsteadNumberThree];
}

- (IBAction)thingsToDoInsteadThreeTimeFourTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:23 andThingToDoInstead:3 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberFourForThingToDoInsteadNumberThree];
}

- (IBAction)thingsToDoInsteadFourTimeOneTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:24 andThingToDoInstead:4 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberOneForThingToDoInsteadNumberFour];
}

- (IBAction)thingsToDoInsteadFourTimeTwoTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:25 andThingToDoInstead:4 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberTwoForThingToDoInsteadNumberFour];
}

- (IBAction)thingsToDoInsteadFourTimeThreeTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:26 andThingToDoInstead:4 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberThreeForThingToDoInsteadNumberFour];
}

- (IBAction)thingsToDoInsteadFourTimeFourTapped:(UITapGestureRecognizer *)sender
{
    [self processStickerAddedWithEntryNumber:27 andThingToDoInstead:4 andBehaviorToChange:2 andCheckIn:_checkInTimeNumberFourForThingToDoInsteadNumberFour];
}

// Less often or not at all
- (IBAction)lessOftenNotAtAllOneTimeOneTapped:(id)sender {
    _lessOftenNotAtAllOneTimeOne.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[28] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
    {
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[28] = stickerToPlace;
    [self updateDBWithLessOftenOrNotAtAll:1];
}

- (IBAction)lessOftenNotAtAllOneTimeTwoTapped:(id)sender {
    _lessOftenNotAtAllOneTimeTwo.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[29] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
    {
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[29] = stickerToPlace;
    [self updateDBWithLessOftenOrNotAtAll:1];
}

- (IBAction)lessOftenNotAtAllOneTimeThreeTapped:(id)sender {
    _lessOftenNotAtAllOneTimeThree.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[30] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
    {
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[30] = stickerToPlace;
    [self updateDBWithLessOftenOrNotAtAll:1];
}

- (IBAction)lessOftenNotAtAllOneTimeFourTapped:(id)sender {
    _lessOftenNotAtAllOneTimeFour.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[31] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
    {
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[31] = stickerToPlace;
    [self updateDBWithLessOftenOrNotAtAll:1];
}

- (IBAction)lessOftenNotAtAllTwoTimeOneTapped:(id)sender {
    _lessOftenNotAtAllTwoTimeOne.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[32] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
    {
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[32] = stickerToPlace;
    [self updateDBWithLessOftenOrNotAtAll:2];
}

- (IBAction)lessOftenNotAtAllTwoTimeTwoTapped:(id)sender
{
    _lessOftenNotAtAllTwoTimeTwo.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[33] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
    {
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[33] = stickerToPlace;
    [self updateDBWithLessOftenOrNotAtAll:2];
}

- (IBAction)lessOftenNotAtAllTwoTimeThreeTapped:(id)sender
{
    _lessOftenNotAtAllTwoTimeThree.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[34] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
        [notebook updateTokenBalanceWith:1];
    {
        tokenStickerSlot[34] = stickerToPlace;
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    [self updateDBWithLessOftenOrNotAtAll:2];
}

- (IBAction)lessOftenNotAtAllTwoTimeFourTapped:(id)sender {
    _lessOftenNotAtAllTwoTimeFour.image = [UIImage imageNamed:stickerToPlace];
    if ([tokenStickerSlot[35] isEqualToString:@"no-sticker-100px.png"] && tokensEarnedToday < 10)
    {
        [notebook updateTokenBalanceWith:1];
        currentTokenBalance++;
        tokensEarnedToday++;
        [self updateTokenLabels];
    }
    tokenStickerSlot[35] = stickerToPlace;
    [self updateDBWithLessOftenOrNotAtAll:2];
}

- (IBAction)pickDateClk:(id)sender {
    // If you want to uncoment this code, you need to make modifications in the
    // PickBehaviorDateToLoadViewController to use this view controller. -- Basem
    /*
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PickBehaviorDateToLoadViewController *modalView = [storyboard instantiateViewControllerWithIdentifier:@"pickDateForBehaviorTracking"];
    modalView.parent = self;
    [self presentViewController:modalView animated:YES completion:nil];
     */
}

- (void) setDate:(NSDate*) date {
    _dateFromModal = date;
    NSString *dateReceived;
    dateReceived = [dateFormatter stringFromDate:_dateFromModal];
    NSLog(@"Date from modal: %@", dateReceived);
    [self setAllLabelsAndValues];
}

- (IBAction)goBackToNotebooksBtn:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end