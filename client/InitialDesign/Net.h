//
//  Net.h
//  Parenting+
//
//  Created by Curtis Ruecker on 1/20/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//
//  You should get the instance of net using:
//
//  Net *sharedNet = [Net sharedNet];
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface Net : NSObject
@property (strong, nonatomic) Reachability *reachability;
@property NSString *foop;
+ (id)sharedNet;
- (BOOL) hasConnection;
- (void) requestLoginWithEmail:(NSString *)email andPassword:(NSString *)password andCallback:(void (^)(BOOL success, NSDictionary * data))callback;
- (void) requestSignUpWithEmail:(NSString *)email andFirstName:(NSString *)first_name andLastName:(NSString *)last_name andPassword:(NSString *)password andCallback:(void (^)(BOOL, NSDictionary *))callback;
-(void) syncDatabase;
-(void) requestLogout;
@end
