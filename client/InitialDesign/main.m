//
//  main.m
//  InitialDesign
//
//  Created by  Sean Walsh on 11/30/13.
//  Copyright (c) 2013 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "Tutorials.h"

Tutorials *tutorials;

int main(int argc, char * argv[])
{
    tutorials = [[Tutorials alloc] init];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
