//
//  NoteBooks.m
//  Parenting+
//
//  Created by Duy Tran on 1/16/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "NoteBooks.h"
#import "DBManager.h"

BOOL sucess;


@implementation NoteBooks
//get device ID
-(NSString *)getdeviceID {
    UIDevice *device = [UIDevice currentDevice];
    return[[device identifierForVendor]UUIDString];
}

-(id)init {
    self = [super init];
    if (self) {
        notebooks_id = 0;
        user_id = 0;
        
        ArrayOfBooks = [[NSMutableDictionary alloc]init];
        ArrayOfGoodBehaviors = [[NSMutableArray alloc] init];
        ArrayOfBadBehaviors = [[NSMutableArray alloc] init];
        ArrayOfBehaviorsToChange = [[NSMutableArray alloc] init];
        TimeToCheckBehaviorsArray = [[NSMutableArray alloc] init];
        ArrayOfRewards = [[NSMutableArray alloc] init];
    }
    NSLog(@"Notebook initialized");
    return self;
}

- (id) initWithID: (NSString *) bookid {
    self = [super init];
    if (self) {
        notebooks_id = [bookid intValue];
        user_id = [self.getCurrentUser intValue];
        
        ArrayOfBooks = [[NSMutableDictionary alloc]init];
        ArrayOfGoodBehaviors = [[NSMutableArray alloc] init];
        ArrayOfBadBehaviors = [[NSMutableArray alloc] init];
        ArrayOfBehaviorsToChange = [[NSMutableArray alloc] init];
        TimeToCheckBehaviorsArray = [[NSMutableArray alloc] init];
        ArrayOfRewards = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithNoteBook:(NSMutableDictionary *)book {
    self = [super init];
    if (self) {
        // All initializeializations
        OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
        DBManager * sharedDB = [DBManager sharedDBManager];
        int nextid = [function getAfterMaxIDFromTable:@"notebooks"];
        NSString *querySQL = [NSString stringWithFormat: @"INSERT INTO notebooks (book_status, book_name, age, tokens, picture, user_id) VALUES ('%@','%@','%@', '%@','%@','%@')", @"incomplete", book[@"book_name"], book[@"age"], book[@"tokens"], book[@"picture"], self.getCurrentUser];
        sucess = [sharedDB insertWithQuery:querySQL];
        if (sucess) {
            user_id = [self.getCurrentUser intValue];
            notebooks_id = nextid;
            [self setCurrentNotebook:[NSString stringWithFormat:@"%d", notebooks_id]];
        }
        ArrayOfBooks = book;
        ArrayOfGoodBehaviors = [[NSMutableArray alloc] init];
        ArrayOfBadBehaviors = [[NSMutableArray alloc] init];
        ArrayOfBehaviorsToChange = [[NSMutableArray alloc] init];
        TimeToCheckBehaviorsArray = [[NSMutableArray alloc] init];
        ArrayOfRewards = [[NSMutableArray alloc] init];
    }
    NSLog(@"Notebook initializeialied with mutable dictionary book");
    return self;
}

// functions for TOKENS
-(int)getTokenBalance {
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString * querySQL = [NSString stringWithFormat: @"SELECT tokens FROM notebooks WHERE id ='%@'", self.getCurrentNotebook];
    return [[function getTableIdByQuery:querySQL] intValue];
}

// Get tokens left for the day on a given day. USE NSDate wrapped as NSString
- (int) dailyTokenBalanceWhen: (NSString*) date {
    DBManager * sharedDB = [DBManager sharedDBManager];
    int tokensleft = 10;
    sqlite3_stmt *checkstatement;
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT time1, time2, time3, time4 FROM trackgoodbehaviors WHERE time_record = '%@' AND notebooks_id = '%@';", date, self.getCurrentNotebook];
    const char *query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            for (int i = 0; i < 4; i ++) {
                NSString *one = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, i)];
                if ([one isEqualToString:@"no-sticker-100px.png"]==FALSE) {
                    tokensleft = tokensleft - 1;
                }
            }
        }
        sqlite3_finalize(checkstatement);
    }
    
    querySQL = [NSString stringWithFormat: @"SELECT time1, time2, time3, time4 FROM trackchangebehaviors WHERE time_record = '%@' AND notebooks_id = '%@';", date, self.getCurrentNotebook];
    query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            for (int i = 0; i < 4; i ++) {
                NSString *one = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, i)];
                if ([one isEqualToString:@"no-sticker-100px.png"]==FALSE) {
                    tokensleft = tokensleft - 1;
                }
            }
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    
    return tokensleft;
}

// Call to update token balance.
- (BOOL) updateTokenBalanceWith: (int) numtoken {
    DBManager * sharedDB = [DBManager sharedDBManager];
    sucess = FALSE;
    int Tokens = [self getTokenBalance];
    Tokens = Tokens + numtoken;
    if (Tokens < 0)
        return sucess;
    else {
        NSString *querySQL = [NSString stringWithFormat: @"UPDATE notebooks SET tokens = '%d' WHERE id ='%@';",Tokens, self.getCurrentNotebook];
        sucess = [sharedDB updateWithQuery:querySQL];
    }
    return sucess;
}





- (void) setArrayBookwithDictionary: (NSMutableDictionary *) dictionaryBook {
    ArrayOfBooks = dictionaryBook;
}

- (void) setKeepBehaviorswithGoodBehavior: (NSMutableArray *) goodBehavior {
    if (!ArrayOfGoodBehaviors) {
        ArrayOfGoodBehaviors = goodBehavior;
    } else {
        for (id obj in goodBehavior) {
            [ArrayOfGoodBehaviors addObject:obj];
        }
    }
}

- (void) setBehaviorsToChangeWithBadBehavior: (NSMutableArray *) badBehavior{
    if (!ArrayOfBadBehaviors) {
        ArrayOfBadBehaviors = badBehavior;
    } else {
        for (id obj in badBehavior) {
            [ArrayOfBadBehaviors addObject:obj];
        }
    }
}

- (void) setBehaviorsToDoInsteadWithChangeBehavior: (NSMutableArray *) changeBehavior{
    if (!ArrayOfBehaviorsToChange) {
        ArrayOfBehaviorsToChange = changeBehavior;
    } else {
        for (id obj in changeBehavior) {
            [ArrayOfBehaviorsToChange addObject:obj];
        }
    }
}

- (void) setBehaviorsCheckinTimeWithTime: (NSMutableArray *) timeToCheckBehavior{
    if (!TimeToCheckBehaviorsArray) {
        TimeToCheckBehaviorsArray = timeToCheckBehavior;
    } else {
        for (id obj in timeToCheckBehavior) {
            [TimeToCheckBehaviorsArray addObject:obj];
        }
    }
}

- (void) setRewards: (NSMutableArray *) rewards{
    ArrayOfRewards = rewards;
}

- (NoteBooks *) setArrayBookFromNotebook: (NoteBooks *) book withDictionary: (NSMutableDictionary *) dictionaryBook {
    [book setArrayBookwithDictionary:dictionaryBook];
    return book;
}
- (NoteBooks *) setBehaviorsToKeepFromNotebook:(NoteBooks *)book withGoodBehavior:(NSMutableArray *)goodBehavior {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *oldname = @"";
    for (id obj in goodBehavior) {
        if([obj[@"bhname"] isEqualToString:oldname] == FALSE) {
            NSString *querySQL = [NSString stringWithFormat: @"INSERT INTO goodbehaviors (bhname, notebooks_id, user_id, date) VALUES ('%@','%@','%@',(SELECT date('now','localtime')))", obj[@"bhname"], self.getCurrentNotebook,self.getCurrentUser];
            sucess = [sharedDB insertWithQuery:querySQL];
            if (sucess) {
                oldname = [NSString stringWithString:obj[@"bhname"]];
            }
        }
    }
    [book setKeepBehaviorswithGoodBehavior:goodBehavior];
    return book;
}

- (NoteBooks *) setBehaviorsToChangeFromNotebook:(NoteBooks *)book withBadBehavior:(NSMutableArray *)badBehavior {
    DBManager * sharedDB = [DBManager sharedDBManager];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString *oldname = @"";
    for (id obj in badBehavior) {
        if([obj[@"name"] isEqualToString:oldname] == FALSE) {
            if (obj[@"name"] && !obj[@"reminders"]) {
                NSString *querySQL = [NSString stringWithFormat: @"INSERT INTO badbehaviors (name, notebooks_id, user_id, date) VALUES ('%@', '%@','%@', (SELECT date('now','localtime')))", obj[@"name"], self.getCurrentNotebook,self.getCurrentUser];
                sucess = [sharedDB insertWithQuery:querySQL];
                if (sucess) {
                    oldname = [NSString stringWithString:obj[@"name"]];
                }
            }
            if (obj[@"name"] && obj[@"reminders"]) {
                NSString *queryID = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE name='%@' AND notebooks_id='%@'",obj[@"name"], self.getCurrentNotebook];
                NSString *myid = [function getTableIdByQuery:queryID];
                if ([myid length] == 0) {
                    NSString *queryInsert = [NSString stringWithFormat: @"INSERT INTO badbehaviors (name, reminders, notebooks_id, user_id, date) VALUES ('%@', '%@','%@','%@', (SELECT date('now','localtime')))", obj[@"name"], obj[@"reminders"], self.getCurrentNotebook,self.getCurrentUser];
                    sucess = [sharedDB insertWithQuery:queryInsert];
                    oldname = [NSString stringWithString:obj[@"name"]];
                    myid = [function getTableIdByQuery:queryID];
                } else {
                    NSString *querySQL = [NSString stringWithFormat: @"UPDATE badbehaviors SET reminders = '%@' WHERE id ='%@';",obj[@"reminders"], myid];
                    sucess = [sharedDB updateWithQuery:querySQL];
                    if (sucess) {
                        oldname = [NSString stringWithString:obj[@"name"]];
                    }
                }
            }
            
        }
    }
    [book setBehaviorsToChangeWithBadBehavior:badBehavior];
    return book;
}
- (NoteBooks *) setBehaviorsToDoInsteadFromNotebook:(NoteBooks *)book withChangeBehavior:(NSMutableArray *)changeBehavior {
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *oldName = @"";
    NSString *oldID = @"";
    for (id obj in changeBehavior) {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE name='%@' AND notebooks_id='%@'",obj[@"badBehavior_name"], self.getCurrentNotebook];
        NSString *myid = [function getTableIdByQuery:querySQL];
        if ([myid isEqualToString:oldID] == FALSE) {
            querySQL = [NSString stringWithFormat: @"INSERT INTO changebehaviors (badbh_id, bhname, notebooks_id, user_id, date) VALUES ('%@','%@','%@', '%@', (SELECT date('now','localtime')))", myid, @"Less often/Not at all", self.getCurrentNotebook, self.getCurrentUser];
            sucess = [sharedDB insertWithQuery:querySQL];
            if (sucess) {
                oldID = [NSString stringWithString:myid];
                oldName = @"";
            }
        }
        if ([obj[@"bhname"] isEqualToString:oldName] == FALSE) {
            querySQL = [NSString stringWithFormat: @"INSERT INTO changebehaviors (badbh_id, bhname, notebooks_id, user_id, date) VALUES ('%@','%@','%@', '%@', (SELECT date('now','localtime')))", myid, obj[@"bhname"], self.getCurrentNotebook, self.getCurrentUser];
            sucess = [sharedDB insertWithQuery:querySQL];
            if (sucess) {
                oldName = [NSString stringWithString:obj[@"bhname"]];
            }
        }
    }
    [book setBehaviorsToDoInsteadWithChangeBehavior:changeBehavior];
    return book;
}
- (NoteBooks *) setBehaviorsCheckinTimeFromNotebook:(NoteBooks *)book withTime:(NSMutableArray *)timeToCheckBehavior {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *oldName = @"";
    for (id obj in timeToCheckBehavior) {
        if([obj[@"timeperiod"] isEqualToString:oldName] == FALSE) {
            NSString *querySQL = [NSString stringWithFormat: @"INSERT INTO rewardtime (timeperiod, notebooks_id,user_id) VALUES ('%@','%@','%@')", obj[@"timeperiod"], self.getCurrentNotebook,self.getCurrentUser];
            sucess = [sharedDB insertWithQuery:querySQL];
            if (sucess) {
                oldName = [NSString stringWithString:obj[@"timeperiod"]];
            }
        }
    }
    [book setBehaviorsCheckinTimeWithTime:timeToCheckBehavior];
    return book;
}
- (NoteBooks *) setRewardsFromNotebook:(NoteBooks *)book andReward:(NSMutableArray *)rewards {
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    DBManager * sharedDB = [DBManager sharedDBManager];
    for (id obj in rewards) {
        if (obj[@"reward_name"] && !obj[@"price"]) {
            NSString *querySQL = [NSString stringWithFormat: @"INSERT INTO rewards (reward_name, notebooks_id,user_id) VALUES ('%@','%@','%@')", obj[@"reward_name"], self.getCurrentNotebook,self.getCurrentUser];
            sucess = [sharedDB insertWithQuery:querySQL];
        }
        if (obj[@"reward_name"] && obj[@"price"]) {
            NSString *queryID = [NSString stringWithFormat: @"SELECT id FROM rewards WHERE reward_name='%@' AND notebooks_id='%@'",obj[@"reward_name"], self.getCurrentNotebook];
            NSString *myid = [function getTableIdByQuery:queryID];
            if (!myid) {
                NSString *queryInsert= [NSString stringWithFormat: @"INSERT INTO rewards (reward_name, price, notebooks_id, user_id) VALUES ('%@', '%@','%@','%@')", obj[@"reward_name"], obj[@"price"], self.getCurrentNotebook,self.getCurrentUser];
                sucess = [sharedDB insertWithQuery:queryInsert];
                myid = [function getTableIdByQuery:queryID];
            }
            NSString *querySQL = [NSString stringWithFormat: @"UPDATE rewards SET price = '%@' WHERE id ='%@';",obj[@"price"], myid];
            sucess = [sharedDB updateWithQuery:querySQL];
        }
    }
    [book setRewards:rewards];
    return book;
}

- (NSMutableArray *) getBehaviorsToKeep {return ArrayOfGoodBehaviors;}
- (NSMutableArray *) getBehaviorsToChange {return ArrayOfBadBehaviors;}
- (NSMutableArray *) getBehaviorsToDoInstead {return ArrayOfBehaviorsToChange;}
- (NSMutableArray *) getBehaviorsCheckinTime {return TimeToCheckBehaviorsArray;}
- (NSMutableArray *) getRewards {return ArrayOfRewards;}
- (NSMutableDictionary *) getArrayBooks {return ArrayOfBooks;}

- (NSMutableDictionary *) getArrayBooksFromNotebook: (NoteBooks *) book {
    return [book getArrayBooks];
}
- (NSMutableArray *) getBehaviorsToKeepFromNotebook: (NoteBooks *) book{
    return [book getBehaviorsToKeep];
}
- (NSMutableArray *) getBehaviorsToChangeFromNotebook: (NoteBooks *) book{
    return [book getBehaviorsToChange];
}
- (NSMutableArray *) getBehaviorsToDoInsteadFromNotebook: (NoteBooks *) book{
    return [book getBehaviorsToDoInstead];
}
- (NSMutableArray *) getBehaviorsCheckinTimeFromNotebook: (NoteBooks *) book{
    return [book getBehaviorsCheckinTime];
}
- (NSMutableArray *) getRewardsFromNotebook: (NoteBooks *) book{
    return [book getRewards];
}

- (NoteBooks *) updateNotebookWithNewName: (NSString *) newName fromNotebook: (NoteBooks *) book {
    NSMutableDictionary *newbook = [[NSMutableDictionary alloc]init];
    DBManager * sharedDB = [DBManager sharedDBManager];
    newbook = [book getArrayBooks];
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE notebooks SET book_name = '%@' WHERE id ='%@';",newName, self.getCurrentNotebook];
    sucess = [sharedDB updateWithQuery:querySQL];
    [newbook setObject:newName forKey:@"book_name"];
    [book setArrayBookwithDictionary:newbook];
    return book;
}

- (NoteBooks *) updateNotebookWithNewPicture: (NSData *) picData fromNotebook: (NoteBooks *) book {
    NSMutableDictionary *newbook = [[NSMutableDictionary alloc]init];
    //DBManager * sharedDB = [DBManager sharedDBManager];
    newbook = [book getArrayBooks];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    sucess = [function updateCameraImage:picData];
    [newbook setObject:picData forKey:@"picture"];
    [book setArrayBookwithDictionary:newbook];
    return book;
}

- (NoteBooks *) updateNotebookWithNewAge: (NSString *) Age fromNotebook: (NoteBooks *) book {
    NSMutableDictionary *newbook = [[NSMutableDictionary alloc]init];
    DBManager * sharedDB = [DBManager sharedDBManager];
    newbook = [book getArrayBooks];
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE notebooks SET age = '%@' WHERE id ='%@';",Age, self.getCurrentNotebook];
    sucess = [sharedDB updateWithQuery:querySQL];
    [newbook setObject:Age forKey:@"age"];
    [book setArrayBookwithDictionary:newbook];
    return book;
}

- (NoteBooks *) updateGoodBehaviorWithOldArray: (NSMutableArray *) oldArray toNewArray: (NSMutableArray *) newArray fromNotebook: (NoteBooks *) book {
    BOOL success = FALSE;
    DBManager * sharedDB = [DBManager sharedDBManager];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    for (int i = 0; i < oldArray.count; i++) {
        NSString * querySQL = [NSString stringWithFormat: @"SELECT id FROM goodbehaviors WHERE bhname = '%@' AND notebooks_id='%@' AND date = (SELECT date('now','localtime'))", oldArray[i], self.getCurrentNotebook];
        NSString *oldid = [function getTableIdByQuery:querySQL];
        if ([oldid length] == 0) {
            if ([newArray[i] length] > 0){
                querySQL = [NSString stringWithFormat: @"INSERT INTO goodbehaviors (bhname, notebooks_id, user_id, date) VALUES ('%@', '%@', '%@', (SELECT date('now','localtime')))",newArray[i], self.getCurrentNotebook, self.getCurrentUser];
                success = [sharedDB insertWithQuery:querySQL];
            }
        } else {
            if ([oldArray[i] length] > 0 && [newArray[i] length] == 0) {
                [function deleteRecordFromTable:@"goodbehaviors" WhereId:oldid];
            } else {
                querySQL = [NSString stringWithFormat: @"UPDATE goodbehaviors SET bhname = '%@' WHERE id = '%@';",newArray[i], oldid];
                success = [sharedDB updateWithQuery:querySQL];
            }
        }
    }
    
    NSMutableArray *newarray = [book getBehaviorsToKeep];
    newarray = newArray;
    return book;
}

- (NoteBooks *) updateBadBehaviorWithOldArray: (NSMutableArray *) oldArray toNewArray: (NSMutableArray *) newArray fromNotebook: (NoteBooks *) book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    for (int i = 0; i < oldArray.count; i++) {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE name='%@' AND notebooks_id='%@' AND date = (SELECT date('now','localtime'))", oldArray[i], self.getCurrentNotebook];
        NSString *myid = [function getTableIdByQuery:querySQL];
        if ([myid length] == 0) {
            if ([newArray[i] length] > 0){
                NSString *nextBBid = [NSString stringWithFormat:@"%d",[function getAfterMaxIDFromTable:@"badbehaviors"]];
                querySQL = [NSString stringWithFormat: @"INSERT INTO badbehaviors (name, notebooks_id, user_id, date) VALUES ('%@','%@','%@', (SELECT date('now','localtime')))", newArray[i], self.getCurrentNotebook,self.getCurrentUser];
                sucess = [sharedDB insertWithQuery:querySQL];
                if (sucess) {
                    querySQL = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE name='%@' AND notebooks_id='%@'", oldArray[i], self.getCurrentNotebook];
                    NSString *oldbadid = [function getTableIdByQuery:querySQL];
                    if ([oldbadid length] > 0) {
                        NSMutableArray *arrayID = [[NSMutableArray alloc]init];
                        querySQL = [NSString stringWithFormat: @"SELECT id FROM changebehaviors WHERE badbh_id = '%@' AND notebooks_id = '%@'", oldbadid, self.getCurrentNotebook];
                        arrayID = [sharedDB selectQuery:querySQL];
                        for (id change_id in arrayID) {
                            querySQL = [NSString stringWithFormat: @"INSERT INTO changebehaviors (badbh_id, bhname, notebooks_id, user_id, date) VALUES ('%@', (SELECT bhname FROM changebehaviors WHERE id = '%@'), '%@', '%@', (SELECT date('now','localtime')))", nextBBid, change_id, self.getCurrentNotebook, self.getCurrentUser];
                        }
                    }
                    
                }
            }
        } else {
            if ([oldArray[i] length] > 0 && [newArray[i] length] == 0) {
                [function deleteRecordFromTable:@"badbehaviors" WhereId:myid];
            } else {
                querySQL = [NSString stringWithFormat: @"UPDATE badbehaviors SET name = '%@' WHERE id ='%@';",newArray[i], myid];
                sucess = [sharedDB updateWithQuery:querySQL];
            }
        }
    }
    
    NSMutableArray *newarray = [book getBehaviorsToChange];
    newarray = newArray;
    //[book setBehaviorsToChangeWithBadBehavior:newarray];
    return book;
}

-( NoteBooks *) updateBadBehaviorWithNewBehavior:(NSString *)badBehavior fromOldRule:(NSString *)oldRule toNewRule:(NSString *)newRule fromNotebook:(NoteBooks *)book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE reminders = '%@' AND name='%@' AND notebooks_id='%@'",newRule, badBehavior, self.getCurrentNotebook];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString *checkid = [function getTableIdByQuery:querySQL];
    if ([checkid length] == 0) {
        querySQL = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE name='%@' AND notebooks_id='%@'",badBehavior, self.getCurrentNotebook];
        NSString *myid = [function getTableIdByQuery:querySQL];
        querySQL = [NSString stringWithFormat: @"UPDATE badbehaviors SET reminders = '%@' WHERE id ='%@';",newRule, myid];
        sucess = [sharedDB updateWithQuery:querySQL];
        NSMutableArray *newarray = [book getBehaviorsToChange];
        for (id obj in newarray) {
            if ([obj[@"reminders"] length] == 0) {
                [obj setObject:newRule forKey:@"reminders"];
            } else if ([obj[@"reminders"] isEqualToString:oldRule] == TRUE) {
                [obj setObject:newRule forKey:@"reminders"];
            }
        }
    }
    //[book setBehaviorsToChangeWithBadBehavior:newarray];
    return book;
}

- (NoteBooks *) updateBehaviorsToDoInsteadWithOldName:(NSString *)oldName toNewName:(NSString *)newName ofbadBehavior:(NSString *)badBehavior fromNotebook:(NoteBooks *)book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE name='%@' AND notebooks_id='%@'",badBehavior, self.getCurrentNotebook];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString *mybadid = [function getTableIdByQuery:querySQL];
    
    querySQL = [NSString stringWithFormat: @"SELECT id FROM changebehaviors WHERE bhname='%@' AND badbh_id='%@'",oldName, mybadid];
    NSString *myid = [function getTableIdByQuery:querySQL];
    if ([myid length] == 0) {
        querySQL = [NSString stringWithFormat: @"INSERT INTO changebehaviors (badbh_id, bhname,user_id) VALUES ('%@','%@','%@')", mybadid, newName,self.getCurrentUser];
        sucess = [sharedDB insertWithQuery:querySQL];
    } else if ([newName length] == 0){
        [function deleteRecordFromTable:@"changebehaviors" WhereId:myid];
    } else {
        querySQL = [NSString stringWithFormat: @"SELECT id FROM changebehaviors WHERE bhname='%@' AND badbh_id = '%@'",newName, mybadid];
        NSString *checkid = [function getTableIdByQuery:querySQL];
        if ([checkid length] == 0) {
            querySQL = [NSString stringWithFormat: @"UPDATE changebehaviors SET bhname = '%@' WHERE id ='%@';",newName, myid];
            sucess = [sharedDB updateWithQuery:querySQL];
        }
    }
    NSMutableArray *newarray = [book getBehaviorsToDoInstead];
    if ([oldName length] == 0) {
        NSMutableDictionary *one = [[NSMutableDictionary alloc]init];
        [one setObject:newName forKey:@"bhname"];
        [one setObject:badBehavior forKey:@"badBehavior_name"];
        [newarray addObject:one];
    }
    for (id obj in newarray) {
        if ([obj[@"bhname"] isEqualToString:oldName] == TRUE) {
            [obj setObject:newName forKey:@"bhname"];
        }
    }
    //[book setBehaviorsToDoInsteadWithChangeBehavior:newarray];
    return book;
}

- (NoteBooks *) updateBehaviorsToDoInsteadWithOldArray: (NSMutableArray *) oldArray toNewArray: (NSMutableArray *) newArray ofBadBH: (NSMutableArray *) badBHArray fromNotebook: (NoteBooks *) book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    int count = 0;
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    for (int i = 0; i < oldArray.count; i++) {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM changebehaviors WHERE bhname='%@' AND badbh_id in (select id from badbehaviors where notebooks_id ='%@') AND date = (SELECT date('now','localtime'))", oldArray[i], self.getCurrentNotebook];
        NSString *myid = [function getTableIdByQuery:querySQL];
        if ([myid length] == 0) {
            if ([newArray[i] length] > 0){
                querySQL = [NSString stringWithFormat: @"SELECT id FROM badbehaviors WHERE name='%@' AND notebooks_id='%@'", badBHArray[i], self.getCurrentNotebook];
                NSString *mybadid = [function getTableIdByQuery:querySQL];
                if (i == 2) count = 0;
                if (count == 0) {
                    querySQL = [NSString stringWithFormat: @"INSERT INTO changebehaviors (badbh_id, bhname, notebooks_id, user_id, date) VALUES ('%@','%@','%@', '%@', (SELECT date('now','localtime')))", mybadid, @"Less often/Not at all", self.getCurrentNotebook, self.getCurrentUser];
                    sucess = [sharedDB insertWithQuery:querySQL];
                    count ++;
                }
                querySQL = [NSString stringWithFormat: @"INSERT INTO changebehaviors (badbh_id, bhname, notebooks_id, user_id, date) VALUES ('%@','%@','%@', '%@', (SELECT date('now','localtime')))", mybadid, newArray[i], self.getCurrentNotebook, self.getCurrentUser];
                sucess = [sharedDB insertWithQuery:querySQL];
            }
        } else {
            if ([oldArray[i] length] > 0 && [newArray[i] length] == 0) {
                [function deleteRecordFromTable:@"changebehaviors" WhereId:myid];
            } else {
                querySQL = [NSString stringWithFormat: @"UPDATE changebehaviors SET bhname = '%@' WHERE id ='%@';",newArray[i], myid];
                sucess = [sharedDB updateWithQuery:querySQL];
            }
        }
    }
    
    NSMutableArray *newarray = [book getBehaviorsToDoInstead];
    newarray = newArray;
    //[book setBehaviorsToChangeWithBadBehavior:newarray];
    return book;
    
}

- (NoteBooks *) updateBehaviorsCheckinTimeWithOldTime: (NSString *) oldTime toNewTime: (NSString *) newtime fromNotebook: (NoteBooks *) book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM rewardtime WHERE timeperiod='%@' AND notebooks_id='%@'",oldTime, self.getCurrentNotebook];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString *myid = [function getTableIdByQuery:querySQL];
    if ([myid length] == 0) {
        querySQL = [NSString stringWithFormat: @"INSERT INTO rewardtime ( timeperiod, notebooks_id, user_id) VALUES ('%@','%@','%@')", newtime, self.getCurrentNotebook,self.getCurrentUser];
        sucess = [sharedDB insertWithQuery:querySQL];
    } else if ([newtime length] == 0){
        [function deleteRecordFromTable:@"rewardtime" WhereId:myid];
    } else {
        querySQL = [NSString stringWithFormat: @"SELECT id FROM rewardtime WHERE timeperiod='%@' AND notebooks_id='%@'",newtime, self.getCurrentNotebook];
        NSString *checkid = [function getTableIdByQuery:querySQL];
        if ([checkid length] == 0) {
            querySQL = [NSString stringWithFormat: @"UPDATE rewardtime SET timeperiod = '%@' WHERE id ='%@';",newtime, myid];
            sucess = [sharedDB updateWithQuery:querySQL];
        }
    }
    NSMutableArray *newarray = [book getBehaviorsCheckinTime];
    if ([oldTime length] == 0) {
        NSMutableDictionary *one = [[NSMutableDictionary alloc]init];
        [one setObject:newtime forKey:@"timeperiod"];
        [newarray addObject:one];
    }
    for (id obj in newarray) {
        if ([obj[@"timeperiod"] isEqualToString:oldTime] == TRUE) {
            [obj setObject:newtime forKey:@"timeperiod"];
        }
    }
    //[book setBehaviorsCheckinTimeWithTime:newarray];
    return book;
}

- (NoteBooks *) updateRewardWithOldName: (NSString *) oldName toNewName: (NSString *) newName fromNotebook: (NoteBooks *) book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM rewards WHERE reward_name='%@' AND notebooks_id='%@'",oldName, self.getCurrentNotebook];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString *myid = [function getTableIdByQuery:querySQL];
    if ([myid length] == 0) {
        querySQL = [NSString stringWithFormat: @"INSERT INTO rewards (reward_name, notebooks_id,user_id) VALUES ('%@','%@','%@')", newName, self.getCurrentNotebook,self.getCurrentUser];
        sucess = [sharedDB insertWithQuery:querySQL];
    } else if ([newName length] == 0){
        [function deleteRecordFromTable:@"rewards" WhereId:myid];
    } else {
        querySQL = [NSString stringWithFormat: @"UPDATE rewards SET reward_name = '%@' WHERE id ='%@';",newName, myid];
        sucess = [sharedDB updateWithQuery:querySQL];
    }
    NSMutableArray *newarray = [book getRewards];
    if ([oldName length] == 0) {
        NSMutableDictionary *one = [[NSMutableDictionary alloc]init];
        [one setObject:newName forKey:@"reward_name"];
        [newarray addObject:one];
    }
    for (id obj in newarray) {
        if ([obj[@"reward_name"] isEqualToString:oldName] == TRUE) {
            [obj setObject:newName forKey:@"reward_name"];
        }
    }
    return book;
}

- (NoteBooks *) updateRewardPriceWithName: (NSString *) rewardName toNewPrice: (NSString *) newPrice fromNotebook: (NoteBooks *) book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM rewards WHERE reward_name='%@' AND notebooks_id='%@'",rewardName, self.getCurrentNotebook];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString *myid = [function getTableIdByQuery:querySQL];
    querySQL = [NSString stringWithFormat: @"UPDATE rewards SET price = '%@' WHERE id ='%@';",newPrice, myid];
    sucess = [sharedDB updateWithQuery:querySQL];
    NSMutableArray *newarray = [book getRewards];
    for (id obj in newarray) {
        if ([obj[@"reward_name"] isEqualToString:rewardName] == TRUE) {
            [obj setObject:newPrice forKey:@"price"];
        }
    }
    //[book setRewards:newarray];
    return book;
}

- (NoteBooks *) updateStatusOfNotebookFromNotebook: (NoteBooks *) book {
    DBManager * sharedDB = [DBManager sharedDBManager];
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT book_status FROM notebooks WHERE id ='%@';", self.getCurrentNotebook];
    NSString *status = [function getTableIdByQuery:querySQL];
    if ([status isEqualToString:@"completed"]) {
        return book;
    } else {
        NSDate *currDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currDate];
        querySQL = [NSString stringWithFormat: @"UPDATE notebooks SET book_status = '%@', date_create = '%@' WHERE id ='%@';",@"completed", dateString, self.getCurrentNotebook];
        sucess = [sharedDB updateWithQuery:querySQL];
        NSMutableDictionary *newbook = [book getArrayBooks];
        newbook[@"book_status"] = @"completed";
        //[book setArrayBookwithDictionary:newbook];
    }
    return book;
}

- (NoteBooks *) getWholeClassNotebooksFromNotebookID:(NSString *) bookid {
    [self setCurrentNotebook:bookid];
    
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *goodBehaviorArray = [[NSMutableArray alloc] init];
    NSMutableArray *badBehaviorArray = [[NSMutableArray alloc] init];
    NSMutableArray *changeBehaviorArray = [[NSMutableArray alloc] init];
    NSMutableArray *timeToCheckBehaviorArray = [[NSMutableArray alloc] init];
    NSMutableArray *rewardArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *book = [[NSMutableDictionary alloc] init];
    NoteBooks *myNotebook = [[NoteBooks alloc]initWithID:bookid];
    
    tempArray = [function getNotebooks];
    for (id obj in tempArray) {
        if ([obj[@"id"] isEqualToString:bookid]) {
            [book setObject:obj[@"book_name"] forKey:@"book_name"];
            [book setObject:obj[@"book_status"] forKey:@"book_status"];
            [book setObject:obj[@"age"] forKey:@"age"];
            [book setObject:obj[@"tokens"] forKey:@"tokens"];
            [book setObject:obj[@"picture"] forKey:@"picture"];
        }
    }
    tempArray = [function getGoodBehaviorsLastest];
    for (id obj in tempArray) {
        NSMutableDictionary *onerecord = [[NSMutableDictionary alloc] init];
        [onerecord setObject:obj[@"bhname"] forKey:@"bhname"];
        [goodBehaviorArray addObject:onerecord];
    }
    tempArray = [function getBadBehaviorsLastest];
    for (id obj in tempArray) {
        NSMutableDictionary *onerecord = [[NSMutableDictionary alloc] init];
        [onerecord setObject:obj[@"name"] forKey:@"name"];
        [onerecord setObject:obj[@"reminders"] forKey:@"reminders"];
        [badBehaviorArray addObject:onerecord];
    }
    tempArray = [function getChangeBehaviorsLastest];
    for (id obj in tempArray) {
        NSMutableDictionary *onerecord = [[NSMutableDictionary alloc] init];
        [onerecord setObject:obj[@"badBehavior_name"] forKey:@"badBehavior_name"];
        [onerecord setObject:obj[@"bhname"] forKey:@"bhname"];
        [changeBehaviorArray addObject:onerecord];
    }
    tempArray = [function getRewardTime];
    for (id obj in tempArray) {
        NSMutableDictionary *onerecord = [[NSMutableDictionary alloc] init];
        [onerecord setObject:obj[@"timeperiod"] forKey:@"timeperiod"];
        [timeToCheckBehaviorArray addObject:onerecord];
    }
    tempArray = [function getRewards];
    for (id obj in tempArray) {
        NSMutableDictionary *onerecord = [[NSMutableDictionary alloc] init];
        [onerecord setObject:obj[@"reward_name"] forKey:@"reward_name"];
        [onerecord setObject:obj[@"price"] forKey:@"price"];
        [rewardArray addObject:onerecord];
    }
    
    [myNotebook setArrayBookwithDictionary:book];
    [myNotebook setKeepBehaviorswithGoodBehavior:goodBehaviorArray];
    [myNotebook setBehaviorsToChangeWithBadBehavior:badBehaviorArray];
    [myNotebook setBehaviorsCheckinTimeWithTime:timeToCheckBehaviorArray];
    [myNotebook setBehaviorsToDoInsteadWithChangeBehavior:changeBehaviorArray];
    [myNotebook setRewards:rewardArray];
    
    return myNotebook;
}

-(int)getCurrentBookID {
    return notebooks_id;
}

-(NSDate *)getNotebookCreateDate {
    OutlineDBFunction *funtion = [[OutlineDBFunction alloc]init];
    NSString *querry = [NSString stringWithFormat:@"SELECT date_create FROM notebooks WHERE id = '%@'", self.getCurrentNotebook];
    NSString* dateString = [funtion getTableIdByQuery:querry];
    NSDateFormatter* fmt = [NSDateFormatter new];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [fmt dateFromString:dateString];
    return date;
}

- (BOOL) isTextViewChange: (NSMutableArray*) oldArray compareTo: (NSMutableArray*) newArray {
    if (newArray.count != oldArray.count) {
        return TRUE;
    }
    for (int i = 0; i < newArray.count; i++){
        if ([oldArray[i] isEqualToString:newArray[i]]){
            return TRUE;
        }
    }
    return FALSE;
}

@end
