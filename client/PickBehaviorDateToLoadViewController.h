//
//  PickBehaviorDateToLoadViewController.h
//  InitialDesign
//
//  Created by Azadi on 2/13/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingBehaviorViewController.h"

@interface PickBehaviorDateToLoadViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)doneClicked:(id)sender;

@property (weak, nonatomic) TrackingBehaviorViewController *parent;


@end
