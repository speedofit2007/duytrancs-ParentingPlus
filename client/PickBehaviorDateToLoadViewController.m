//
//  PickBehaviorDateToLoadViewController.m
//  InitialDesign
//
//  Created by Sean Walsh on 2/13/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "PickBehaviorDateToLoadViewController.h"
#import "NoteBooks.h"
#import "LocalDatabase.h"

@interface PickBehaviorDateToLoadViewController ()

@end

@implementation PickBehaviorDateToLoadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate *todaysDate = [NSDate date];
    NSDate *dateOfCreation = [self.parent.notebook getNotebookCreateDate];
    
    [self.datePicker setMaximumDate:todaysDate];
    [self.datePicker setMinimumDate:dateOfCreation];
    self.datePicker.date = self.parent.currDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneClicked:(id)sender
{
    self.parent.currDate = [_datePicker date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
