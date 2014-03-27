//
//  LocalDatabase.h
//  DatabaseModule
//
//  Created by Duy Tran on 12/15/13.
//  Copyright (c) 2013 Capstone Team B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <sqlite3.h>

@interface LocalDatabase : NSObject

// basic function
-(void) setCurrentUser: (NSString*) userID;
-(void) setCurrentNotebook: (NSString*) bookID;
-(void) setDatabasePath;
-(void)setCurrentDate:(NSDate *)date;
-(NSString *) getCurrentDate;
-(NSString *) getCurrentUser;
-(NSString *) getCurrentNotebook;
-(NSString *) getDatabasePath;
-(NSString *) getEmail;
-(void) deleteCurrentNotebook;
-(NSMutableDictionary *) getUserInformation;

// function check exist local database
-(void) createLocalDB;

-(void) signUpNewUser: (NSString *)firstName andLastName:(NSString*)lastName andEmail:(NSString *)username andPassword:(NSString *)password andCallback:(void (^)(BOOL, NSArray *))callback;

// function logout
-(void) Logout;
// function auto login
-(void)autoLoginandCallback:(void (^)(BOOL))callback;

// function check email and password exists in localDB or not
-(void) checkLogin: (NSString *)username andPassword:(NSString *)password andCallback:(void (^)(BOOL, NSString *))callback;

// function get UserID from current user
-(NSString *) getUserID: (NSString *)username andPassword:(NSString *)password;

// function update user
-(void) updateUsersWithEmail: (NSString *)email andPassword:(NSString *)password;

//function working with User Information
-(BOOL) updateFirstLastEmail:(NSString*)first andLast: (NSString*)last andEmail: (NSString*) email;
-(BOOL) updatePasswordToNew: (NSString*) newPass;


// function encript string password into MD5 string
- (NSString *) encryptMD5:(NSString *) input;

@end
