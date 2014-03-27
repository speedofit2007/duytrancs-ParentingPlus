//
//  MPTutorials.m
//  MiniProject
//
//  Created by David Wiza on 12/7/13.
//  Copyright (c) 2013 Capstone Student. All rights reserved.
//

#import "Tutorials.h"

TutorialBalloon *balloon;

@implementation Tutorials

- (id) init {
    balloon = NULL;
    self.tutorials = [[NSMutableDictionary alloc] init];
    [self addTutorial:TUT_USER_NAME :@"Enter your user name"];
    [self addTutorial:TUT_PASSWORD :@"Enter your password"];
    [self addTutorial:TUT_PRESS_LOGIN :@"Touch the login button"];
    [self addTutorial:TUT_FIRST_TIME :@"Is this your first time using Parenting+?  Tap the Sign Up button to create an account!"];
    [self addTutorial:TUT_NEED_TO_CREATE_NOTEBOOK :@"Create your first notebook by clicking the + button in the corner."];
    [self addTutorial:TUT_EDIT_NOTEBOOK :@"Tap a notebook to log behavior or access rewards.  Swipe left on a notebook to edit or delete the notebook."];
    [self addTutorial:TUT_BEHAVIORS_KEEP :@"Think of up to three good behaviors that you want your child to continue doing and enter them."];
    [self addTutorial:TUT_BEHAVIORS_CHANGE :@"Think of up to two bad behaviors that you want your child to stop doing and enter them."];
    [self addTutorial:TUT_BEHAVIORS_INSTEAD :@"For each behavior you want your child to change, think of two things your child could do instead and enter them."];
    [self addTutorial:TUT_RULES_AND_REMINDERS :@"Think of two additional rules for your child or things to remind them of and enter them."];
    [self addTutorial:TUT_TIME :@"Choose up to four times of the day to observe your child's behavior and reward them for good behavior."];
    [self addTutorial:TUT_REWARDS :@"Think of three to eight different rewards your child can earn with good behavior and enter them."];
    [self addTutorial:TUT_REWARD_PRICES_1 :@"Each time you record your child's behavior, you will be awarding them with a sticker for each proper behavior.  For each sticker award, they will earn a token."];
    [self addTutorial:TUT_REWARD_PRICES_2 :@"Consider each reward and enter how many points a reward should cost your child to redeem."];
    [self addTutorial:TUT_NOTEBOOK_1 :@"This is the main notebook screen.  To log your child's good behavior and give them a sticker, tap the \"Behaviors\" button."];
    [self addTutorial:TUT_NOTEBOOK_2 :@"After your child has earned enough tokens, you can tap the Rewards button to redeem them for rewards."];
    [self addTutorial:TUT_NOTEBOOK_3 :@"At the end of each day, tap the \"Lock Notebook for the Day\" button.  You can lock the Notebook early to disallow them from receiving any more stickers for that day."];
    [self addTutorial:TUT_PHOTO_1 :@"Select a picture to use for this Notebook.  You can either use a stock photo, take a new picture, or select from your library of pictures.  After selecting a photo, enter your child's name and birthdate below and then touch Save and Continue."];
    [self addTutorial:TUT_REWARD :@"After your child has earned enough tokens to buy a reward, click the coin icon to redeem tokens for a reward or save the reward for a later date."];
    [self addTutorial:TUT_CHEST :@"Rewards saved for later can be accessed by tapping the Treasure Chest button."];
    [self addTutorial:TUT_BEHAVIORS_1 :@"For each check-in time, if your child has behaved according to the rules you have defined, you can reward them with a sticker for each behavior they have followed properly."];
    [self addTutorial:TUT_BEHAVIORS_2 :@"For each sticker you give your child, a token will be saved.  The tokens can then be redeemed for the rewards you defined."];
    [self addTutorial:TUT_BEHAVIORS_3 :@"To change the sticker graphic, tap a graphic from below."];
    NSLog(@"Tutorial dictionary initialized.");
    return self;
}

- (void) addTutorial:(TutorialID)ID :(NSString *)text {
    Tutorial *tut = [[Tutorial alloc] init];
    NSString *key = [NSString stringWithFormat:@"%i", (int)ID];
    tut.ID = ID;
    tut.text = text;
    [self.tutorials setObject:tut forKey:key];
}

- (NSString *) getCurrentUser {
    NSString *currentUser = [[[LocalDatabase alloc] init] getCurrentUser];
    if (!currentUser) {
        NSLog(@"currentUser is NULL.");
        return NULL;
    }
    return [NSString stringWithFormat:@"u%@", currentUser];
}

- (void) setShown:(TutorialID)ID {
    NSString* currentUser = [self getCurrentUser];
    if (!currentUser) {
        return ;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TutorialLog.plist"];
    //NSLog(@"plist path is %@", path);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    if (!dict) {
        NSLog(@"dict was null.  Creating...");
        dict = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *tutArray = tutArray = [dict objectForKey:currentUser];
    
    if (!tutArray) {
        NSLog(@"Tutorial array not found.  Creating.");
        tutArray = [[NSMutableArray alloc] initWithCapacity:TUT_COUNT];
        for (int i = 0; i < TUT_COUNT; i++) {
            [tutArray addObject:[NSNumber numberWithInt:0]];
        }
    }
    
    if (tutArray.count < TUT_COUNT) {
        NSLog(@"Tutorial array is smaller than expected.  Expanding...");
        for(int i = (int)tutArray.count; i < TUT_COUNT; i++){
            [tutArray addObject:[NSNumber numberWithInt:0]];
        }
    }
    
    [tutArray replaceObjectAtIndex:(int)ID withObject:[NSNumber numberWithInt:1]];
    
    [dict setValue:tutArray forKey:currentUser];
    if (![dict writeToFile:path atomically:YES]) {
        NSLog(@"ERROR: Failed to write tutorial dictionary to plist!");
    }
}

- (NSMutableArray*) getTutArray {
    NSString *currentUser = [self getCurrentUser];
    NSLog(@"Current user: %@", currentUser);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TutorialLog.plist"];
    NSLog(@"plist path is %@", path);
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    return [dict objectForKey:currentUser];
}

- (void) reset {
    NSString *currentUser = [self getCurrentUser];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TutorialLog.plist"];
    //NSLog(@"plist path is %@", path);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableArray *tutArray = [[NSMutableArray alloc] initWithCapacity:(int)TUT_COUNT];
    for (int i = 0; i < TUT_COUNT; i++) {
        [tutArray addObject:[NSNumber numberWithInt:0]];
    }
    [dict setValue:tutArray forKey:currentUser];
    [dict writeToFile:path atomically:YES];
}

- (bool) hasBeenShown:(TutorialID)ID {
    int tutId = (int)ID;
    NSMutableArray *tutArray = [self getTutArray];
    if (tutArray) {
        NSLog(@"tutorial array found.");
        if (tutArray.count < TUT_COUNT) {
            NSLog(@"Tutorial array is smaller than expected.  Returning false.");
            return false;
        }
        return [[tutArray objectAtIndex:tutId] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        
    } else {
        NSLog(@"tutorial array not found.  returning false.");
        return false;
    }
}

- (void) showTutorialAtX:(int)x atY:(int)y withID:(TutorialID)ID inView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender
{
    if([self hasBeenShown:ID]) {
        if (callback && sender) {
            [sender performSelector:callback];
        }
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%i", (int)ID];
    Tutorial *tut = [self.tutorials valueForKey:key];
    [self setShown:ID];
    [self.tutorials setObject:tut forKey:key];
    self.currentTutorial = ID;
    [self showBubbleWithText:tut.text atX:x atY:y inView:view withOrientation:orientation withCallback:callback fromSender:sender];
}

- (void) showBubbleWithText:(NSString*)text atX:(int) x atY:(int)y inView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender
{
    if(balloon) {
        [self hideTutorial];
    }
    balloon = [[TutorialBalloon alloc] initWithX:x withY:y withText:text withOrientation:orientation];
    balloon.callback = callback;
    balloon.sender = sender;
    [view addSubview:balloon];
}

- (void) showCustomTutorialOnControl:(UIView *)control withText:(NSString*)text nView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender
{
    int x = control.frame.origin.x + control.frame.size.width / 2;
    int y = orientation == POINTING_UP ? control.frame.origin.y + 0.9 * control.frame.size.height : control.frame.origin.y + 0.1 * control.frame.size.height;
    [self showBubbleWithText:text atX:x atY:y inView:view withOrientation:orientation withCallback:callback fromSender:sender];
}


- (void) showTutorialOnControl:(UIView *)control withID:(TutorialID)ID inView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender
{
    int x = control.frame.origin.x + control.frame.size.width / 2;
    int y = orientation == POINTING_UP ? control.frame.origin.y + 0.9 * control.frame.size.height : control.frame.origin.y + 0.1 * control.frame.size.height;
    [self showTutorialAtX:x atY:y withID:ID inView:view withOrientation:orientation withCallback:callback fromSender:sender];
}

- (void) hideTutorial {
    if(!balloon)
        return;
    [balloon removeFromSuperview];
    balloon = NULL;
}

@end
