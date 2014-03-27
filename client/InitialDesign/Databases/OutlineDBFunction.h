//
//  OutlineDBFunction.h
//  initializeDesign
//
//  Created by Duy Tran on 1/22/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalDatabase.h"

@interface OutlineDBFunction : LocalDatabase

// outline Functions
-(NSString *) getTableIdByQuery: (NSString *) getIdQuery;
-(BOOL) checkNotebookNameExist: (NSString *) name;
-(int) getAfterMaxIDFromTable: (NSString*) tname;

-(NSMutableArray *) getNotebooks;
-(NSMutableArray *) getGoodBehaviors;
-(NSMutableArray *) getBadBehaviors;
-(NSMutableArray *) getChangeBehaviors;
-(NSMutableArray *) getChangeBehaviorsDisplay;
-(NSMutableArray *) getAllChangeBehaviors;
-(NSMutableArray *) getRewardTime;
-(NSMutableArray *) getRewards;
-(NSMutableArray *) getSavedRewards;
-(NSMutableArray *) getTrackBehaviorWhen: (NSString *) date;

-(NSMutableArray *) getGoodBehaviorsLastest;
-(NSMutableArray *) getGoodBehaviorsBeforeTo: (NSString *) date;
-(NSMutableArray *) getBadBehaviorsLastest;
-(NSMutableArray *) getBadBehaviorsBeforeTo: (NSString *) date;
-(NSMutableArray *) getChangeBehaviorsLastest;
-(NSMutableArray *) getChangeBehaviorsBeforeTo: (NSString *) date;

// function update Camera Image
-(BOOL) updateCameraImage: (NSData*) imgData;
-(NSData*) getCameraImage;
-(NSData*) getCameraImageWithID: (NSString*)bookid;
- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2;

// functions working with Rewards
-(BOOL) SaveRedeemRewards: (NSString *)reward_name andPrice: (int)price andStatus:(NSString *)status when: (NSString*) date;
// function for Notebook Account Statement page
- (int) getTokenEarnedWhen: (NSString*) date;
- (NSMutableArray *) getRewardsRedeemedOrSavedWhen: (NSString*) date;
- (int) getBeginningTokenBalanceWhen:(NSString*) date;
- (BOOL) updateSavedRewardToRedemmedFromID: (NSString*) savedreward_id;

// functions working with keep track all behaviors
-(NSMutableArray *) getTrackGoodBehaviorsWhen: (NSString *) date;
-(NSMutableArray *) getTrackThingsToDoInsteadWhen: (NSString *) date;
-(BOOL) setTrackGoodBehaviorWithTime: (NSString *) date andGoodBehaviorid: (NSString *) goodBehavior_id andTime1: (NSString *) time1 andTime2: (NSString *) time2 andTime3: (NSString *) time3 andTime4: (NSString *) time4;
-(BOOL) setTrackChangeBehaviorWithTime: (NSString *) date andChangeBehaviorId: (NSString *) changeBehavior_id andTime1: (NSString *) time1 andTime2: (NSString *) time2 andTime3: (NSString *) time3 andTime4: (NSString *) time4;

// function implement into each history table
// 0 = delete
// 1 = insert/update
-(void)implementHistoryTableWithKey:(NSMutableDictionary *)composKey andType:(BOOL)changeType toTable:(NSString *)tablename;

// function DELETE
-(void) deleteRecordFromTable: (NSString*) table WhereId: (NSString*) myid;
@end
