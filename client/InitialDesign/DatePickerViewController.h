//
//  PickBehaviorDateToLoadViewController.h
//  InitialDesign
//
//  Created by Sean Walsh on 2/13/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)doneClicked:(id)sender;

@property (weak, nonatomic) UIViewController *parent;

@end
