//
//  Tutorials.h
//
//  Created by David Wiza on 12/7/13.
//  Copyright (c) 2013 Capstone Student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialBalloon.h"
#import "Tutorial.h"
#import "LocalDatabase.h"

#define VERTICAL_OFFSET 25
#define HORIZONTAL_OFFSET   10

@interface Tutorials : NSObject

@property NSMutableDictionary *tutorials;
@property TutorialID currentTutorial;

- (void) setShown:(TutorialID)ID;
- (void) showTutorialAtX:(int)x atY:(int)y withID:(TutorialID)ID inView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender;
- (void) showTutorialOnControl:(UIView *)control withID:(TutorialID)ID inView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender;
//- (void) showBubbleWithText:(NSString*)text atX:(int) x atY:(int)y inView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender;
- (void) showCustomTutorialOnControl:(UIView *)control withText:(NSString*)text nView:(UIView *)view withOrientation:(BalloonOrientation)orientation withCallback:(SEL)callback fromSender:(id)sender;
- (void) hideTutorial;
- (void) reset;
- (bool) hasBeenShown:(TutorialID)ID;

@end
