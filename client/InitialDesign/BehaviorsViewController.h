//
//  BehaviorsViewController.h
//  Parenting+
//
//  Created by Sean Walsh on 1/6/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface BehaviorsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITabBarItem *notebookSettingsItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *infoItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *rewardsItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *behaviorsItem;

@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *stickerScrollView;

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UILabel *behaviorToKeep1;
@property (weak, nonatomic) IBOutlet UILabel *behaviorToKeep2;
@property (weak, nonatomic) IBOutlet UILabel *behaviorToKeep3;
@property (weak, nonatomic) IBOutlet UILabel *behaviorToChange1;
@property (weak, nonatomic) IBOutlet UILabel *behaviorToChange2;
@property (strong, nonatomic) IBOutlet UILabel *behaviorsToChangeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lessOftenNotAtAllLabel1;
@property (strong, nonatomic) IBOutlet UILabel *lessOftenNotAtAllLabel2;

@property (weak, nonatomic) IBOutlet UILabel *thingToDoInsteadOfFirstBehaviorToChange1;
@property (weak, nonatomic) IBOutlet UILabel *thingToDoInsteadOfFirstBehaviorToChange2;
@property (weak, nonatomic) IBOutlet UILabel *thingToDoInsteadOfSecondBehaviorToChange1;
@property (weak, nonatomic) IBOutlet UILabel *thingToDoInsteadOfSecondBehaviorToChange2;

@property (nonatomic, setter = setDate:) NSDate *dateFromModal;

@property (strong, nonatomic) IBOutlet UILabel *behaviorDataForDateLbl;

- (void) setDate:(NSDate *) date;

@property (strong, nonatomic) NoteBooks *notebook;

// Behavior to Keep #1
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberOneForBehaviorToKeepNumberOne;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberTwoForBehaviorToKeepNumberOne;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberThreeForBehaviorToKeepNumberOne;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberFourForBehaviorToKeepNumberOne;

// Behavior to Keep #2
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberOneForBehaviorToKeepNumberTwo;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberTwoForBehaviorToKeepNumberTwo;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberThreeForBehaviorToKeepNumberTwo;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberFourForBehaviorToKeepNumberTwo;

// Behavior to Keep #3
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberOneForBehaviorToKeepNumberThree;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberTwoForBehaviorToKeepNumberThree;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberThreeForBehaviorToKeepNumberThree;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberFourForBehaviorToKeepNumberThree;

// Things to do Instead #1
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberOneForThingToDoInsteadNumberOne;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberTwoForThingToDoInsteadNumberOne;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberThreeForThingToDoInsteadNumberOne;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberFourForThingToDoInsteadNumberOne;

// Things to do Instead #2
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberOneForThingToDoInsteadNumberTwo;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberTwoForThingToDoInsteadNumberTwo;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberThreeForThingToDoInsteadNumberTwo;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberFourForThingToDoInsteadNumberTwo;

// Things to do Instead #3
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberOneForThingToDoInsteadNumberThree;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberTwoForThingToDoInsteadNumberThree;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberThreeForThingToDoInsteadNumberThree;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberFourForThingToDoInsteadNumberThree;

// Things to do Instead #4
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberOneForThingToDoInsteadNumberFour;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberTwoForThingToDoInsteadNumberFour;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberThreeForThingToDoInsteadNumberFour;
@property (weak, nonatomic) IBOutlet UIImageView *checkInTimeNumberFourForThingToDoInsteadNumberFour;

@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllOneTimeOne;
@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllOneTimeTwo;
@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllOneTimeThree;
@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllOneTimeFour;

@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllTwoTimeOne;
@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllTwoTimeTwo;
@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllTwoTimeThree;
@property (strong, nonatomic) IBOutlet UIImageView *lessOftenNotAtAllTwoTimeFour;

// Sticker UIImageViews
@property (weak, nonatomic) IBOutlet UIImageView *stickerOne;
@property (weak, nonatomic) IBOutlet UIImageView *stickerTwo;
@property (weak, nonatomic) IBOutlet UIImageView *stickerThree;
@property (weak, nonatomic) IBOutlet UIImageView *stickerFour;
@property (weak, nonatomic) IBOutlet UIImageView *stickerFive;
@property (weak, nonatomic) IBOutlet UIImageView *stickerSix;
@property (weak, nonatomic) IBOutlet UIImageView *stickerSeven;
@property (weak, nonatomic) IBOutlet UIImageView *stickerEight;

// Variables
@property (weak, nonatomic) NSString *imageToUpdate;
@property (nonatomic, assign) BOOL stickersToUpdate;
@property (weak, nonatomic) IBOutlet UILabel *currentTokenBalance;
@property (weak, nonatomic) IBOutlet UILabel *dailyTokenBalance;
@property (strong, nonatomic) IBOutlet UILabel *notebookNameLbl;
@property (weak, nonatomic) NSDate *currDate;

// Save btn
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

// Tokens labels
@property (weak, nonatomic) IBOutlet UILabel *dailyTokensLbl;
@property (weak, nonatomic) IBOutlet UILabel *tokenBalanceLbl;

// Tab bar items
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rewardsTab;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoTab;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsTab;
@property (strong, nonatomic) IBOutlet UILabel *behaviorToKeepTitleLabel;

// Gesture recognizers
- (IBAction)stickerOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)stickerTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)stickerThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)stickerFourTapped:(UITapGestureRecognizer *)sender;
- (IBAction)stickerFiveTapped:(UITapGestureRecognizer *)sender;
- (IBAction)stickerSixTapped:(UITapGestureRecognizer *)sender;
- (IBAction)stickerSevenTapped:(UITapGestureRecognizer *)sender;
- (IBAction)stickerEightTapped:(UITapGestureRecognizer *)sender;

// Behaviors to keep
- (IBAction)behaviorToKeepOneTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepOneTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepOneTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepOneTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)behaviorToKeepTwoTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepTwoTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepTwoTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepTwoTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)behaviorToKeepThreeTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepThreeTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepThreeTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)behaviorToKeepThreeTimeFourTapped:(UITapGestureRecognizer *)sender;

// Things to do instead
- (IBAction)thingsToDoInsteadOneTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadOneTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadOneTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadOneTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)thingsToDoInsteadTwoTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadTwoTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadTwoTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadTwoTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)thingsToDoInsteadThreeTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadThreeTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadThreeTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadThreeTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)thingsToDoInsteadFourTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadFourTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadFourTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)thingsToDoInsteadFourTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)lessOftenNotAtAllOneTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)lessOftenNotAtAllOneTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)lessOftenNotAtAllOneTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)lessOftenNotAtAllOneTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)lessOftenNotAtAllTwoTimeOneTapped:(UITapGestureRecognizer *)sender;
- (IBAction)lessOftenNotAtAllTwoTimeTwoTapped:(UITapGestureRecognizer *)sender;
- (IBAction)lessOftenNotAtAllTwoTimeThreeTapped:(UITapGestureRecognizer *)sender;
- (IBAction)lessOftenNotAtAllTwoTimeFourTapped:(UITapGestureRecognizer *)sender;

- (IBAction)saveBtnClick:(id)sender;
- (IBAction)goBackToNotebooksBtn:(id)sender;
- (IBAction)pickDateClk:(id)sender;

-(void) setRequiredLabelValues;
-(void) checkWhichLabelsToDisplay;

@end
