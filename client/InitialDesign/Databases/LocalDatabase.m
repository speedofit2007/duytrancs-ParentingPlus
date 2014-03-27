//
//  LocalDatabase.m
//  DatabaseModule
//
//  Created by Duy Tran on 12/15/13.
//  Copyright (c) 2013 Capstone Team B. All rights reserved.
//

#import "LocalDatabase.h"
#import "OutlineDBFunction.h"
#import "Net.h"
#import "DBManager.h"

static NSString *databasePath;
static NSString *currentUser;
static NSString *currentNotebook;
static NSString *currDate;
BOOL serverRequest;

@implementation LocalDatabase

-(void)Logout {
    currentUser = @"";
    currentNotebook = @"";
    DBManager * sharedDB = [DBManager sharedDBManager];
    Net * sharedNet = [Net sharedNet];
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE users SET log_type = '0';"];
    [sharedDB updateWithQuery:querySQL];
    if ([sharedNet hasConnection]) {
        [sharedNet requestLogout];
    }
    NSLog(@"The current user logged out");
}

-(void)autoLoginandCallback:(void (^)(BOOL))callback {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM users WHERE log_type = '1';"];
    NSDictionary * user = [sharedDB selectFirstWithQuery:querySQL];
    NSLog(@"User = %@",user);
    Net * sharedNet = [Net sharedNet];
    if (user == nil) {
        callback(NO);
        return;
    }
    if ([sharedNet hasConnection]) {
        NSLog(@"LOGIN: Using server.");
        NSString * username = [user objectForKey:@"email"];
        NSString * password = [user objectForKey:@"password"];
        [sharedNet requestLoginWithEmail:username andPassword:password andCallback:^(BOOL success, NSDictionary *data) {
            NSLog(@"LOGIN: Server data: %@",data);
            if (success) {
                currentUser = [data objectForKey:@"id"];
                NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM users WHERE id='%@'",currentUser];
                NSString *userId = [[sharedDB selectFirstWithQuery:querySQL] objectForKey:@"id"];
                if ([userId length] > 0) {
                    //Update database, user already exists
                    querySQL = [NSString stringWithFormat:@"UPDATE users SET first_name = '%@', last_name = '%@', email = '%@', password = '%@' WHERE id = '%@';",[data objectForKey:@"first_name"],[data objectForKey:@"last_name"],[data objectForKey:@"email"],password,currentUser];
                    [sharedDB updateWithQuery:querySQL];
                } else {
                    //Insert into database, user doesn't exist
                    querySQL = [NSString stringWithFormat:@"INSERT INTO users (id,first_name,last_name,email,password) VALUES (%@,'%@','%@','%@','%@');",[data objectForKey:@"id"],[data objectForKey:@"first_name"],[data objectForKey:@"last_name"],[data objectForKey:@"email"],password];
                    [sharedDB insertWithQuery:querySQL];
                }
            } else { //Invalid login
                NSString *querySQL = [NSString stringWithFormat: @"UPDATE users SET log_type = '0';"];
                [sharedDB updateWithQuery:querySQL];
            }
            callback(success);
            return;
        }];
    } else {
        currentUser = [user objectForKey:@"id"];
        callback(YES);
        return;
    }
}

-(BOOL)updateFirstLastEmail:(NSString *)first andLast:(NSString *)last andEmail:(NSString *)email {
    DBManager * sharedDB = [DBManager sharedDBManager];
    BOOL success = FALSE;
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE users SET first_name = %@', last_name = '%@', email = '%@' WHERE id = '%@'",first, last, email, [self getCurrentUser]];
    success = [sharedDB updateWithQuery:querySQL];
    return success;
}

-(BOOL)updatePasswordToNew: (NSString *)newPass {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *newPassCript = [self encryptMD5:newPass];
    BOOL success = FALSE;
    NSString *querySQL = [NSString stringWithFormat: @"UPDATE users SET password = '%@' WHERE id = '%@'",newPassCript, [self getCurrentUser]];
    success = [sharedDB updateWithQuery:querySQL];
    return success;
}

-(NSMutableDictionary *)getUserInformation {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSMutableDictionary *user = [sharedDB selectFirstWithQuery:[NSString stringWithFormat:@"SELECT first_name, last_name, email, password FROM users"]];
    return user;
}

//get device ID
-(NSString *)getdeviceID {
    UIDevice *device = [UIDevice currentDevice];
    return[[device identifierForVendor]UUIDString];
}

// implement all basic functions for all static variables
-(void)setCurrentUser:(NSString *)userID {
    currentUser = [NSString stringWithString:userID];
}
-(void)setCurrentNotebook:(NSString *)bookID {
    currentNotebook = [NSString stringWithString:bookID];
}
-(void)setCurrentDate:(NSDate *)date {
    date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    currDate = [dateFormatter stringFromDate:date];
}
-(NSString *)getCurrentUser {
    return currentUser;
}
-(NSString *)getCurrentNotebook {
    return currentNotebook;
}
-(NSString *)getCurrentDate {
    return currDate;
}
-(NSString *)getEmail {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSDictionary * user = [sharedDB selectFirstWithQuery:[NSString stringWithFormat: @"SELECT email FROM users WHERE id ='%@'",self.getCurrentUser]];
    NSString *email = [user objectForKey:@"email"];;
    return email;
}

-(void) deleteCurrentNotebook {
    DBManager * sharedDB = [DBManager sharedDBManager];
    sqlite3 *kidzplanDB = [sharedDB getAndLockDatabase];
    char * err = NULL;
    NSString *querySQL = [NSString stringWithFormat: @"PRAGMA foreign_keys = ON"];
    const char *query_stmt = [querySQL UTF8String];
    sqlite3_exec(kidzplanDB, query_stmt, 0, NULL, &err);
    
    querySQL = [NSString stringWithFormat: @"DELETE FROM notebooks WHERE id ='%@';",self.getCurrentNotebook];
    query_stmt = [querySQL UTF8String];
    sqlite3_exec(kidzplanDB, query_stmt, NULL, NULL, &err);
    [sharedDB unlockDatabase];
    
    NSLog(@"Notebook %@ is deleted!!!", self.getCurrentNotebook);
}

-(void)updateUsersWithEmail:(NSString *)email andPassword:(NSString *)password {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *encryptPass = [self encryptMD5:password];
    [sharedDB updateWithQuery:[NSString stringWithFormat: @"UPDATE users SET email = '%@', password = '%@' WHERE id ='%@';",email, encryptPass, currentUser]];
}

- (NSString *) encryptMD5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

-(void)setDatabasePath {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"localDB.db"]];
}

-(NSString *)getDatabasePath {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    return [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"localDB.db"]];
}

-(void) checkLogin: (NSString *)username andPassword:(NSString *)password andCallback:(void (^)(BOOL, NSString *))callback {
    Net * sharedNet = [Net sharedNet];
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *encryptPass = [self encryptMD5:password];
    if ([sharedNet hasConnection]) {
        NSLog(@"LOGIN: Using server.");
        [sharedNet requestLoginWithEmail:username andPassword:encryptPass andCallback:^(BOOL success, NSDictionary *data) {
            NSString * error = [data objectForKey:@"error"];
            NSLog(@"LOGIN: Server data: %@",data);
            if (success) {
                currentUser = [data objectForKey:@"id"];
                NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM users WHERE id='%@'",currentUser];
                NSString *userId = [[sharedDB selectFirstWithQuery:querySQL] objectForKey:@"id"];
                if ([userId length] > 0) {
                    //Update database, user already exists
                    querySQL = [NSString stringWithFormat:@"UPDATE users SET first_name = '%@', last_name = '%@', email = '%@', password = '%@' WHERE id = '%@';",[data objectForKey:@"first_name"],[data objectForKey:@"last_name"],[data objectForKey:@"email"],encryptPass,currentUser];
                    [sharedDB updateWithQuery:querySQL];
                } else {
                    //Insert into database, user doesn't exist
                    querySQL = [NSString stringWithFormat:@"INSERT INTO users (id,first_name,last_name,email,password) VALUES (%@,'%@','%@','%@','%@');",[data objectForKey:@"id"],[data objectForKey:@"first_name"],[data objectForKey:@"last_name"],[data objectForKey:@"email"],encryptPass];
                    [sharedDB insertWithQuery:querySQL];
                }
                querySQL = [NSString stringWithFormat: @"UPDATE users SET log_type = '0';"];
                [sharedDB updateWithQuery:querySQL];
                querySQL = [NSString stringWithFormat: @"UPDATE users SET log_type = '1' WHERE id = '%@';", currentUser];
                [sharedDB updateWithQuery:querySQL];
            }
            callback(success,error);
        }];
    } else {
        NSLog(@"LOGIN: Using local database.");
        NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM users WHERE email='%@' AND password='%@'",username, encryptPass];
        NSDictionary * user = [sharedDB selectFirstWithQuery:querySQL];
        NSString *userId = [user objectForKey:@"id"];
        if (userId != nil) {
            currentUser = [[NSString alloc] initWithString:userId];
            querySQL = [NSString stringWithFormat: @"UPDATE users SET log_type = '0';"];
            [sharedDB updateWithQuery:querySQL];
            querySQL = [NSString stringWithFormat: @"UPDATE users SET log_type = '1' WHERE id = '%@';", currentUser];
            [sharedDB updateWithQuery:querySQL];
        }
        if ([currentUser length] > 0) {
            callback(YES,nil);
            return;
        } else {
            callback(NO,@"Invalid email or password.");
            return;
        }
    }
}

-(void)signUpNewUser:(NSString *)firstName andLastName:(NSString *)lastName andEmail:(NSString *)username andPassword:(NSString *)password andCallback:(void (^)(BOOL, NSArray *))callback {
    Net * sharedNet = [Net sharedNet];
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *encryptPass = [self encryptMD5:password];
    if ([sharedNet hasConnection]) {
        [sharedNet requestSignUpWithEmail:username andFirstName:firstName andLastName:lastName andPassword:encryptPass andCallback:^(BOOL success, NSDictionary *data) {
            if (success == YES) {
                NSLog(@"SERVER: signup successfully. %@",data);
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO users (id, first_name, last_name, email, password) VALUES ('%@', '%@', '%@', '%@', '%@');",[data objectForKey:@"id"], firstName, lastName, username, encryptPass];
                success = [sharedDB insertWithQuery:insertSQL];
                if (success) {
                    NSLog(@"DATABASE: New user added.");
                    callback(YES,nil);
                } else {
                    NSLog(@"DATABASE: Failed to add new user !!!");
                    callback(NO,@[@"Local database error"]);
                }
            } else {
                NSMutableArray * errors = [[NSMutableArray alloc] init];
                if ([data objectForKey:@"error"]) {
                    [errors addObject:[data objectForKey:@"error"]];
                }
                if ([data objectForKey:@"errors"]) {
                    [[data objectForKey:@"errors"] enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
                        [errors addObject:[NSString stringWithFormat:@"%@: %@",key,obj]];
                    }];
                }
                callback(NO,errors);
            }
        }];
    }
}

-(NSString *)getUserID:(NSString *)username andPassword:(NSString *)password {
    DBManager * sharedDB = [DBManager sharedDBManager];
    NSString *encryptPass = [self encryptMD5:password];
    NSDictionary *user = [sharedDB selectFirstWithQuery:[NSString stringWithFormat: @"SELECT id FROM users WHERE email='%@' AND password='%@'",username, encryptPass]];
    return [user objectForKey:@"id"];
}

-(void)createLocalDB{
    sqlite3 * kidzplanDB = NULL;
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"localDB.db"]];
    NSLog(@"CREATE DB: %@",databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:databasePath] == NO) {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &kidzplanDB) == SQLITE_OK) {
            char *err;
            // Create empty table users
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, first_name TEXT, last_name TEXT, email TEXT, password TEXT, log_type BOOL DEFAULT 0, last_sync TEXT)";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table users");
            }
            
            // Create Empty table key_map
            sql_stmt = "CREATE TABLE IF NOT EXISTS key_map (tablename TEXT, id INTEGER, hid INTEGER, user_id INTEGER, device_id TEXT, UNIQUE(tablename, id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table key_map");
            }
            
            // Create Empty table notebooks
            sql_stmt = "CREATE TABLE IF NOT EXISTS notebooks (id INTEGER PRIMARY KEY AUTOINCREMENT,  book_status TEXT, book_name TEXT NOT NULL, age DAYTIME, tokens INTEGER, picture BLOB, date_create DAYTIME, user_id INTEGER, picture_updated BOOL DEFAULT FALSE, FOREIGN KEY(user_id) REFERENCES users(id), UNIQUE (book_name, id, user_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table notebooks");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS notebooks_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table notebooks_history");
            }
            
            // Create empty table rewards
            sql_stmt = "CREATE TABLE IF NOT EXISTS rewards (id INTEGER PRIMARY KEY AUTOINCREMENT, reward_name TEXT NOT NULL, price INTEGER, notebooks_id INTEGER, user_id INTEGER, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, UNIQUE(reward_name, notebooks_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table rewards");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS rewards_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table rewards_history");
            }
            
            // Create Empty table savedreward
            sql_stmt = "CREATE TABLE IF NOT EXISTS savedreward (id INTEGER PRIMARY KEY AUTOINCREMENT, notebooks_id INTEGER, reward_name TEXT, reward_status TEXT, reward_price INTEGER, date DAYTIME, user_id INTEGER, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE)";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table savedreward");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS savedreward_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table savedreward_history");
            }
            
            // Create empty table goodbehaviors
            sql_stmt = "CREATE TABLE IF NOT EXISTS goodbehaviors (id INTEGER PRIMARY KEY AUTOINCREMENT, bhname TEXT NOT NULL, notebooks_id INTEGER, user_id INTEGER, date DAYTIME, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, UNIQUE(bhname, notebooks_id, date))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table goodbehaviors");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS goodbehaviors_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table goodbehaviors_history");
            }
            
            // Create Empty table changebehaviors
            sql_stmt = "CREATE TABLE IF NOT EXISTS changebehaviors (id INTEGER PRIMARY KEY AUTOINCREMENT, badbh_id INTEGER, bhname TEXT NOT NULL, notebooks_id INTEGER, user_id INTEGER, date DAYTIME, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, FOREIGN KEY(badbh_id) REFERENCES badbehaviors(id) ON DELETE CASCADE, UNIQUE (badbh_id, bhname, notebooks_id, date))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table changebehaviors");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS changebehaviors_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table changebehaviors_history");
            }
            
            // Create empty table trackgoodbehaviors
            sql_stmt = "CREATE TABLE IF NOT EXISTS trackgoodbehaviors (id INTEGER PRIMARY KEY AUTOINCREMENT, time_record DAYTIME, notebooks_id INTEGER, goodbehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT, user_id INTEGER, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, FOREIGN KEY(goodbehaviors_id) REFERENCES goodbehaviors(id) ON DELETE CASCADE)";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table trackgoodbehaviors");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS trackgoodbehaviors_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table trackgoodbehaviors_history");
            }
            
            // Create Empty table trackchangebehaviors
            sql_stmt = "CREATE TABLE IF NOT EXISTS trackchangebehaviors (id INTEGER PRIMARY KEY AUTOINCREMENT, time_record DAYTIME, notebooks_id INTEGER, changebehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT, user_id INTEGER, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, FOREIGN KEY(changebehaviors_id) REFERENCES changebehaviors(id) ON DELETE CASCADE)";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table trackchangebehaviors");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS trackchangebehaviors_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table trackchangebehaviors_history");
            }
            
            // Create empty table badbehaviors
            sql_stmt = "CREATE TABLE IF NOT EXISTS badbehaviors (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, reminders TEXT, notebooks_id INTEGER, user_id INTEGER, date DAYTIME, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, UNIQUE (name, notebooks_id, date))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table badbehaviors");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS badbehaviors_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table badbehaviors_history");
            }
            
            // Create empty table rewardtime
            sql_stmt = "CREATE TABLE IF NOT EXISTS rewardtime (id INTEGER PRIMARY KEY AUTOINCREMENT, timeperiod TEXT NOT NULL, notebooks_id INTEGER, user_id INTEGER, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, UNIQUE (timeperiod, notebooks_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table rewardtime");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS rewardtime_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table rewardtime_history");
            }
            
            // Create empty table tokenhistory
            sql_stmt = "CREATE TABLE IF NOT EXISTS tokenhistory (id INTEGER PRIMARY KEY AUTOINCREMENT, date DAYTIME, begin_token INTEGER, notebooks_id INTEGER, user_id INTEGER, FOREIGN KEY(notebooks_id) REFERENCES notebooks(id) ON DELETE CASCADE, UNIQUE (date, notebooks_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table tokenhistory");
            }
            sql_stmt = "CREATE TABLE IF NOT EXISTS tokenhistory_history (id INTEGER, user_id INTEGER, device_id TEXT, change_type BOOLEAN, PRIMARY KEY (id, user_id, device_id))";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table tokenhistory_history");
            }
            
            sql_stmt = "CREATE TABLE IF NOT EXISTS trigger_control (enable BOOL DEFAULT TRUE)";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create table trigger_control");
            }
            sql_stmt = "INSERT INTO trigger_control (enable) VALUEs ('TRUE');";
            sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err);
            
            
            // Create trigger for each sql querry to tables ------------------
            // ---------------------------------------------------------------
            NSMutableArray *mytable = [[NSMutableArray alloc]initWithObjects:@"notebooks", @"rewards", @"savedreward", @"rewardtime", @"goodbehaviors", @"badbehaviors", @"changebehaviors", @"trackgoodbehaviors", @"trackchangebehaviors", @"tokenhistory", nil];
            NSString *mysql;
            for (id table in mytable) {
                mysql = [NSString stringWithFormat:@"CREATE TRIGGER %@_insert AFTER INSERT ON %@ WHEN (SELECT enable FROM trigger_control) == 'TRUE'\
                         BEGIN\
                         INSERT INTO key_map (tablename, id, hid, user_id, device_id) VALUES ('%@', new.id, new.id, new.user_id, '%@');\
                         INSERT INTO %@_history (id, user_id, device_id, change_type) VALUES (new.id, (SELECT id FROM users WHERE log_type = '1'), '%@', '0');\
                         END;", table, table, table, [self getdeviceID], table, [self getdeviceID]];
                sql_stmt = [mysql UTF8String];
                if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                    NSLog(@"Failed to create TRIGGER %@_insert", table);
                    NSLog(@"%s",err);
                }
                
                mysql = [NSString stringWithFormat:@"CREATE TRIGGER %@_update AFTER UPDATE ON %@ WHEN (SELECT enable FROM trigger_control) == 'TRUE'\
                         BEGIN\
                         INSERT OR REPLACE INTO %@_history (id, user_id, device_id, change_type) VALUES ((SELECT hid FROM key_map WHERE tablename = '%@' AND id = new.id), (SELECT user_id FROM key_map WHERE tablename = '%@' AND id = new.id), (SELECT device_id FROM key_map WHERE tablename = '%@' AND id = new.id), '0');\
                         END;", table, table, table, table, table, table];
                sql_stmt = [mysql UTF8String];
                if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                    NSLog(@"Failed to create TRIGGER %@_update", table);
                    NSLog(@"%s",err);
                }
                
                mysql = [NSString stringWithFormat:@"CREATE TRIGGER %@_delete BEFORE DELETE ON %@ WHEN (SELECT enable FROM trigger_control) == 'TRUE'\
                         BEGIN\
                         INSERT OR REPLACE INTO %@_history (id, user_id, device_id, change_type) VALUES ((SELECT hid FROM key_map WHERE tablename = '%@' AND id = old.id), (SELECT user_id FROM key_map WHERE tablename = '%@' AND id = old.id), (SELECT device_id FROM key_map WHERE tablename = '%@' AND id = old.id), '1') ;\
                         END;", table, table, table, table, table, table];
                sql_stmt = [mysql UTF8String];
                if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                    NSLog(@"Failed to create TRIGGER %@_delete", table);
                    NSLog(@"%s",err);
                }
            }
            
            // NOTEBOOKS VIEWS/TRIGGERS
            
            sql_stmt = "CREATE VIEW notebooks_sync AS SELECT n.book_name AS book_name,n.book_status AS book_status,n.age AS age,n.tokens AS tokens,n.date_create AS date_create,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id FROM notebooks n JOIN key_map k ON n.id = k.id AND k.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view notebooks_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER notebook_sync_update \
            INSTEAD OF UPDATE ON notebooks_sync \
            FOR EACH ROW BEGIN \
            UPDATE notebooks SET book_name = new.book_name, book_status = new.book_status, age = new.age, tokens = new.tokens, date_create = new.date_create \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'notebooks'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger notebooks_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER notebook_sync_insert \
            INSTEAD OF INSERT ON notebooks_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO notebooks (book_name,book_status,age,tokens,date_create,user_id) VALUES (new.book_name, new.book_status, new.age, new.tokens, new.date_create, new.user_id); \
            INSERT INTO key_map VALUES ('notebooks',(SELECT max(id) FROM notebooks),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger notebooks_sync_insert");
            }
            
            // REWARDS VIEWS/TRIGGERS
            // id INTEGER PRIMARY KEY AUTOINCREMENT, reward_name TEXT, price INTEGER, notebooks_id INTEGER
            sql_stmt = "CREATE VIEW rewards_sync AS SELECT r.reward_name AS reward_name,r.price AS price,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id,nk.hid AS notebooks_id,nk.user_id AS notebooks_user_id,nk.device_id AS notebooks_device_id FROM rewards r JOIN key_map k ON r.id = k.id AND k.tablename = 'rewards' JOIN key_map nk ON nk.id = r.notebooks_id AND nk.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view rewards_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER rewards_sync_update \
            INSTEAD OF UPDATE ON rewards_sync \
            FOR EACH ROW BEGIN \
            UPDATE rewards SET reward_name = new.reward_name, price = new.price \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'rewards'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger rewards_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER rewards_sync_insert \
            INSTEAD OF INSERT ON rewards_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO rewards (reward_name,price,notebooks_id) VALUES (new.reward_name,new.price,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id)); \
            INSERT INTO key_map VALUES ('rewards',(SELECT max(id) FROM rewards),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger rewards_sync_insert");
            }
            
            // SAVEDREWARD VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, notebooks_id INTEGER, rewards_id INTEGER, reward_status TEXT, date DAYTIME
            sql_stmt = "CREATE VIEW savedreward_sync AS SELECT s.reward_name AS reward_name, s.reward_status AS reward_status,s.date AS date,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id,nk.hid AS notebooks_id,nk.user_id AS notebooks_user_id,nk.device_id AS notebooks_device_id FROM savedreward s JOIN key_map k ON s.id = k.id AND k.tablename = 'savedreward' JOIN key_map nk ON nk.id = s.notebooks_id AND nk.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view savedreward_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER savedreward_sync_update \
            INSTEAD OF UPDATE ON savedreward_sync \
            FOR EACH ROW BEGIN \
            UPDATE savedreward SET reward_status = new.reward_status, date = new.date, reward_name = new.reward_name \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'savedreward'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger savedreward_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER savedreward_sync_insert \
            INSTEAD OF INSERT ON savedreward_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO savedreward (reward_name,reward_status,date,notebooks_id) VALUES (new.reward_name,new.reward_status,new.date,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id)); \
            INSERT INTO key_map VALUES ('savedreward',(SELECT max(id) FROM savedreward),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger savedreward_sync_insert");
            }
            
            // GOODBEHAVIORS VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, bhname TEXT, notebooks_id INTEGER
            sql_stmt = "CREATE VIEW goodbehaviors_sync AS SELECT b.bhname AS bhname, b.date AS date, k.hid AS id,k.user_id AS user_id,k.device_id AS device_id,nk.hid AS notebooks_id,nk.user_id AS notebooks_user_id,nk.device_id AS notebooks_device_id FROM goodbehaviors b JOIN key_map k ON b.id = k.id AND k.tablename = 'goodbehaviors' JOIN key_map nk ON nk.id = b.notebooks_id AND nk.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view goodbehaviors_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER goodbehaviors_sync_update \
            INSTEAD OF UPDATE ON goodbehaviors_sync \
            FOR EACH ROW BEGIN \
            UPDATE goodbehaviors SET bhname = new.bhname, date = new.date\
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'goodbehaviors'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger goodbehaviors_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER goodbehaviors_sync_insert \
            INSTEAD OF INSERT ON goodbehaviors_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO goodbehaviors (bhname,date,notebooks_id) VALUES (new.bhname,new.date,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id)); \
            INSERT INTO key_map VALUES ('goodbehaviors',(SELECT max(id) FROM goodbehaviors),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger goodbehaviors_sync_insert");
            }
            
            // CHANGEBEHAVIORS VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, badbh_id TEXT, bhname TEXT
            sql_stmt = "CREATE VIEW changebehaviors_sync AS SELECT b.bhname AS bhname,b.date AS date,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id,nk.hid AS badbh_id,nk.user_id AS badbh_user_id,nk.device_id AS badbh_device_id,nbk.hid AS notebooks_id,nbk.user_id AS notebooks_user_id,nbk.device_id AS notebooks_device_id FROM changebehaviors b JOIN key_map k ON b.id = k.id AND k.tablename = 'changebehaviors' JOIN key_map nk ON nk.id = b.badbh_id AND nk.tablename = 'badbehaviors' JOIN key_map nbk ON nbk.id = b.notebooks_id AND nbk.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view changebehaviors_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER changebehaviors_sync_update \
            INSTEAD OF UPDATE ON changebehaviors_sync \
            FOR EACH ROW BEGIN \
            UPDATE changebehaviors SET bhname = new.bhname, date = new.date \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'changebehaviors'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger changebehaviors_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER changebehaviors_sync_insert \
            INSTEAD OF INSERT ON changebehaviors_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO changebehaviors (bhname,date,badbh_id) VALUES (new.bhname,new.date,(SELECT id FROM key_map WHERE tablename = 'badbehaviors' AND hid = new.badbh_id AND user_id = new.badbh_user_id AND device_id = new.badbh_device_id)); \
            INSERT INTO key_map VALUES ('changebehaviors',(SELECT max(id) FROM changebehaviors),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger changebehaviors_sync_insert");
            }
            
            // TRACKGOODBEHAVIORS VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, time_record DAYTIME, notebooks_id INTEGER, goodbehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT
            sql_stmt = "CREATE VIEW trackgoodbehaviors_sync AS SELECT t.time_record AS time_record, t.time1 AS time1,t.time2 AS time2,t.time3 AS time3,t.time4 AS time4, k.hid AS id, k.user_id AS user_id, k.device_id AS device_id, nk.hid AS notebooks_id, nk.user_id AS notebooks_user_id, nk.device_id AS notebooks_device_id, gk.hid AS goodbehaviors_id, gk.user_id AS goodbehaviors_user_id, gk.device_id AS goodbehaviors_device_id FROM trackgoodbehaviors t JOIN key_map k ON t.id = k.id AND k.tablename = 'trackgoodbehaviors' JOIN key_map nk ON nk.id = t.notebooks_id AND nk.tablename = 'notebooks' JOIN key_map gk ON gk.id = t.goodbehaviors_id AND gk.tablename = 'goodbehaviors';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view trackgoodbehaviors_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER trackgoodbehaviors_sync_update \
            INSTEAD OF UPDATE ON trackgoodbehaviors_sync \
            FOR EACH ROW BEGIN \
            UPDATE trackgoodbehaviors SET time_record = new.time_record, time1 = new.time1, time2 = new.time2, time3 = new.time3, time4 = new.time4 \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'trackgoodbehaviors'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger trackgoodbehaviors_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER trackgoodbehaviors_sync_insert \
            INSTEAD OF INSERT ON trackgoodbehaviors_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO trackgoodbehaviors (time_record,time1,time2,time3,time4,notebooks_id,goodbehaviors_id) VALUES (new.time_record,new.time1,new.time2,new.time3,new.time4,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id),(SELECT id FROM key_map WHERE tablename = 'goodbehaviors' AND hid = new.goodbehaviors_id AND user_id = new.goodbehaviors_user_id AND device_id = new.goodbehaviors_device_id)); \
            INSERT INTO key_map VALUES ('trackgoodbehaviors',(SELECT max(id) FROM trackgoodbehaviors),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger trackgoodbehaviors_sync_insert");
            }
            
            // TRACKCHANGEBEHAVIORS VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, time_record DAYTIME, notebooks_id INTEGER, changebehaviors_id INTEGER, time1 TEXT, time2 TEXT, time3 TEXT, time4 TEXT
            sql_stmt = "CREATE VIEW trackchangebehaviors_sync \
            AS SELECT \
            t.time_record AS time_record, \
            t.time1 AS time1,t.time2 AS time2,t.time3 AS time3,t.time4 AS time4, \
            k.hid AS id, \
            k.user_id AS user_id, \
            k.device_id AS device_id, \
            nk.hid AS notebooks_id, \
            nk.user_id AS notebooks_user_id, \
            nk.device_id AS notebooks_device_id, \
            gk.hid AS changebehaviors_id, \
            gk.user_id AS changebehaviors_user_id, \
            gk.device_id AS changebehaviors_device_id \
            FROM trackchangebehaviors t \
            JOIN key_map k ON t.id = k.id AND k.tablename = 'trackchangebehaviors' \
            JOIN key_map nk ON nk.id = t.notebooks_id AND nk.tablename = 'notebooks' \
            JOIN key_map gk ON gk.id = t.changebehaviors_id AND gk.tablename = 'changebehaviors';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view trackchangebehaviors_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER trackchangebehaviors_sync_update \
            INSTEAD OF UPDATE ON trackchangebehaviors_sync \
            FOR EACH ROW BEGIN \
            UPDATE trackchangebehaviors SET time_record = new.time_record, time1 = new.time1, time2 = new.time2, time3 = new.time3, time4 = new.time4 \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'trackchangebehaviors'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger trackchangebehaviors_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER trackchangebehaviors_sync_insert \
            INSTEAD OF INSERT ON trackchangebehaviors_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO trackchangebehaviors (time_record,time1,time2,time3,time4,notebooks_id,changebehaviors_id) VALUES (new.time_record,new.time1,new.time2,new.time3,new.time4,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id),(SELECT id FROM key_map WHERE tablename = 'changebehaviors' AND hid = new.changebehaviors_id AND user_id = new.changebehaviors_user_id AND device_id = new.changebehaviors_device_id)); \
            INSERT INTO key_map VALUES ('trackchangebehaviors',(SELECT max(id) FROM trackchangebehaviors),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger trackchangebehaviors_sync_insert");
            }
            
            // BADBEHAVIORS VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, reminders TEXT, notebooks_id INTEGER
            sql_stmt = "CREATE VIEW badbehaviors_sync AS SELECT b.name AS name,b.date AS date,b.reminders AS reminders,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id,nk.hid AS notebooks_id,nk.user_id AS notebooks_user_id,nk.device_id AS notebooks_device_id FROM badbehaviors b JOIN key_map k ON b.id = k.id AND k.tablename = 'badbehaviors' JOIN key_map nk ON nk.id = b.notebooks_id AND nk.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view badbehaviors_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER badbehaviors_sync_update \
            INSTEAD OF UPDATE ON badbehaviors_sync \
            FOR EACH ROW BEGIN \
            UPDATE badbehaviors SET name = new.name,reminders = new.reminders, date = new.date \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'badbehaviors'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger badbehaviors_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER badbehaviors_sync_insert \
            INSTEAD OF INSERT ON badbehaviors_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO badbehaviors (name,date,reminders,notebooks_id) VALUES (new.name,new.date,new.reminders,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id)); \
            INSERT INTO key_map VALUES ('badbehaviors',(SELECT max(id) FROM badbehaviors),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger badbehaviors_sync_insert");
            }
            
            // REWARDTIME VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, timeperiod TEXT, notebooks_id INTEGER
            sql_stmt = "CREATE VIEW rewardtime_sync AS SELECT b.timeperiod AS timeperiod,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id,nk.hid AS notebooks_id,nk.user_id AS notebooks_user_id,nk.device_id AS notebooks_device_id FROM rewardtime b JOIN key_map k ON b.id = k.id AND k.tablename = 'rewardtime' JOIN key_map nk ON nk.id = b.notebooks_id AND nk.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view rewardtime_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER rewardtime_sync_update \
            INSTEAD OF UPDATE ON rewardtime_sync \
            FOR EACH ROW BEGIN \
            UPDATE rewardtime SET timeperiod = new.timeperiod \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'rewardtime'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger rewardtime_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER rewardtime_sync_insert \
            INSTEAD OF INSERT ON rewardtime_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO rewardtime (timeperiod,notebooks_id) VALUES (new.timeperiod,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id)); \
            INSERT INTO key_map VALUES ('rewardtime',(SELECT max(id) FROM rewardtime),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger rewardtime_sync_insert");
            }
            
            // TOKENHISTORY VIEWS/TRIGGERS
            //id INTEGER PRIMARY KEY AUTOINCREMENT, date DAYTIME, begin_token INTEGER, notebooks_id INTEGER
            
            sql_stmt = "CREATE VIEW tokenhistory_sync AS SELECT b.date AS date,b.begin_token AS begin_token,k.hid AS id,k.user_id AS user_id,k.device_id AS device_id,nk.hid AS notebooks_id,nk.user_id AS notebooks_user_id,nk.device_id AS notebooks_device_id FROM tokenhistory b JOIN key_map k ON b.id = k.id AND k.tablename = 'tokenhistory' JOIN key_map nk ON nk.id = b.notebooks_id AND nk.tablename = 'notebooks';";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create view tokenhistory_sync");
            }
            
            sql_stmt = "\
            CREATE TRIGGER tokenhistory_sync_update \
            INSTEAD OF UPDATE ON tokenhistory_sync \
            FOR EACH ROW BEGIN \
            UPDATE tokenhistory SET date = new.date,begin_token = new.begin_token \
            WHERE id = (SELECT k.id FROM key_map k WHERE k.hid = new.id AND k.user_id = new.user_id AND k.device_id = new.device_id AND k.tablename = 'tokenhistory'); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger tokenhistory_sync_update");
            }
            
            sql_stmt = "\
            CREATE TRIGGER tokenhistory_sync_insert \
            INSTEAD OF INSERT ON tokenhistory_sync \
            FOR EACH ROW BEGIN \
            INSERT INTO tokenhistory (date,begin_token,notebooks_id) VALUES (new.date,new.begin_token,(SELECT id FROM key_map WHERE tablename = 'notebooks' AND hid = new.notebooks_id AND user_id = new.notebooks_user_id AND device_id = new.notebooks_device_id)); \
            INSERT INTO key_map VALUES ('tokenhistory',(SELECT max(id) FROM tokenhistory),new.id,new.user_id,new.device_id); \
            END;";
            if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                NSLog(@"Failed to create trigger tokenhistory_sync_insert");
            }
            
            
            // DELETE SYNC TRIGGERS
            for (id table in mytable) {
                mysql = [NSString stringWithFormat:@"CREATE TRIGGER %@_sync_delete INSTEAD OF DELETE ON %@_sync FOR EACH ROW BEGIN DELETE FROM %@ WHERE id = (SELECT id FROM key_map WHERE tablename = '%@' AND hid = old.id AND user_id = old.user_id AND device_id = old.device_id); END;",table,table,table,table];
                sql_stmt = [mysql UTF8String];
                if (sqlite3_exec(kidzplanDB, sql_stmt, NULL, NULL, &err) != SQLITE_OK) {
                    NSLog(@"Failed to create trigger %@_sync_delete",table);
                }
            }
            
            sqlite3_close(kidzplanDB);
            NSLog(@"Local Database was created");
        }   else {
            NSLog(@"Failed to open/create database");
        }
    }
    else {
        NSLog(@"Local Database already exists");
    }
}

/* IF EXISTS (SELECT * FROM key_map WHERE table = '%@' AND id = old.id)\
 UPDATE %@_history SET change_type = '1' WHERE id = (SELECT hid FROM key_map WHERE tablename = '%@' AND id = old.id) AND user_id = (SELECT user_id FROM key_map WHERE tablename = '%@' AND id = old.id) AND device_id = (SELECT device_id FROM key_map WHERE tablename = '%@' AND id = old.id);\
 IF NOT EXISTS (SELECT * FROM key_map WHERE table = '%@' AND id = old.id)\
 INSERT INTO %@_history (id, user_id, device_id, change_type) VALUES ((SELECT hid FROM key_map WHERE tablename = '%@' AND id = old.id), (SELECT user_id FROM key_map WHERE tablename = '%@' AND id = old.id), (SELECT device_id FROM key_map WHERE tablename = '%@' AND id = old.id), '1') ;\ */

@end
