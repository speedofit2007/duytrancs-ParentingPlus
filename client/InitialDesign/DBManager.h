//
//  DBManager.h
//  InitialDesign
//
//  Created by Curtis Ruecker on 2/26/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
@property (strong, nonatomic) NSLock * dblock;
@property sqlite3 * localDB;
+ (id)sharedDBManager;
-(sqlite3 *) getAndLockDatabase;
-(void) unlockDatabase;
-(NSMutableArray *)selectQuery:(NSString *)selectQuery;
-(NSMutableDictionary *)selectFirstWithQuery:(NSString *)selectQuery;
- (NSString *)getSingletonWithSelectQuery:(NSString *)selectQuery;
-(BOOL)updateWithQuery:(NSString *)updateWithQuery;
-(BOOL)insertWithQuery:(NSString *)insertQuery;
-(BOOL)deleteWithQuery:(NSString *)deleteQuery;
@end
