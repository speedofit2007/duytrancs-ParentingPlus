//
//  InfoViewController.m
//  InitialDesign
//
//  Created by Neil Gebhard on 3/2/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "InfoViewController.h"
#import "BehaviorsToKeepViewController.h"
#import "BehaviorsToChangeViewController.h"
#import "ThingsToDoInsteadViewController.h"
#import "RulesAndRemindersViewController.h"
#import "ObserveAndRewardViewController.h"
#import "RewardsToEarnViewController.h"

static NSString *CellIdentifier = @"Cell";

@interface InfoViewController () {
    NSMutableArray *examples;
}

@end

@implementation InfoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // navigation setup
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,320,64)];
    UINavigationItem *buttonCarrier = [[UINavigationItem alloc] initWithTitle:@"Examples"];
    UIBarButtonItem *barDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    [buttonCarrier setRightBarButtonItem:barDoneButton];
    NSArray *barItemArray = [[NSArray alloc] initWithObjects:buttonCarrier, nil];
    [navBar setItems:barItemArray];
    [self.tableView setTableHeaderView:navBar];
    
    // transition from Behaviors To Keep
    if(_transition == 1) {
        examples = [[NSMutableArray alloc] initWithObjects:@"Helps set table" ,@"Gives hugs", @"Uses seatbelt", @"Puts toys away", nil];
    }
    // transition from Behaviors to Change
    if(_transition == 2) {
        examples = [[NSMutableArray alloc] initWithObjects:@"Forgets to say please" ,@"Jumping on couch", @"Whining", @"Arguing", nil];
    }
    // transition from Things to Do Instead
    if(_transition == 3) {
        examples = [[NSMutableArray alloc] initWithObjects:@"Say please more" ,@"Talk clearly", @"Save running for outside", nil];
    }
    // transition from Rules/Reminders
    if(_transition == 4) {
        examples = [[NSMutableArray alloc] initWithObjects:@"Respect others" ,@"Take turns talking", @"Tell the truth at all times", nil];
    }
    // transition from tracking times
    if(_transition == 5) {
        examples = [[NSMutableArray alloc] initWithObjects:@"Morning" ,@"Afternoon", @"Evening", nil];
    }
    // transition from Rewards
    if(_transition == 6) {
        examples = [[NSMutableArray alloc] initWithObjects:@"Ice cream", @"Cookies", @"Disneyland", @"Ferrari", nil];
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonPressed:(UIBarButtonItem *) paramSender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return examples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [examples objectAtIndex:indexPath.row];
    
    return cell;
}

// Is being called after behaviors page is loaded...
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_transition == 1) {
        ((BehaviorsToKeepViewController *)self.parent).behavior1Txt.text = [examples objectAtIndex:indexPath.row];
    } if(_transition == 2) {
        ((BehaviorsToChangeViewController *)self.parent).behavior1Txt.text = [examples objectAtIndex:indexPath.row];
    } if(_transition == 3) {
        ((ThingsToDoInsteadViewController *)self.parent).behavior1Txt.text = [examples objectAtIndex:indexPath.row];
    } if(_transition == 4) {
        ((RulesAndRemindersViewController *)self.parent).rule1Txt.text = [examples objectAtIndex:indexPath.row];
    } if(_transition == 5) {
        ((ObserveAndRewardViewController *)self.parent).time1Txt.text = [examples objectAtIndex:indexPath.row];
    } if(_transition == 6) {
        ((RewardsToEarnViewController *)self.parent).reward1Txt.text = [examples objectAtIndex:indexPath.row];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
