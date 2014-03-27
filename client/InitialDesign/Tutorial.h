//
//  Tutorial.h
//
//  Created by David Wiza on 12/7/13.
//  Copyright (c) 2013 Capstone Student. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _TutorialID : NSInteger{
    TUT_USER_NAME,
    TUT_PASSWORD,
    TUT_PRESS_LOGIN,
    TUT_FIRST_TIME,
    TUT_NEED_TO_CREATE_NOTEBOOK,
    TUT_EDIT_NOTEBOOK,
    TUT_BEHAVIORS_KEEP,
    TUT_BEHAVIORS_CHANGE,
    TUT_BEHAVIORS_INSTEAD,
    TUT_RULES_AND_REMINDERS,
    TUT_TIME,
    TUT_REWARDS,
    TUT_REWARD_PRICES_1,
    TUT_REWARD_PRICES_2,
    TUT_NOTEBOOK_1,
    TUT_NOTEBOOK_2,
    TUT_NOTEBOOK_3,
    TUT_PHOTO_1,
    TUT_PHOTO_2,
    TUT_PHOTO_3,
    TUT_REWARD,
    TUT_CHEST,
    TUT_BEHAVIORS_1,
    TUT_BEHAVIORS_2,
    TUT_BEHAVIORS_3,
    
    TUT_COUNT
} TutorialID;

@interface Tutorial : NSObject

@property int ID;
@property NSString *text;
//@property bool shown;

@end
