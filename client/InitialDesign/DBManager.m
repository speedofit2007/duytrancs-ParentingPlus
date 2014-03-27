//
//  DBManager.m
//  InitialDesign
//
//  Created by Curtis Ruecker on 2/26/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "DBManager.h"
#import "LocalDatabase.h"
#import <sqlite3.h>

@implementation DBManager

///////////////////
// CLASS METHODS //
///////////////////

+ (id)sharedDBManager {
    static DBManager *sharedDBManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBManager = [[self alloc] init];
    });
    return sharedDBManager;
}

//////////////////////
// INSTANCE METHODS //
//////////////////////

- (id)init {
    if (self = [super init]) {
        LocalDatabase * ldb = [[LocalDatabase alloc] init];
        NSLog(@"DB PATH: %@",[self getDatabasePath]);
        sqlite3 * db = NULL;
        const char *dbpath = [self.getDatabasePath UTF8String];
        self.dblock = [[NSLock alloc] init];
        [self.dblock lock];
        [ldb createLocalDB];
        if (sqlite3_open(dbpath,&db) == SQLITE_OK) {
            self.localDB = db;
        } else {
            NSLog(@"DBManager: ERROR OPENING DATABASE");
        }
        [self.dblock unlock];
    }
    return self;
}

-(NSString *)getDatabasePath {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    return [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"localDB.db"]];
}

-(sqlite3 *) getAndLockDatabase {
    [self.dblock lock];
    return self.localDB;
}

-(void) unlockDatabase {
    [self.dblock unlock];
}

-(BOOL)insertWithQuery:(NSString *)insertQuery {
    BOOL success = FALSE;
    const char *query_stmt = [insertQuery UTF8String];
    char * err;
    [self.dblock lock];
    if (sqlite3_exec(self.localDB, query_stmt, NULL, NULL, &err) == SQLITE_OK)
    {
        NSLog(@"New record added");
        success = TRUE;
    } else {
        NSLog(@"Failed to add new record: %s",err);
    }
    [self.dblock unlock];
    return success;
}

-(BOOL)updateWithQuery:(NSString *)updateQuery {
    BOOL success = FALSE;
    sqlite3_stmt *updateStmt;
    const char *query_stmt = [updateQuery UTF8String];
    [self.dblock lock];
    if(sqlite3_prepare_v2(self.localDB, query_stmt, -1, &updateStmt, NULL) != SQLITE_OK) {
        NSLog(@"Error while creating update statement. %s", sqlite3_errmsg(self.localDB));
    }
    else {
        if (SQLITE_DONE != sqlite3_step(updateStmt)){
            NSAssert1(0, @"Error while updating data. '%s'", sqlite3_errmsg(self.localDB));
        }
        else {
            success = TRUE;
            NSLog(@"update sucessfully");
        }
    }
    [self.dblock unlock];
    return success;
}

-(BOOL)deleteWithQuery:(NSString *)deleteQuery {
    BOOL success = FALSE;
    sqlite3_stmt *updateStmt;
    const char *query_stmt = [deleteQuery UTF8String];
    [self.dblock lock];
    if(sqlite3_prepare_v2(self.localDB, query_stmt, -1, &updateStmt, NULL) != SQLITE_OK) {
        NSLog(@"Error while creating delete statement. %s", sqlite3_errmsg(self.localDB));
    }
    else {
        if (SQLITE_DONE != sqlite3_step(updateStmt)){
            NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(self.localDB));
        }
        else {
            success = TRUE;
            NSLog(@"delete sucessfully");
        }
    }
    [self.dblock unlock];
    return success;
}



-(NSMutableArray *)selectQuery:(NSString *)selectQuery {
    NSMutableArray * result = NULL;
    sqlite3_stmt *selectStmt;
    const char *query_stmt = [selectQuery UTF8String];
    
    [self.dblock lock];
    
    sqlite3_prepare_v2(self.localDB,query_stmt, -1, &selectStmt, NULL);
    result = [self arrayFromSQLite3Stmt:selectStmt];
    sqlite3_finalize(selectStmt);

    [self.dblock unlock];
    return result;
}

-(NSMutableDictionary *)selectFirstWithQuery:(NSString *)selectQuery {
    NSMutableDictionary * result = NULL;
    sqlite3_stmt *selectStmt;
    const char *query_stmt = [selectQuery UTF8String];
    
    [self.dblock lock];
    
    sqlite3_prepare_v2(self.localDB,query_stmt, -1, &selectStmt, NULL);
    if (sqlite3_step(selectStmt) == SQLITE_ROW) {
        result = [self dictFromSQLite3Stmt:selectStmt];
    }
    sqlite3_finalize(selectStmt);
    [self.dblock unlock];
    return result;
}

- (NSString *)getSingletonWithSelectQuery:(NSString *)selectQuery {
    NSString *singleton;
    [self.dblock lock];
    sqlite3_stmt *checkstatement;

    const char *query_stmt = [selectQuery UTF8String];
    const char *value = nil;
    if (sqlite3_prepare_v2(self.localDB,query_stmt, -1, &checkstatement, NULL) == SQLITE_OK)
    {
        if (sqlite3_step(checkstatement) == SQLITE_ROW)
        {
            value = (const char *) sqlite3_column_text(checkstatement, 0);
            if (value != NULL) {
                singleton = [[NSString alloc] initWithUTF8String:value];
            }
        }
        sqlite3_finalize(checkstatement);
    }
    [self.dblock unlock];
    return singleton;
}

- (NSMutableDictionary *)dictFromSQLite3Stmt:(sqlite3_stmt *)stmt {
    if (stmt == nil) {
        return nil;
    }
    const char * col_name = nil;
    const char * col_value = nil;
    NSMutableDictionary * row = [[NSMutableDictionary alloc] init];
    NSString * val = nil;
    for (int i = 0;i < sqlite3_column_count(stmt);i++) {
        col_name = sqlite3_column_name(stmt,i);
        col_value = (const char *)sqlite3_column_text(stmt,i);
        if (sqlite3_column_type(stmt, i) != SQLITE_NULL) {
            val = [NSString stringWithUTF8String:col_value];
            if ([val rangeOfString:@"null"].location != NSNotFound) {
                val = @"";
            }
        } else {
            val = @"";
        }
        [row setObject:val forKey:[NSString stringWithUTF8String:col_name]];
    }
    return row;
}

- (NSMutableArray *) arrayFromSQLite3Stmt:(sqlite3_stmt *)stmt {
    if (stmt == nil) {
        return nil;
    }
    NSMutableArray * records = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        [records addObject:[self dictFromSQLite3Stmt:stmt]];
    }
    return records;
}
                                    
- (void)dealloc {
    // Should never be called
}

@end
