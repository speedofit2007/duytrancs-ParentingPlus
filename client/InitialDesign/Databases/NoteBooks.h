//
//  NoteBooks.h
//  Parenting+
//
//  Created by Duy Tran on 1/16/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalDatabase.h"
#import "OutlineDBFunction.h"

@interface NoteBooks : LocalDatabase
{
    int notebooks_id;
    int user_id;
    
    NSMutableDictionary *ArrayOfBooks;
    NSMutableArray *ArrayOfGoodBehaviors;
    NSMutableArray *ArrayOfBadBehaviors;
    NSMutableArray *ArrayOfBehaviorsToChange;
    NSMutableArray *TimeToCheckBehaviorsArray;
    NSMutableArray *ArrayOfRewards;
}
// constructor
- (id) init;
- (id) initWithID: (NSString *) bookid;
- (id) initWithNoteBook: (NSMutableDictionary *) book;

// functions for TOKENS
- (int) getTokenBalance;
- (int) dailyTokenBalanceWhen: (NSString*) date;
- (BOOL) updateTokenBalanceWith: (int) numtoken;

// INSERT Functions from specific notebook
- (NoteBooks *) setArrayBookFromNotebook: (NoteBooks *) book withDictionary: (NSMutableDictionary *) dictionaryBook;
- (NoteBooks *) setBehaviorsToKeepFromNotebook: (NoteBooks *) book withGoodBehavior: (NSMutableArray *) goodBehavior;
- (NoteBooks *) setBehaviorsToChangeFromNotebook: (NoteBooks *) book withBadBehavior: (NSMutableArray *) badBehavior;
- (NoteBooks *) setBehaviorsToDoInsteadFromNotebook: (NoteBooks *) book withChangeBehavior: (NSMutableArray *) changeBehavior;
- (NoteBooks *) setBehaviorsCheckinTimeFromNotebook: (NoteBooks *) book withTime: (NSMutableArray *) timeToCheckBehavior;
- (NoteBooks *) setRewardsFromNotebook: (NoteBooks *) book andReward: (NSMutableArray *) rewards;

// implement insert function (Only for system process, no use for UI)
- (void) setArrayBookwithDictionary: (NSMutableDictionary *) dictionaryBook;
- (void) setKeepBehaviorswithGoodBehavior: (NSMutableArray *) goodBehavior;
- (void) setBehaviorsToChangeWithBadBehavior: (NSMutableArray *) badBehavior;
- (void) setBehaviorsToDoInsteadWithChangeBehavior: (NSMutableArray *) changeBehavior;
- (void) setBehaviorsCheckinTimeWithTime: (NSMutableArray *) timeToCheckBehavior;
- (void) setRewards: (NSMutableArray *) rewards;


// Get notebook by notebooks_id for display notebook
- (NoteBooks *) getWholeClassNotebooksFromNotebookID:(NSString *) bookid;
- (int) getCurrentBookID;
- (NSDate *) getNotebookCreateDate;

// GETARRAY Function from current Notebook (Only for system process, no use for UI)
- (NSMutableArray *) getBehaviorsToKeep;
- (NSMutableArray *) getBehaviorsToChange;
- (NSMutableArray *) getBehaviorsToDoInstead;
- (NSMutableArray *) getBehaviorsCheckinTime;
- (NSMutableArray *) getRewards;
- (NSMutableDictionary *) getArrayBooks;

// GETARRAY Function from specific Notebook
- (NSMutableDictionary *) getArrayBooksFromNotebook: (NoteBooks *) book;
- (NSMutableArray *) getBehaviorsToKeepFromNotebook: (NoteBooks *) book;
- (NSMutableArray *) getBehaviorsToChangeFromNotebook: (NoteBooks *) book;
- (NSMutableArray *) getBehaviorsToDoInsteadFromNotebook: (NoteBooks *) book;
- (NSMutableArray *) getBehaviorsCheckinTimeFromNotebook: (NoteBooks *) book;
- (NSMutableArray *) getRewardsFromNotebook: (NoteBooks *) book;

// UPDATE Functions
- (NoteBooks *) updateNotebookWithNewName: (NSString *) newName fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateNotebookWithNewPicture: (NSData *) picData fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateNotebookWithNewAge: (NSString *) Age fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateGoodBehaviorWithOldArray: (NSMutableArray *) oldArray toNewArray: (NSMutableArray *) newArray fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateBadBehaviorWithOldArray: (NSMutableArray *) oldArray toNewArray: (NSMutableArray *) newArray fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateBadBehaviorWithNewBehavior: (NSString *) badBehavior fromOldRule: (NSString *) oldRule toNewRule: (NSString *) newRule fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateBehaviorsToDoInsteadWithOldName: (NSString *) oldName toNewName: (NSString *) newName ofbadBehavior: (NSString *) badBehavior fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateBehaviorsToDoInsteadWithOldArray: (NSMutableArray *) oldArray toNewArray: (NSMutableArray *) newArray ofBadBH: (NSMutableArray *) badBHArray fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateBehaviorsCheckinTimeWithOldTime: (NSString *) oldTime toNewTime: (NSString *) newtime fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateRewardWithOldName: (NSString *) oldName toNewName: (NSString *) newName fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateRewardPriceWithName: (NSString *) rewardName toNewPrice: (NSString *) newPrice fromNotebook: (NoteBooks *) book;
- (NoteBooks *) updateStatusOfNotebookFromNotebook: (NoteBooks *) book;

// function check old value has change or not?
- (BOOL) isTextViewChange: (NSMutableArray*) oldArray compareTo: (NSMutableArray*) newArray;

@end
