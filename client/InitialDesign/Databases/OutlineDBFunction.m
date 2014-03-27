//
//  OutlineDBFunction.m
//  Parenting+
//
//  Created by Duy Tran on 1/22/14.
//  Copyright (c) 2014 Duy Tran. All rights reserved.
//

#import "OutlineDBFunction.h"
#import "NoteBooks.h"
#import "DBManager.h"

@implementation OutlineDBFunction
//get device ID
-(NSString *)getdeviceID {
    UIDevice *device = [UIDevice currentDevice];
    return[[device identifierForVendor]UUIDString];
}

-(void)deleteRecordFromTable:(NSString *)table WhereId: (NSString*) myid {
    DBManager * sharedDB = [DBManager sharedDBManager];
    sqlite3 *kidzplanDB = [sharedDB getAndLockDatabase];
    char * err = NULL;
    NSString *querySQL = [NSString stringWithFormat: @"PRAGMA foreign_keys = ON"];
    const char *query_stmt = [querySQL UTF8String];
    sqlite3_exec(kidzplanDB, query_stmt, 0, NULL, &err);
    
    querySQL = [NSString stringWithFormat: @"DELETE FROM %@ WHERE id ='%@';", table, myid];
    query_stmt = [querySQL UTF8String];
    sqlite3_exec(kidzplanDB, query_stmt, NULL, NULL, &err);
    [sharedDB unlockDatabase];
    
    NSLog(@"record %@ in table %@ is deleted!!!", myid, table);
}
// ------------------------- Image ------------------------------------

-(BOOL)updateCameraImage:(NSData *)imgData {
    DBManager * sharedDB = [DBManager sharedDBManager];
    sqlite3_stmt *checkstatement;
    sqlite3 *kidzplanDB = [sharedDB getAndLockDatabase];
    BOOL finish = FALSE;
    char * err = NULL;
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE notebooks SET picture = ? WHERE id = '%@';", self.getCurrentNotebook];
    const char *sql = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB, sql, -1, &checkstatement, NULL) == SQLITE_OK) {
        sqlite3_bind_blob(checkstatement, 1, [imgData bytes], [imgData length], SQLITE_STATIC);
    }
    if (sqlite3_step(checkstatement) == SQLITE_DONE) {
        finish = TRUE;
    }
    sqlite3_finalize(checkstatement);
    querySQL = [NSString stringWithFormat:@"UPDATE notebooks SET picture_updated = 'TRUE' WHERE id = %@;",self.getCurrentNotebook];
    sql = [querySQL UTF8String];
    sqlite3_exec(kidzplanDB, sql, NULL, NULL, &err);
    [sharedDB unlockDatabase];
    
    return finish;
}
-(NSData *)getCameraImage {
    DBManager * sharedDB = [DBManager sharedDBManager];
    sqlite3_stmt *statement;
    sqlite3 *kidzplanDB = [sharedDB getAndLockDatabase];
    NSData *blobData;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT picture FROM notebooks WHERE id = '%@';", self.getCurrentNotebook];
    const char *sql = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            const void *blobBytes = sqlite3_column_blob(statement, 0);
            int blobBytesLength = sqlite3_column_bytes(statement, 0); // Count the number of bytes in the BLOB.
            blobData = [NSData dataWithBytes:blobBytes length:blobBytesLength];
        }
    }
    sqlite3_finalize(statement);
    [sharedDB unlockDatabase];
    return blobData;
}
-(NSData *)getCameraImageWithID:(NSString *)bookid {
    DBManager * sharedDB = [DBManager sharedDBManager];
    sqlite3_stmt *statement;
    sqlite3 *kidzplanDB = [sharedDB getAndLockDatabase];
    NSData *blobData;
    
    
    NSString *querySQL = [NSString stringWithFormat: @"SELECT picture FROM notebooks WHERE id = '%@';", bookid];
    const char *sql = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            const void *blobBytes = sqlite3_column_blob(statement, 0);
            int blobBytesLength = sqlite3_column_bytes(statement, 0); // Count the number of bytes in the BLOB.
            blobData = [NSData dataWithBytes:blobBytes length:blobBytesLength];
        }
    }
    sqlite3_finalize(statement);
    [sharedDB unlockDatabase];
    
    return blobData;
}
-(BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}
-(BOOL)checkNotebookNameExist:(NSString *)name {
    DBManager * sharedDB = [DBManager sharedDBManager];
    BOOL success = FALSE;
    NSString * getIdQuery;
    if ([self.getCurrentNotebook length] == 0) {
        getIdQuery = [NSString stringWithFormat: @"SELECT book_name FROM notebooks WHERE book_name='%@' AND user_id ='%@'",name, self.getCurrentUser];
    } else {
        getIdQuery = [NSString stringWithFormat: @"SELECT book_name FROM notebooks WHERE book_name='%@' AND user_id ='%@' AND notebooks_id != '%@'",name, self.getCurrentUser, self.getCurrentNotebook];
    }
    sqlite3_stmt *checkstatement;
    
    const char *query_stmt = [getIdQuery UTF8String];
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        if (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            success = TRUE;
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    return success;
}

-(int)getAfterMaxIDFromTable:(NSString *)tname {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT MAX(id) FROM %@", tname];
    NSString *idtext = [sharedDB getSingletonWithSelectQuery:querySQL];
    if ([idtext length] == 0) {
        idtext = @"0";
    }
    return idtext.intValue + 1;
}

-(NSString *)getTableIdByQuery:(NSString *)getIdQuery {
    DBManager * sharedDB = [DBManager sharedDBManager];
    return [sharedDB getSingletonWithSelectQuery:getIdQuery];
}

-(NSMutableArray *)getNotebooks {
    DBManager * sharedDB = [DBManager sharedDBManager];
    //NSMutableArray *allBooks = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT * FROM notebooks WHERE user_id='%@'",self.getCurrentUser]];
    NSMutableArray *allBooks = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *checkstatement;
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    OutlineDBFunction *function = [[OutlineDBFunction alloc]init];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM notebooks WHERE user_id = '%@';", self.getCurrentUser];
    const char *query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            NSMutableDictionary *oneRecord = [[NSMutableDictionary alloc] init];
            
            NSString *bookid = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 0)];
            NSString *bookstatus = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 1)];
            NSString *bookname = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 2)];
            NSString *age = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 3)];
            NSString *tokens = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 4)];
            [sharedDB unlockDatabase];
            NSData* mypicture = [function getCameraImageWithID:bookid];
            [sharedDB getAndLockDatabase];
            [oneRecord setObject:bookid forKey:@"id"];
            [oneRecord setObject:bookstatus forKey:@"book_status"];
            [oneRecord setObject:bookname forKey:@"book_name"];
            [oneRecord setObject:age  forKey:@"age"];
            [oneRecord setObject:tokens forKey:@"tokens"];
            [oneRecord setObject:mypicture forKey:@"picture"];
            
            [allBooks addObject:oneRecord];
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    return allBooks;
}

// Get good behaviors ------------------------------------------------------------
-(NSMutableArray *)getGoodBehaviors{
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT id, bhname FROM goodbehaviors WHERE notebooks_id = '%@';",self.getCurrentNotebook]];
    return table;
}
// Get good behaviors lastest
-(NSMutableArray *)getGoodBehaviorsLastest{
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT * FROM goodbehaviors WHERE notebooks_id = '%@' AND date = (SELECT DISTINCT(date) FROM goodbehaviors ORDER BY date DESC LIMIT 1);", self.getCurrentNotebook]];
    return table;
}

-(NSMutableArray *) getGoodBehaviorsBeforeTo: (NSString *) date {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString * querry = [NSString stringWithFormat: @"SELECT * FROM goodbehaviors WHERE notebooks_id = '%@' AND date = (SELECT DISTINCT(date) FROM goodbehaviors WHERE date >= '%@' ORDER BY date ASC LIMIT 1);", self.getCurrentNotebook, date];
    NSMutableArray *table = [sharedDB selectQuery:querry];
    return table;
}

// Get bad behaviors ------------------------------------------------------------
-(NSMutableArray *)getBadBehaviors {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT id, name, reminders FROM badbehaviors WHERE notebooks_id = '%@';",self.getCurrentNotebook]];
    return table;
}
// Get bad behaviors lastest
-(NSMutableArray *)getBadBehaviorsLastest{
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT * FROM badbehaviors WHERE notebooks_id = '%@' AND date = (SELECT DISTINCT(date) FROM badbehaviors ORDER BY date DESC LIMIT 1);", self.getCurrentNotebook]];
    return table;
}

-(NSMutableArray *) getBadBehaviorsBeforeTo: (NSString *) date {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString * querry = [NSString stringWithFormat: @"SELECT * FROM badbehaviors WHERE notebooks_id = '%@' AND date = (SELECT DISTINCT(date) FROM badbehaviors WHERE date >= '%@' ORDER BY date ASC LIMIT 1);", self.getCurrentNotebook, date];
    NSMutableArray *table = [sharedDB selectQuery:querry];
    return table;
}

// Get behaviors to change ------------------------------------------------------------
-(NSMutableArray *)getChangeBehaviors {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT CB.id AS id, BB.name AS badBehavior_name, CB.bhname AS bhname FROM badbehaviors BB, changebehaviors CB WHERE CB.badbh_id = BB.id AND BB.notebooks_id = '%@';",self.getCurrentNotebook]];
    return table;
}
-(NSMutableArray *)getChangeBehaviorsDisplay {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT CB.id AS id, BB.name AS badBehavior_name, CB.bhname AS bhname FROM badbehaviors BB, changebehaviors CB WHERE CB.badbh_id = BB.id AND BB.notebooks_id = '%@' AND bhname != 'Less often/Not at all' AND CB.date = (SELECT DISTINCT(date) FROM changebehaviors ORDER BY date DESC LIMIT 1);",self.getCurrentNotebook]];
    return table;
}

-(NSMutableArray *)getAllChangeBehaviors {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT CB.id AS id, BB.name as badBehavior_name, CB.bhname AS bhname FROM badbehaviors BB, changebehaviors CB WHERE CB.badbh_id = BB.id AND BB.notebooks_id = '%@';",self.getCurrentNotebook]];
    return table;
}
// Get change behaviors lastest
-(NSMutableArray *)getChangeBehaviorsLastest{
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT CB.id AS id, BB.name AS badBehavior_name, CB.bhname AS bhname FROM badbehaviors BB, changebehaviors CB WHERE CB.badbh_id = BB.id AND BB.notebooks_id = '%@' AND CB.date = (SELECT DISTINCT(date) FROM changebehaviors ORDER BY date DESC LIMIT 1);", self.getCurrentNotebook]];
    return table;
}

-(NSMutableArray *) getChangeBehaviorsBeforeTo: (NSString *) date {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString * querry = [NSString stringWithFormat: @"SELECT CB.id AS id, BB.name AS badBehavior_name, CB.bhname AS bhname FROM badbehaviors BB, changebehaviors CB WHERE CB.badbh_id = BB.id AND BB.notebooks_id = '%@' AND CB.date = (SELECT DISTINCT(date) FROM changebehaviors WHERE date >= '%@' ORDER BY date ASC LIMIT 1);", self.getCurrentNotebook, date];
    NSMutableArray *table = [sharedDB selectQuery:querry];
    return table;
}


// Get reward times  ------------------------------------------------------------
-(NSMutableArray *)getRewardTime {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT id, timeperiod FROM rewardtime WHERE notebooks_id = '%@';",self.getCurrentNotebook]];
    return table;
}

// Get list of rewards for a given notebook
-(NSMutableArray *)getRewards {
    
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *checkstatement;
    
    NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM rewards WHERE notebooks_id='%@'",self.getCurrentNotebook];
    
    const char *query_stmt = [querySQL UTF8String];
    
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            NSMutableDictionary *oneRecord = [[NSMutableDictionary alloc] init];
            
            NSString *rewards_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 0)];
            NSString *reward_name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 1)];
            NSString *price = @"";
            if (sqlite3_column_type(checkstatement, 2) != SQLITE_NULL) {
                price = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(checkstatement, 2)];
            }
            
            [oneRecord setObject:rewards_id forKey:@"id"];
            [oneRecord setObject:reward_name forKey:@"reward_name"];
            [oneRecord setObject:price forKey:@"price"];
            
            [table  addObject:oneRecord];
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    //NSLog(@"success to get all rewards");
    
    return table;
}

// Get list of saved rewards for a given notebook.
-(NSMutableArray *)getSavedRewards {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [sharedDB selectQuery:[NSString stringWithFormat: @"SELECT * FROM savedreward WHERE notebooks_id='%@' AND reward_status = 'saved'",self.getCurrentNotebook]];
    return table;
}

// ------------------------------------ Redeem -----------------------------------
-(BOOL)SaveRedeemRewards:(NSString *)reward_name andPrice: (int)price andStatus:(NSString *)status when:(NSString *)date {
    DBManager * sharedDB = [DBManager sharedDBManager];
    BOOL success = FALSE;
    NSString *querySQL = [NSString stringWithFormat: @"INSERT INTO savedreward (reward_name, reward_price, notebooks_id, reward_status, date, user_id) VALUES ('%@', '%d','%@', '%@','%@', '%@')", reward_name, price, self.getCurrentNotebook, status, date, self.getCurrentUser];
    success = [sharedDB insertWithQuery:querySQL];
    
    if (success) {
        NoteBooks *book = [[NoteBooks alloc]init];
        querySQL = [NSString stringWithFormat: @"INSERT INTO tokenhistory (date, begin_token, notebooks_id, user_id) VALUES ('%@', '%d', '%@', '%@')", date,[book getTokenBalance],self.getCurrentNotebook, self.getCurrentUser];
        success =  [sharedDB insertWithQuery:querySQL];
    }
    return success;
}
- (BOOL) updateSavedRewardToRedemmedFromID: (NSString*) savedreward_id {
    DBManager * sharedDB = [DBManager sharedDBManager];
    BOOL sucess = FALSE;
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE savedreward SET reward_status = 'redeemed' WHERE id = '%@'",savedreward_id];
    sucess = [sharedDB updateWithQuery:querySQL];
    return sucess;
}
// --------------------------------- Notebook Account Page -----------------------
-(int)getTokenEarnedWhen:(NSString *)date {
    
    DBManager * sharedDB = [DBManager sharedDBManager];
    int token = 0;
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
                    token += 1;
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
                    token += 1;
                }
            }
        }
        sqlite3_finalize(checkstatement);
    }
    
    [sharedDB unlockDatabase];
    
    return token;
}

-(NSMutableArray *)getRewardsRedeemedOrSavedWhen:(NSString *)date {
    
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *checkstatement;
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    
    NSString *querySQL = [NSString stringWithFormat: @"SELECT reward_name, reward_price, reward_status FROM savedreward WHERE notebooks_id='%@' AND date = '%@'",self.getCurrentNotebook, date];
    
    const char *query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            NSMutableDictionary *oneRecord = [[NSMutableDictionary alloc] init];
            
            NSString *reward_name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 0)];
            NSString *price = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 1)];
            NSString *reward_status = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 2)];
            //NSString *date = @"";
            
            [oneRecord setObject:reward_name forKey:@"reward_name"];
            [oneRecord setObject:price forKey:@"price"];
            [oneRecord setObject:reward_status forKey:@"reward_status"];
            
            [table  addObject:oneRecord];
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    //NSLog(@"success to get all saved rewards");
    
    return table;
}

-(int)getBeginningTokenBalanceWhen:(NSString *)date {
    int token = 0;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM tokenhistory WHERE notebooks_id = '%@' AND date <= '%@';", self.getCurrentNotebook, date];
    int count = [[self getTableIdByQuery:querySQL]intValue];
    if (count > 0) {
        querySQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM tokenhistory WHERE date ='%@' AND notebooks_id = '%@';",date, self.getCurrentNotebook];
        count = [[self getTableIdByQuery:querySQL]intValue];
        
        if (count > 0) {
            querySQL = [NSString stringWithFormat: @"SELECT begin_token FROM tokenhistory WHERE date ='%@' AND notebooks_id = '%@';",date, self.getCurrentNotebook];
            token = [[self getTableIdByQuery:querySQL]intValue];
        } else {
            querySQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM tokenhistory WHERE notebooks_id = '%@' AND date > '%@';", self.getCurrentNotebook, date];
            count = [[self getTableIdByQuery:querySQL]intValue];
            
            if (count > 0) {
                querySQL = [NSString stringWithFormat: @"SELECT begin_token FROM tokenhistory WHERE notebooks_id = '%@' AND date > '%@' ORDER BY date ASC;", self.getCurrentNotebook, date];
                token = [[self getTableIdByQuery:querySQL]intValue];
            } else {
                NoteBooks *mybook = [[NoteBooks alloc]init];
                token = [mybook getTokenBalance];
            }
        }
    }
    
    return token;
}

-(NSMutableArray *)getTrackBehaviorWhen:(NSString *)date {
    
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableArray *table = [[NSMutableArray alloc] init];
    sqlite3_stmt *checkstatement;
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT bhname, time1, time2, time3, time4 FROM goodbehaviors G, trackgoodbehaviors T WHERE G.id = T.goodbehaviors_id AND time_record = '%@' AND T.notebooks_id = '%@';",date,self.getCurrentNotebook];
    
    const char *query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            NSMutableDictionary *oneRecord = [[NSMutableDictionary alloc] init];
            
            NSString *bhname = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 0)];
            NSString *time1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 1)];
            NSString *time2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 2)];
            NSString *time3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 3)];
            NSString *time4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 4)];
            
            [oneRecord setObject:bhname forKey:@"bhname"];
            int count = 0;
            if([time1 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            if([time2 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            if([time3 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            if([time4 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            NSString *token = [NSString stringWithFormat:@"%d",count];
            [oneRecord setObject:token  forKey:@"token_earned"];
            
            [table  addObject:oneRecord];
        }
        sqlite3_finalize(checkstatement);
    }
    
    querySQL = [NSString stringWithFormat: @"SELECT bhname, name as badname, time1, time2, time3, time4 FROM changebehaviors C, trackchangebehaviors T, badbehaviors B WHERE C.badbh_id = B.id AND C.id = T.changebehaviors_id AND time_record = '%@' AND T.notebooks_id = '%@';",date,self.getCurrentNotebook];
    
    query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            NSMutableDictionary *oneRecord = [[NSMutableDictionary alloc] init];
            
            NSString *bhname = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 0)];
            NSString *badname = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 1)];
            NSString *time1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 2)];
            NSString *time2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 3)];
            NSString *time3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 4)];
            NSString *time4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 5)];
            
            [oneRecord setObject:bhname forKey:@"bhname"];
            [oneRecord setObject:badname forKey:@"badname"];
            int count = 0;
            if([time1 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            if([time2 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            if([time3 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            if([time4 isEqualToString:@"no-sticker-100px.png"] == FALSE)
                count++;
            NSString *token = [NSString stringWithFormat:@"%d",count];
            [oneRecord setObject:token  forKey:@"token_earned"];
            
            [table  addObject:oneRecord];
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    //NSLog(@"success to get all trackgoodbehaviors");
    return table;
}

// ----------------------------Track Behaviors------------------------------------
-(NSMutableArray *)getTrackGoodBehaviorsWhen:(NSString *)date {
    
    DBManager * sharedDB = [DBManager sharedDBManager];
    //NSMutableArray *array = [self getGoodBehaviorsLastest];
    
    // Updated by Basem
    // We don't need this anymore. I've changed the sql query to do all the work.
    /*
    NSMutableArray *array = [self getGoodBehaviorsBeforeTo:date];
    for (id one in array) {
        [one setValue:@"no-sticker-100px.png" forKey:@"time1"];
        [one setValue:@"no-sticker-100px.png" forKey:@"time2"];
        [one setValue:@"no-sticker-100px.png" forKey:@"time3"];
        [one setValue:@"no-sticker-100px.png" forKey:@"time4"];
    }
    */
    NSMutableArray *table = [[NSMutableArray alloc] init];
    sqlite3_stmt *checkstatement;
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    NSString *querySQL = [NSString stringWithFormat:
                          @"SELECT bhname, ifnull(time1,'no-sticker-100px.png') time1, ifnull(time2,'no-sticker-100px.png') time2, ifnull(time3,'no-sticker-100px.png') time3, ifnull(time4,'no-sticker-100px.png') time4, G.id FROM goodbehaviors G left join trackgoodbehaviors T on G.id = T.goodbehaviors_id and T.time_record = '%@' WHERE G.date  between ( SELECT max(date) FROM goodbehaviors where date <= '%@' AND notebooks_id = '%@') AND '%@' AND G.notebooks_id = '%@' order by G.id",date,date, self.getCurrentNotebook,date,self.getCurrentNotebook];
    
    const char *query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            NSMutableDictionary *oneRecord = [[NSMutableDictionary alloc] init];
            
            NSString *bhname = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 0)];
            NSString *time1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 1)];
            NSString *time2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 2)];
            NSString *time3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 3)];
            NSString *time4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 4)];
            NSString *behID = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 5)];
            
            [oneRecord setObject:behID forKey:@"id"];
            [oneRecord setObject:bhname forKey:@"bhname"];
            [oneRecord setObject:time1  forKey:@"time1"];
            [oneRecord setObject:time2 forKey:@"time2"];
            [oneRecord setObject:time3 forKey:@"time3"];
            [oneRecord setObject:time4 forKey:@"time4"];
            
            [table  addObject:oneRecord];
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    // Updated by Basem
    // We also don't need this after changing the sql query above.
    /*
    if ([table count] > 0) {
        for (id array_obj in array) {
            for (id table_obj in table) {
                if ([array_obj[@"bhname"] isEqualToString:table_obj[@"bhname"]]) {
                    [array_obj setObject:table_obj[@"time1"] forKey:@"time1"];
                    [array_obj setObject:table_obj[@"time2"] forKey:@"time2"];
                    [array_obj setObject:table_obj[@"time3"] forKey:@"time3"];
                    [array_obj setObject:table_obj[@"time4"] forKey:@"time4"];
                }
            }
        }
     }
     return array;
     */
    return table;
}
-(NSMutableArray *)getTrackThingsToDoInsteadWhen:(NSString *)date {
    
    DBManager * sharedDB = [DBManager sharedDBManager];
    
    // Updated by Basem
    // We don't need this anymore. I've changed the sql query to do all the work.
    /*
    NSMutableArray *array = [self getChangeBehaviorsBeforeTo:date];
    for (id one in array) {
        [one setValue:@"no-sticker-100px.png" forKey:@"time1"];
        [one setValue:@"no-sticker-100px.png" forKey:@"time2"];
        [one setValue:@"no-sticker-100px.png" forKey:@"time3"];
        [one setValue:@"no-sticker-100px.png" forKey:@"time4"];
    }
    */
    NSMutableArray *table = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *checkstatement;
    sqlite3 * kidzplanDB = [sharedDB getAndLockDatabase];
    
    NSString *querySQL = [NSString stringWithFormat:
                          @"SELECT BB.name, CB.bhname, ifnull(time1,'no-sticker-100px.png') time1, ifnull(time2,'no-sticker-100px.png') time2, ifnull(time3,'no-sticker-100px.png') time3, ifnull(time4,'no-sticker-100px.png') time4, CB.id FROM badbehaviors BB join changebehaviors CB on CB.badbh_id = BB.id left join trackchangebehaviors TC on TC.changebehaviors_id = CB.id AND time_record = '%@' WHERE BB.date  between ( SELECT max(date) FROM badbehaviors where date <= '%@' AND notebooks_id = '%@') AND '%@' AND BB.notebooks_id = '%@' order by CB.id",date,date, self.getCurrentNotebook,date,self.getCurrentNotebook];
    /*
    NSString *querySQL = [NSString stringWithFormat: @"SELECT BB.name, CB.bhname, time1, time2, time3, time4 FROM badbehaviors BB, trackchangebehaviors TC, changebehaviors CB WHERE TC.changebehaviors_id = CB.id AND CB.badbh_id = BB.id AND time_record = '%@' AND TC.notebooks_id = '%@';",date,self.getCurrentNotebook];
    */
    const char *query_stmt = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            NSMutableDictionary *oneRecord = [[NSMutableDictionary alloc] init];
            
            NSString *badname = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 0)];
            NSString *insteadname = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 1)];
            NSString *time1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 2)];
            NSString *time2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 3)];
            NSString *time3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 4)];
            NSString *time4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 5)];
            NSString *behID = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(checkstatement, 6)];
            
            [oneRecord setObject:behID forKey:@"id"];
            [oneRecord setObject:badname forKey:@"badBehavior_name"];
            [oneRecord setObject:insteadname forKey:@"bhname"];
            [oneRecord setObject:time1  forKey:@"time1"];
            [oneRecord setObject:time2 forKey:@"time2"];
            [oneRecord setObject:time3 forKey:@"time3"];
            [oneRecord setObject:time4 forKey:@"time4"];
            
            [table  addObject:oneRecord];
        }
        sqlite3_finalize(checkstatement);
    }
    [sharedDB unlockDatabase];
    //NSLog(@"success to get all trackchangebehaviors");
    
    // Updated by Basem
    // We also don't need this after changing the sql query above.
    /*
    if ([table count] > 0) {
        for (id array_obj in array) {
            for (id table_obj in table) {
                if ([array_obj[@"badBehavior_name"] isEqualToString:table_obj[@"badname"]] &&
                    [array_obj[@"bhname"] isEqualToString:table_obj[@"insteadname"]]) {
                    [array_obj setObject:table_obj[@"time1"] forKey:@"time1"];
                    [array_obj setObject:table_obj[@"time2"] forKey:@"time2"];
                    [array_obj setObject:table_obj[@"time3"] forKey:@"time3"];
                    [array_obj setObject:table_obj[@"time4"] forKey:@"time4"];
                }
            }
        }
    }
    return array;
     */
    return table;
}
-(BOOL)setTrackGoodBehaviorWithTime:(NSString *)date andGoodBehaviorid:(NSString *)goodBehavior_id andTime1:(NSString *)time1 andTime2:(NSString *)time2 andTime3:(NSString *)time3 andTime4:(NSString *)time4 {
    DBManager * sharedDB = [DBManager sharedDBManager];
    BOOL sucess = FALSE;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM trackgoodbehaviors WHERE goodbehaviors_id = '%@' AND time_record = '%@' AND notebooks_id = '%@'",goodBehavior_id, date, self.getCurrentNotebook];
    NSString *myid = [self getTableIdByQuery:querySQL];
    if ([myid length] == 0) {
        querySQL = [NSString stringWithFormat: @"SELECT id FROM tokenhistory WHERE date = '%@' AND notebooks_id = '%@'", date, self.getCurrentNotebook];
        NSString *tokenid = [self getTableIdByQuery:querySQL];
        if ([tokenid length] == 0) {
            NoteBooks *book = [[NoteBooks alloc]init];
            querySQL = [NSString stringWithFormat: @"INSERT INTO tokenhistory (date, begin_token, notebooks_id) VALUES ('%@', '%d', '%@')", date,[book getTokenBalance],self.getCurrentNotebook];
            sucess = [sharedDB insertWithQuery:querySQL];
        }
        querySQL = [NSString stringWithFormat: @"INSERT INTO trackgoodbehaviors (time_record,notebooks_id,goodbehaviors_id,time1,time2,time3,time4, user_id) VALUES ('%@', %@, %@, '%@', '%@', '%@', '%@', '%@')",date, self.getCurrentNotebook, goodBehavior_id, time1, time2, time3, time4, self.getCurrentUser];
        sucess = [sharedDB insertWithQuery:querySQL];
        return sucess;
    } else {
        querySQL = [NSString stringWithFormat: @"UPDATE trackgoodbehaviors SET time1 = '%@', time2 = '%@', time3 = '%@', time4 = '%@' WHERE id ='%@';", time1, time2, time3, time4, myid];
        sucess = [sharedDB updateWithQuery:querySQL];
        return sucess;
    }
}

-(BOOL)setTrackChangeBehaviorWithTime:(NSString *)date andChangeBehaviorId:(NSString *)changeBehavior_id andTime1:(NSString *)time1 andTime2:(NSString *)time2 andTime3:(NSString *)time3 andTime4:(NSString *)time4 {
    
    DBManager * sharedDB = [DBManager sharedDBManager];
    BOOL sucess = FALSE;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM trackchangebehaviors WHERE changebehaviors_id = '%@' AND time_record = '%@' AND notebooks_id = '%@'",changeBehavior_id, date, self.getCurrentNotebook];
    NSString *myid = [self getTableIdByQuery:querySQL];
    if ([myid length] == 0) {
        querySQL = [NSString stringWithFormat: @"SELECT id FROM tokenhistory WHERE date = '%@' AND notebooks_id = '%@'", date, self.getCurrentNotebook];
        NSString *tokenid = [self getTableIdByQuery:querySQL];
        if ([tokenid length] == 0) {
            NoteBooks *book = [[NoteBooks alloc]init];
            querySQL = [NSString stringWithFormat: @"INSERT INTO tokenhistory (date, begin_token, notebooks_id) VALUES ('%@', %d, %@)", date,[book getTokenBalance],self.getCurrentNotebook];
            sucess = [sharedDB insertWithQuery:querySQL];
        }
        querySQL = [NSString stringWithFormat: @"INSERT INTO trackchangebehaviors (time_record, notebooks_id, changebehaviors_id, time1,time2,time3,time4, user_id) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", date, self.getCurrentNotebook, changeBehavior_id, time1, time2, time3, time4, self.getCurrentUser];
        sucess = [sharedDB insertWithQuery:querySQL];
        return sucess;
    } else {
        querySQL = [NSString stringWithFormat: @"UPDATE trackchangebehaviors SET time1 = '%@', time2 = '%@', time3 = '%@', time4 = '%@' WHERE id ='%@';", time1, time2, time3, time4, myid];
        sucess = [sharedDB updateWithQuery:querySQL];
        return sucess;
    }
}

// ---------------------------------- history table ---------------------------------------------------
-(void)implementHistoryTableWithKey:(NSMutableDictionary *)composKey andType:(BOOL)changeType toTable:(NSString *)tablename {
    DBManager * sharedDB = [DBManager sharedDBManager];
    BOOL success = FALSE;
    // expend table name with _history
    NSString* tablehistory = [NSString stringWithFormat:@"%@_history",tablename];
    // get device_id and user_id from origin table
    NSString* myid = composKey[@"history_id"];
    NSString* deviceid = composKey[@"device_id"];
    NSString* userid = composKey[@"user_id"];
    // get id from history table if it exist
    NSString* querySQL = [NSString stringWithFormat: @"SELECT change_type FROM %@ WHERE id = '%@' AND user_id = '%@' AND device_id = '%@'", tablehistory, myid, userid, deviceid];
    NSString *type = [self getTableIdByQuery:querySQL];
    if ([type length] > 0) {   // did exist
        if ([type boolValue] != changeType) {
            querySQL = [NSString stringWithFormat: @"UPDATE %@ SET change_type = '%hhd' WHERE id = '%@' AND user_id = '%@' AND device_id = '%@'", tablehistory, changeType, myid, userid, deviceid];
            success = [sharedDB updateWithQuery:querySQL];
        }
    } else {                      // not exist
        querySQL = [NSString stringWithFormat: @"INSERT INTO %@ (id, user_id, device_id, change_type) VALUES ('%@', '%@', '%@', '%hhd')", tablehistory, myid, userid, deviceid, changeType];
        success = [sharedDB insertWithQuery:querySQL];
    }
    if (success) NSLog(@"success insert/update into %@_history table", tablename);
    else NSLog(@"failed to insert/update into %@_history table",tablename);
}

@end
