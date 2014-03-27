//
//  PickBehaviorDateToLoadViewController.m
//  InitialDesign
//
//  Created by Sean Walsh on 2/13/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "DatePickerViewController.h"
#import "SetUpNotebookPhotoController.h"


@interface DatePickerViewController()

@end

@implementation DatePickerViewController
NSDate *todaysDate;
NSDate *dateOfCreation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    todaysDate = [NSDate date];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    
}

- (IBAction)doneClicked:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd-YYYY"];
    
    (( SetUpNotebookPhotoController *)self.parent).birthdayTxt.text = [dateFormatter stringFromDate:[_datePicker date]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
