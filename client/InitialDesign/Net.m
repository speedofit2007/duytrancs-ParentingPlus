//
//  Net.m
//  Parenting+
//
//  Created by Curtis Ruecker on 1/20/14.
//  Copyright (c) 2014 Capstone Team B.. All rights reserved.
//

#import "Net.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "Reachability.h"
#import <sqlite3.h>
#import "OutlineDBFunction.h"
#import "DBManager.h"


@implementation Net
/*
    //Deveopment
NSString *const hostname = @"localhost";
NSString *const port = @"3000";
*/

    //Production
NSString *const hostname = @"capstonebb.cs.pdx.edu";
NSString *const port = @"80/r"; //HACK
NSMutableArray * notificationQueue;


///////////////////
// CLASS METHODS //
///////////////////

+ (id)sharedNet {
    static Net *sharedNet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNet = [[self alloc] init];
        NSThread* syncThread = [[NSThread alloc] initWithTarget:sharedNet
                                                     selector:@selector(syncThreadLoop)
                                                       object:nil];
        notificationQueue = [[NSMutableArray alloc] init];
        [syncThread start];
    });
    return sharedNet;
}


//////////////////////
// INSTANCE METHODS //
//////////////////////

- (id)init {
    if (self = [super init]) {
        self.reachability = [Reachability reachabilityWithHostName:hostname];
        [self.reachability startNotifier];
    }
    return self;
}

- (void)dealloc {
    // Should never be called
}

/////////////////////
// SUPPORT METHODS //
/////////////////////

-(void) broadcastNotifications {
    NSNotificationCenter * defaultNotification = [NSNotificationCenter defaultCenter];
    NSDictionary * dict = nil;
    while ([notificationQueue count] > 0) {
        dict = [notificationQueue objectAtIndex:0];
        [defaultNotification postNotificationName:@"sync"
                                           object:self
                                         userInfo:dict];
        [notificationQueue removeObjectAtIndex:0];
    }
}

-(void) setupNotificationForTable:(NSString *)tableName withRecord:(NSDictionary *)record andChangeType:(NSString *)changeType {
    NSArray * dictObjects = @[tableName,changeType,[record objectForKey:@"id"],[record objectForKey:@"user_id"],[record objectForKey:@"device_id"]];
    NSArray * dictKeys = @[@"table",@"change_type",@"id",@"user_id",@"device_id"];
    NSDictionary * userInfoDict = [NSDictionary dictionaryWithObjects:dictObjects
                                                              forKeys:dictKeys];
    [notificationQueue addObject:userInfoDict];
}

/////////////////////
// TESTING METHODS //
/////////////////////

-(void) setUpTestData {
    DBManager * sharedDB = [DBManager sharedDBManager];
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceId = [[device identifierForVendor] UUIDString];
    sqlite3 * localDB = [sharedDB getAndLockDatabase];
    
    NSString * queryString = NULL;
    const char * query_stmt = NULL;
    char * err = NULL;
    queryString = [NSString stringWithFormat:@"DELETE FROM notebooks_history;INSERT INTO notebooks_history VALUES (1,1,'%@',1);",deviceId];
    query_stmt = [queryString UTF8String];
    sqlite3_exec(localDB, query_stmt, NULL, NULL, &err);
    [sharedDB unlockDatabase];
}



////////////////////////
// NETWORKING METHODS //
////////////////////////

- (void)deleteHTTPCookies {
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* httpCookies = [cookies cookiesForURL:
                            [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",hostname]]];
    for (NSHTTPCookie* cookie in httpCookies) {
        [cookies deleteCookie:cookie];
        
        NSLog(@"cookie: %@",cookie);
    }
}

- (BOOL) hasConnection {
    //return NO; // TEMPORARY
    NetworkStatus netStat = [self.reachability currentReachabilityStatus];
    return (netStat == ReachableViaWiFi || netStat == ReachableViaWWAN);
}

-(NSData *) synchronousHttpRequestWithMethod:(NSString *)method andData:(NSString *)data toURL:(NSString *)url {
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLResponse * response = nil;
    [request setHTTPMethod:method];
    if ([method isEqualToString:@"POST"]) {
        [request setValue:[NSString stringWithFormat:@"%ld", (long)[data length]] forHTTPHeaderField:@"Content-length"];
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
}

-(void) httpRequestWithMethod:(NSString *)method andData:(NSString *)data toURL:(NSString *)url andCallback:(void (^)(NSData * replyString,NSError *error))callback {
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
    if ([method isEqualToString:@"POST"]) {
        [request setValue:[NSString stringWithFormat:@"%ld", (long)[data length]] forHTTPHeaderField:@"Content-length"];
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (data == nil) { //If we don't have data for some reason
                                   data = [@"{\"error\": \"Connection error.\"}" dataUsingEncoding:NSUTF8StringEncoding]; //Encode an error message
                               }
                               callback(data,error);
                           }];
}

-(void) requestLoginWithEmail:(NSString *)email andPassword:(NSString *)password andCallback:(void (^)(BOOL success, NSDictionary * data))callback {
    NSString * data = [NSString stringWithFormat:@"user[email]=%@&user[password]=%@",email,password];
    [self httpRequestWithMethod:@"POST"
                        andData:data
                          toURL:[NSString stringWithFormat:@"http://%@:%@/login.json",hostname,port]
                    andCallback:^(NSData * replyData,NSError *error){
                        NSDictionary * loginData = [NSJSONSerialization JSONObjectWithData:replyData options:0 error:nil];
                        if ([loginData objectForKey:@"error"]) {
                            callback(NO,loginData);
                        } else {
                            callback(YES,loginData);
                        }
                    }];
}


-(void) requestLogout {
    [self deleteHTTPCookies];
    [self httpRequestWithMethod:@"POST"
                        andData:nil
                          toURL:[NSString stringWithFormat:@"http://%@:%@/logout.json",hostname,port]
                    andCallback:^(NSData * replyData,NSError *error) {}];
}

-(void) requestSignUpWithEmail:(NSString *)email andFirstName:(NSString *)first_name andLastName:(NSString *)last_name andPassword:(NSString *)password andCallback:(void (^)(BOOL, NSDictionary *))callback {
    NSString * data = [NSString stringWithFormat:@"user[email]=%@&user[first_name]=%@&user[last_name]=%@&user[password]=%@&user[password_confirmation]=%@",email,first_name,last_name,password,password];
    [self httpRequestWithMethod:@"POST"
                        andData:data
                          toURL:[NSString stringWithFormat:@"http://%@:%@/signup.json",hostname,port]
                    andCallback:^(NSData * replyData,NSError *error){
                        NSDictionary * signupData = [NSJSONSerialization JSONObjectWithData:replyData options:0 error:nil];
                        if (signupData == nil || [signupData objectForKey:@"error"] || [signupData objectForKey:@"errors"]) {
                            callback(NO,signupData);
                        } else {
                            callback(YES,signupData);
                        }
                    }];
}


-(BOOL) requestSyncBeginForUserId:(NSString *)userId {
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceId = [[device identifierForVendor] UUIDString];
    NSString * lastSync = [self getLastSyncForUserId:userId];
    NSData * replyData = [self synchronousHttpRequestWithMethod:@"POST"
                                                        andData:[NSString stringWithFormat:@"device_id=%@&last_sync=%@",deviceId,lastSync]
                                                          toURL:[NSString stringWithFormat:@"http://%@:%@/home/syncBegin.json",hostname,port]];
    NSDictionary * reply = [NSJSONSerialization JSONObjectWithData:replyData options:0 error:nil];
    if (reply != nil) {
        return YES;
    } else {
        NSLog(@"SYNC: SyncBegin failure");
        return NO;
    }
    
}

-(BOOL) requestSyncEndForUserId:(NSString *)userId {
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceId = [[device identifierForVendor] UUIDString];
    NSData * replyData = [self synchronousHttpRequestWithMethod:@"POST"
                                                        andData:[NSString stringWithFormat:@"device_id=%@",deviceId]
                                                          toURL:[NSString stringWithFormat:@"http://%@:%@/home/syncEnd.json",hostname,port]];
    NSDictionary * reply = [NSJSONSerialization JSONObjectWithData:replyData options:0 error:nil];
    NSLog(@"SYNC END REPLY: %@",reply);
    if (reply != nil) {
        [self setLastSync:[reply objectForKey:@"last_sync"] forUserId:userId];
        return YES;
    } else {
        NSLog(@"SYNC: SyncEnd failure");
        return NO;
    }
}


//////////////////////////////
// SQL STATEMENT GENERATORS //
//////////////////////////////

-(NSString *) insertStatementForTable:(NSString *)tableName withRecord:(NSDictionary *)record {
    //NSLog(@"Insert generator: record = %@",record);
    if ([tableName isEqualToString:@"notebooks"]) {
        //id INTEGER NOT NULL, book_status TEXT, book_name TEXT, age INTEGER, tokens INTEGER, picture TEXT, date_create DAYTIME, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO notebooks_sync (book_status, book_name, age, tokens, id, user_id, device_id) VALUES ('%@', '%@', '%@', %@, %@, %@, '%@');",
                [record objectForKey:@"book_status"],
                [record objectForKey:@"book_name"],
                [record objectForKey:@"age"],
                [record objectForKey:@"tokens"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"rewards"]) {
        //id INTEGER NOT NULL, reward_name TEXT, price INTEGER, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO rewards_sync (reward_name, price, notebooks_id, notebooks_user_id, notebooks_device_id, id, user_id, device_id) VALUES ('%@', %@, %@, %@, '%@', %@, %@, '%@');",
                [record objectForKey:@"reward_name"],
                [record objectForKey:@"price"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"savedreward"]) {
        //id INTEGER NOT NULL, notebooks_id INTEGER, rewards_id INTEGER, reward_status TEXT, date DAYTIME, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO savedreward_sync (reward_name, notebooks_id, notebooks_user_id, notebooks_device_id, id, user_id, device_id) VALUES ('%@', %@, %@, '%@', %@, %@, '%@');",
                [record objectForKey:@"reward_name"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"goodbehaviors"]) {
        //id INTEGER NOT NULL, bhname TEXT, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO goodbehaviors_sync (bhname, date, notebooks_id, notebooks_user_id, notebooks_device_id, id, user_id, device_id) VALUES ('%@', '%@', %@, %@, '%@', %@, %@, '%@');",
                [record objectForKey:@"bhname"],
                [record objectForKey:@"date"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"changebehaviors"]) {
        //id INTEGER NOT NULL, badbh_id TEXT, bhname TEXT, user_id INTEGER, device_id TEXT,
        return [NSString stringWithFormat:@"INSERT INTO changebehaviors_sync (badbh_id, badbh_user_id, badbh_device_id, notebooks_id, notebooks_user_id, notebooks_device_id, bhname, date, id, user_id, device_id) VALUES ('%@', %@, '%@', %@, %@, '%@', '%@', '%@', %@, %@, '%@');",
                [record objectForKey:@"badbh_id"],
                [record objectForKey:@"badbh_user_id"],
                [record objectForKey:@"badbh_device_id"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"bhname"],
                [record objectForKey:@"date"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"trackgoodbehaviors"]) {
        //id INTEGER NOT NULL, time_record DAYTIME, notebooks_id INTEGER, goodbehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO trackgoodbehaviors_sync (time_record, notebooks_id, notebooks_user_id, notebooks_device_id, goodbehaviors_id, goodbehaviors_user_id, goodbehaviors_device_id, time1, time2, time3, time4, id, user_id, device_id) VALUES ('%@', %@, %@, '%@', %@, %@, '%@', '%@', '%@', '%@', '%@', %@, %@, '%@');",
                [record objectForKey:@"time_record"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"goodbehaviors_id"],
                [record objectForKey:@"goodbehaviors_user_id"],
                [record objectForKey:@"goodbehaviors_device_id"],
                [record objectForKey:@"time1"],
                [record objectForKey:@"time2"],
                [record objectForKey:@"time3"],
                [record objectForKey:@"time4"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"trackchangebehaviors"]) {
        //id INTEGER NOT NULL, time_record DAYTIME, notebooks_id INTEGER, changebehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO trackchangebehaviors_sync (time_record, notebooks_id, notebooks_user_id, notebooks_device_id, changebehaviors_id, changebehaviors_user_id, changebehaviors_device_id, time1, time2, time3, time4, id, user_id, device_id) VALUES ('%@', %@, %@, '%@', %@, %@, '%@', '%@', '%@', '%@', '%@', %@, %@, '%@');",
                [record objectForKey:@"time_record"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"changebehaviors_id"],
                [record objectForKey:@"changebehaviors_user_id"],
                [record objectForKey:@"changebehaviors_device_id"],
                [record objectForKey:@"time1"],
                [record objectForKey:@"time2"],
                [record objectForKey:@"time3"],
                [record objectForKey:@"time4"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"badbehaviors"]) {
        //id INTEGER NOT NULL, name TEXT, reminders TEXT, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO badbehaviors_sync (name, reminders, date, notebooks_id, notebooks_user_id, notebooks_device_id, id, user_id, device_id) VALUES ('%@', '%@', '%@', %@, %@, '%@', %@, %@, '%@');",
                [record objectForKey:@"name"],
                [record objectForKey:@"reminders"],
                [record objectForKey:@"date"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"rewardtime"]) {
        //id INTEGER NOT NULL, timeperiod TEXT, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO rewardtime_sync (timeperiod, notebooks_id, notebooks_user_id, notebooks_device_id, id, user_id, device_id) VALUES ('%@', %@, %@, '%@', %@, %@, '%@');",
                [record objectForKey:@"timeperiod"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"tokenhistory"]) {
        //id INTEGER NOT NULL, date DAYTIME, begin_token INTEGER, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"INSERT INTO tokenhistory_sync (date, begin_token, notebooks_id, notebooks_user_id, notebooks_device_id, id, user_id, device_id) VALUES ('%@', %@, %@, %@, '%@', %@, %@, '%@');",
                [record objectForKey:@"date"],
                [record objectForKey:@"begin_token"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"notebooks_user_id"],
                [record objectForKey:@"notebooks_device_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else {
        return nil;
    }
}

-(NSString *) updateStatementForTable:(NSString *)tableName withRecord:(NSDictionary *)record {
    if ([tableName isEqualToString:@"notebooks"]) {
        //id INTEGER NOT NULL, book_status TEXT, book_name TEXT, age INTEGER, tokens INTEGER, picture TEXT, date_create DAYTIME, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE notebooks_sync SET book_status = '%@', book_name = '%@', age = '%@', tokens = %@ WHERE id = %@;",
                [record objectForKey:@"book_status"],
                [record objectForKey:@"book_name"],
                [record objectForKey:@"age"],
                [record objectForKey:@"tokens"],
                [record objectForKey:@"id"]];
    } else if ([tableName isEqualToString:@"rewards"]) {
        //id INTEGER NOT NULL, reward_name TEXT, price INTEGER, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE rewards_sync SET reward_name = '%@', price = %@, notebooks_id = %@ WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"reward_name"],
                [record objectForKey:@"price"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"savedreward"]) {
        //id INTEGER NOT NULL, notebooks_id INTEGER, rewards_id INTEGER, reward_status TEXT, date DAYTIME, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE savedreward_sync SET reward_name = '%@', price = %@, notebooks_id = %@ WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"reward_name"],
                [record objectForKey:@"price"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"goodbehaviors"]) {
        //id INTEGER NOT NULL, bhname TEXT, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE goodbehaviors_sync SET bhname = '%@', date = '%@', notebooks_id = %@ WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"bhname"],
                [record objectForKey:@"date"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"changebehaviors"]) {
        //id INTEGER NOT NULL, badbh_id TEXT, bhname TEXT, user_id INTEGER, device_id TEXT,
        return [NSString stringWithFormat:@"UPDATE changebehaviors_sync SET badbh_id = '%@', bhname = '%@', date = '%@' WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"badbh_id"],
                [record objectForKey:@"bhname"],
                [record objectForKey:@"date"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"trackgoodbehaviors"]) {
        //id INTEGER NOT NULL, time_record DAYTIME, notebooks_id INTEGER, goodbehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE trackgoodbehaviors_sync SET time_record = '%@', notebooks_id = %@, goodbehaviors_id = %@, time1 = '%@', time2 = '%@', time3 = '%@', time4 = '%@' WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"time_record"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"goodbehaviors_id"],
                [record objectForKey:@"time1"],
                [record objectForKey:@"time2"],
                [record objectForKey:@"time3"],
                [record objectForKey:@"time4"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"trackchangebehaviors"]) {
        //id INTEGER NOT NULL, time_record DAYTIME, notebooks_id INTEGER, changebehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE trackchangebehaviors_sync SET time_record = '%@', notebooks_id = %@, changebehaviors_id = %@, time1 = '%@', time2 = '%@', time3 = '%@', time4 = '%@' WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"time_record"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"changebehaviors_id"],
                [record objectForKey:@"time1"],
                [record objectForKey:@"time2"],
                [record objectForKey:@"time3"],
                [record objectForKey:@"time4"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"badbehaviors"]) {
        //id INTEGER NOT NULL, name TEXT, reminders TEXT, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE badbehaviors_sync SET name = '%@', date = '%@', reminders = '%@', notebooks_id = %@ WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"name"],
                [record objectForKey:@"date"],
                [record objectForKey:@"reminders"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"rewardtime"]) {
        //id INTEGER NOT NULL, timeperiod TEXT, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE rewardtime_sync SET timeperiod = '%@', notebooks_id = %@ WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"timeperiod"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else if ([tableName isEqualToString:@"tokenhistory"]) {
        //id INTEGER NOT NULL, date DAYTIME, begin_token INTEGER, notebooks_id INTEGER, user_id INTEGER, device_id TEXT
        return [NSString stringWithFormat:@"UPDATE tokenhistory_sync SET date = '%@', begin_token = %@, notebooks_id = %@ WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
                [record objectForKey:@"date"],
                [record objectForKey:@"begin_token"],
                [record objectForKey:@"notebooks_id"],
                [record objectForKey:@"id"],
                [record objectForKey:@"user_id"],
                [record objectForKey:@"device_id"]];
    } else {
        return nil;
    }
}

-(NSString *) deleteStatementForTable:(NSString *)tableName withRecord:(NSDictionary *)record {
    return [NSString stringWithFormat:@"DELETE FROM %@_sync WHERE id=%@ AND user_id=%@ AND device_id='%@';",
            tableName,
            [record objectForKey:@"id"],
            [record objectForKey:@"user_id"],
            [record objectForKey:@"device_id"]];
}

-(NSString *) selectStatementForTable:(NSString *)tableName withRecord:(NSDictionary *)record {
    return [NSString stringWithFormat:@"SELECT * FROM %@_sync WHERE id = %@ AND user_id = %@ AND device_id = '%@';",
            tableName,
            [record objectForKey:@"id"],
            [record objectForKey:@"user_id"],
            [record objectForKey:@"device_id"]];
}


//////////////////////
// DATABASE METHODS //
//////////////////////

-(BOOL)updateImage:(NSData *)imgData forNotebookId:(NSString *)notebookId {
    DBManager * sharedDB = [DBManager sharedDBManager];
    sqlite3_stmt *checkstatement;
    sqlite3 *kidzplanDB = [sharedDB getAndLockDatabase];
    BOOL finish = FALSE;
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE notebooks SET picture = ? WHERE id = '%@';", notebookId];
    const char *sql = [querySQL UTF8String];
    
    if (sqlite3_prepare_v2(kidzplanDB, sql, -1, &checkstatement, NULL) == SQLITE_OK) {
        sqlite3_bind_blob(checkstatement, 1, [imgData bytes], [imgData length], SQLITE_STATIC);
    }
    if (sqlite3_step(checkstatement) == SQLITE_DONE) {
        finish = TRUE;
    }
    sqlite3_finalize(checkstatement);
    [sharedDB unlockDatabase];
    
    return finish;
}

-(NSString *) getLastSyncForUserId:(NSString *)userId {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString * querySQL = [NSString stringWithFormat:@"SELECT last_sync FROM users WHERE id = %@;",userId];
    return [sharedDB getSingletonWithSelectQuery:querySQL];
}

-(BOOL) setLastSync:(NSString *)last_sync forUserId:(NSString *)userId {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString * querySQL = [NSString stringWithFormat:@"UPDATE users SET last_sync = '%@' WHERE id = %@;",last_sync,userId];
    return [sharedDB updateWithQuery:querySQL];
}

-(NSArray *) getUpdatedForTable:(NSString *)tableName forUserId:(NSString *)userId {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSArray * history = nil;
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@_sync t JOIN %@_history h ON t.id = h.id WHERE h.change_type = 0 AND h.user_id = %@;",tableName,tableName,userId];
    history = [sharedDB selectQuery:querySQL];
    return history;
}
-(NSArray *) getDeletedForTable:(NSString *)tableName forUserId:(NSString *)userId {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSArray * history = nil;
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@_history WHERE change_type = 1 AND user_id = %@;",tableName,userId];
    history = [sharedDB selectQuery:querySQL];
    return history;
}

-(BOOL) clearHistoryForTable:(NSString *)tableName forUserId:(NSString *)userId {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString * queryString = NULL;
    const char * query_stmt = NULL;
    char * err = NULL;
    queryString = [NSString stringWithFormat:@"DELETE FROM %@_history WHERE user_id = %@;",tableName,userId];
    query_stmt = [queryString UTF8String];
    sqlite3 * localDB = [sharedDB getAndLockDatabase];
    if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) == SQLITE_OK) {
        [sharedDB unlockDatabase];
        return YES;
    } else {
        [sharedDB unlockDatabase];
        return NO;
        NSLog(@"SYNC: clearHistory error status %s",err);
    }
}

//////////////////
// SYNC METHODS //
//////////////////

-(BOOL) synchronizePhotosForUserId:(NSString *)userId {
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceId = [[device identifierForVendor] UUIDString];
    DBManager * sharedDB = [DBManager sharedDBManager];
    OutlineDBFunction * outDB = [[OutlineDBFunction alloc] init];
    NSMutableArray * notebooksWithNewPhotos = [sharedDB selectQuery:[NSString stringWithFormat:@"SELECT n.id AS local_id,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id FROM notebooks n JOIN key_map k ON k.tablename = 'notebooks' AND k.id = n.id WHERE n.user_id = %@ AND picture_updated = 'TRUE';",userId]];
    NSMutableArray * push = [[NSMutableArray alloc] init];
    for (id obj in notebooksWithNewPhotos) {
        NSData * photoData = [outDB getCameraImageWithID:[obj objectForKey:@"local_id"]];
        NSString * photoString = [photoData base64EncodedStringWithOptions:0];
        NSDictionary * notebook = [[NSDictionary alloc]
                                   initWithObjects:@[[obj objectForKey:@"id"],[obj objectForKey:@"user_id"],[obj objectForKey:@"device_id"],photoString]
                                   forKeys:@[@"id",@"user_id",@"device_id",@"picture"]];
        [push addObject:notebook];
    }
    
    NSData * pushData = [NSJSONSerialization dataWithJSONObject:push options:0 error:nil];
    NSString * pushString = [pushData base64EncodedStringWithOptions:0];
    NSData * replyData = [self synchronousHttpRequestWithMethod:@"POST"
                                                        andData:[NSString stringWithFormat:@"device_id=%@&data=%@",deviceId,pushString]
                                                          toURL:[NSString stringWithFormat:@"http://%@:%@/home/syncPhoto.json",hostname,port]];
    NSArray * pullData = [NSJSONSerialization JSONObjectWithData:replyData options:0 error:nil];
    for (id n in pullData) {
        NSString * idQuery = [NSString stringWithFormat:@"SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = %@ AND user_id = %@ AND device_id = '%@'",[n objectForKey:@"id"],[n objectForKey:@"user_id"],[n objectForKey:@"device_id"]];
        NSString * notebookId = [sharedDB getSingletonWithSelectQuery:idQuery];
        NSData * picture = [[NSData alloc] initWithBase64EncodedString:[n objectForKey:@"picture"] options:0];
        [self setupNotificationForTable:@"notebooks" withRecord:n andChangeType:@"update"];
        [self updateImage:picture forNotebookId:notebookId];
    }
    [sharedDB updateWithQuery:[NSString stringWithFormat:@"UPDATE notebooks SET picture_updated = 'FALSE' WHERE user_id = %@;",userId]];
    [self clearHistoryForTable:@"notebooks" forUserId:userId];
    [self broadcastNotifications];
    return YES;
}

-(BOOL) pushTable:(NSString *)tableName forUserId:(NSString *)userId {
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceId = [[device identifierForVendor] UUIDString];
    NSMutableDictionary * push = [[NSMutableDictionary alloc] init];
    NSArray * updated = [self getUpdatedForTable:tableName forUserId:userId];
    NSArray * deleted = [self getDeletedForTable:tableName forUserId:userId];
    if (updated == nil || deleted == nil) {
        NSLog(@"SYNC: Push Error: No updated or deleted array");
        return NO;
    }
    if ([deleted count] > 0) {
        NSLog(@"DELETED ARRAY: %@",deleted);
    }
    [push setObject:updated forKey:@"updated"];
    [push setObject:deleted forKey:@"deleted"];
    NSData * pushData = [NSJSONSerialization dataWithJSONObject:push options:0 error:nil];
    NSString * pushString = [pushData base64EncodedStringWithOptions:0];
    NSData * replyData = [self synchronousHttpRequestWithMethod:@"POST"
                                                        andData:[NSString stringWithFormat:@"object=%@&device_id=%@&data=%@",tableName,deviceId,pushString]
                                                          toURL:[NSString stringWithFormat:@"http://%@:%@/home/push.json",hostname,port]];
    
    NSString * replyString = [[NSString alloc] initWithData:replyData encoding:NSUTF8StringEncoding];
    if ([replyString boolValue] == YES) {
        [self clearHistoryForTable:tableName forUserId:userId];
        return YES;
    } else {
        NSLog(@"SYNC: Push Error: Bad server reply");
        return NO;
    }
}

-(BOOL) pullTable:(NSString *)tableName forUserId:(NSString *)userId {
    LocalDatabase * ldb = [[LocalDatabase alloc] init];
    DBManager * sharedDB = [DBManager sharedDBManager];
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceId = [[device identifierForVendor] UUIDString];
    NSData * replyData = [self synchronousHttpRequestWithMethod:@"POST"
                        andData:[NSString stringWithFormat:@"object=%@&device_id=%@",tableName,deviceId]
                        toURL:[NSString stringWithFormat:@"http://%@:%@/home/pull.json",hostname,port]];
    NSDictionary * pullData = [NSJSONSerialization JSONObjectWithData:replyData options:0 error:nil];
    NSArray * updated = [pullData objectForKey:@"updated"];
    NSArray * deleted = [pullData objectForKey:@"deleted"];
    NSString * queryString = NULL;
    sqlite3_stmt * existsStmt;
    const char *query_stmt = NULL;
    char *err;
    sqlite3 * localDB = [sharedDB getAndLockDatabase];
    query_stmt = "BEGIN TRANSACTION;";
    if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
        NSLog(@"SYNC ERROR: Pull %@, could not begin transaction",tableName);
        [sharedDB unlockDatabase];
        return NO;
    }
    query_stmt = "UPDATE trigger_control SET enable = 'FALSE';";
    if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
        NSLog(@"SYNC ERROR: Pull %@, could not disable triggers",tableName);
        [sharedDB unlockDatabase];
        return NO;
    }
    if (updated != nil && ![updated isKindOfClass:[NSNull class]]) {
        for (id record in updated) { // For each updated record
            // prepare an SQL statement to check if the record already exists
            queryString = [self selectStatementForTable:tableName withRecord:record];
            //NSLog(@"SYNC STATEMENT:%@",queryString);
            query_stmt = [queryString UTF8String];
            if (sqlite3_prepare_v2(localDB,query_stmt, -1, &existsStmt, NULL) == SQLITE_OK) // Execute SELECT statement
            {
                if (sqlite3_step(existsStmt) == SQLITE_ROW) // Record exists, do update
                {
                    // prepare statement to update record
                    queryString = [self updateStatementForTable:tableName withRecord:record];
                    queryString = [queryString stringByReplacingOccurrencesOfString:@"'<null>'" withString:@"null"];
                    queryString = [queryString stringByReplacingOccurrencesOfString:@"<null>" withString:@"null"];
                    //NSLog(@"SYNC STATEMENT:%@",queryString);
                    query_stmt = [queryString UTF8String];
                    if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) { // Execute UPDATE statement
                        NSLog(@"SYNC: Error updating record %s.",err);
                        query_stmt = "COMMIT TRANSACTION;";
                        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
                            NSLog(@"SYNC ERROR: Pull %@, could not end transaction",tableName);
                        }
                        query_stmt = "UPDATE trigger_control SET enable = 'TRUE';";
                        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
                            NSLog(@"SYNC ERROR: Pull %@, could not enable triggers",tableName);
                        }
                        [sharedDB unlockDatabase];
                        return NO;
                        // Error updating record
                    } else {
                        queryString = [NSString stringWithFormat:@"DELETE FROM %@_history WHERE %@_id = %@ AND user_id = %@ AND device_id = %@;",tableName,tableName,[record objectForKey:@"id"],[record objectForKey:@"user_id"],[record objectForKey:@"device_id"]];
                        query_stmt = [queryString UTF8String];
                        sqlite3_exec(localDB, query_stmt, NULL, NULL, &err);
                        [self setupNotificationForTable:tableName withRecord:record andChangeType:@"update"];
                    }
                } else { // Record does not exist, do insert
                    // prepare statement to insert record
                    queryString = [self insertStatementForTable:tableName withRecord:record];
                    queryString = [queryString stringByReplacingOccurrencesOfString:@"'<null>'" withString:@"null"];
                    queryString = [queryString stringByReplacingOccurrencesOfString:@"<null>" withString:@"null"];
                    //NSLog(@"SYNC STATEMENT:%@",queryString);
                    query_stmt = [queryString UTF8String];
                    if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) { //Execute INSERT statement
                        NSLog(@"SYNC: Error inserting record. %s",err);
                        query_stmt = "COMMIT TRANSACTION;";
                        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
                            NSLog(@"SYNC ERROR: Pull %@, could not end transaction",tableName);
                        }
                        query_stmt = "UPDATE trigger_control SET enable = 'TRUE';";
                        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
                            NSLog(@"SYNC ERROR: Pull %@, could not enable triggers",tableName);
                        }
                        [sharedDB unlockDatabase];
                        return NO;
                    } else {
                        [self setupNotificationForTable:tableName withRecord:record andChangeType:@"insert"];
                    }
                }
                sqlite3_finalize(existsStmt);
            } else {
                NSLog(@"SYNC: Error in select statement %s", err);
            }
        }
    } else {
        NSLog(@"SYNC: Error: No updated array");
        query_stmt = "COMMIT TRANSACTION;";
        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
            NSLog(@"SYNC ERROR: Pull %@, could not end transaction",tableName);
        }
        query_stmt = "UPDATE trigger_control SET enable = 'TRUE';";
        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
            NSLog(@"SYNC ERROR: Pull %@, could not enable triggers",tableName);
        }
        [sharedDB unlockDatabase];
        [ldb autoLoginandCallback:^(BOOL hack) {}];
        return NO;
    }
    if (deleted != nil && ![deleted isKindOfClass:[NSNull class]]) {
        for (id record in deleted) { // for each record to be deleted
            // prepare an SQL statement to delete the record
            queryString = [self deleteStatementForTable:tableName withRecord:record];
            queryString = [queryString stringByReplacingOccurrencesOfString:@"'<null>'" withString:@"null"];
            queryString = [queryString stringByReplacingOccurrencesOfString:@"<null>" withString:@"null"];
            NSLog(@"SYNC STATEMENT:%@",queryString);
            query_stmt = [queryString UTF8String];
            if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) { // Execute DELETE statement
                NSLog(@"SYNC: Error deleting record.");
                query_stmt = "COMMIT TRANSACTION;";
                if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
                    NSLog(@"SYNC ERROR: Pull %@, could not end transaction",tableName);
                }
                query_stmt = "UPDATE trigger_control SET enable = 'TRUE';";
                if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
                    NSLog(@"SYNC ERROR: Pull %@, could not enable triggers",tableName);
                }
                [sharedDB unlockDatabase];
                return NO;
            } else {
                [self setupNotificationForTable:tableName withRecord:record andChangeType:@"delete"];
            }
        }
    } else {
        NSLog(@"SYNC: Error: No deleted array");
        query_stmt = "COMMIT TRANSACTION;";
        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
            NSLog(@"SYNC ERROR: Pull %@, could not end transaction",tableName);
        }
        query_stmt = "UPDATE trigger_control SET enable = 'TRUE';";
        if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
            NSLog(@"SYNC ERROR: Pull %@, could not enable triggers",tableName);
        }
        [sharedDB unlockDatabase];
        return NO;
    }
    query_stmt = "COMMIT TRANSACTION;";
    if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
        NSLog(@"SYNC ERROR: Pull %@, could not end transaction",tableName);
    }
    query_stmt = "UPDATE trigger_control SET enable = 'TRUE';";
    if (sqlite3_exec(localDB, query_stmt, NULL, NULL, &err) != SQLITE_OK) {
        NSLog(@"SYNC ERROR: Pull %@, could not enable triggers",tableName);
    }
    [sharedDB unlockDatabase];
    return YES;
}

-(BOOL) syncTable:(NSString *)tableName forUserId:(NSString *)userId {
    return [self pullTable:tableName forUserId:userId] && [self pushTable:tableName forUserId:userId];
}

-(void) syncDatabase {
    OutlineDBFunction * ldb = [[OutlineDBFunction alloc] init];
    NSString * currentUser = [ldb getCurrentUser];
    NSLog(@"SYNC: currentUser = %@",currentUser);
    if ([self hasConnection] && currentUser != nil) {
        if (
            [self requestSyncBeginForUserId:currentUser] &&
            [self syncTable:@"notebooks" forUserId:currentUser] &&
            [self synchronizePhotosForUserId:currentUser] &&
            [self syncTable:@"badbehaviors" forUserId:currentUser] &&
            [self syncTable:@"rewards" forUserId:currentUser] &&
            [self syncTable:@"savedreward" forUserId:currentUser] &&
            [self syncTable:@"goodbehaviors" forUserId:currentUser] &&
            [self syncTable:@"changebehaviors" forUserId:currentUser] &&
            [self syncTable:@"trackgoodbehaviors" forUserId:currentUser] &&
            [self syncTable:@"trackchangebehaviors" forUserId:currentUser] &&
            [self syncTable:@"rewardtime" forUserId:currentUser] &&
            [self syncTable:@"tokenhistory" forUserId:currentUser] &&
            [self requestSyncEndForUserId:currentUser]
            )
        {
            NSLog(@"SYNC: Successful sync.");
        } else {
            NSLog(@"SYNC: Sync failure.");
        }
        [self broadcastNotifications];
    }
}

-(void) syncThreadLoop {
    while (YES) {
        [self syncDatabase];
        [NSThread sleepForTimeInterval:5.0f]; //Sleep for 10 seconds between sync attempts
    }
}


@end