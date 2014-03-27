//
//  TreasureChestViewController.m
//  Parenting+
//
//  Created by Sean Walsh on 1/7/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "TreasureChestViewController.h"
#import "NoteBooks.h"

@interface TreasureChestViewController () {
    NSMutableArray *rewardTitles;
    NSInteger rowNumberClicked;
    NoteBooks *notebook;
    NSString* dateString;
}

@end

@implementation TreasureChestViewController

@synthesize TChestTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
	
    // Do any additional setup after loading the view.
    self.title = @"Treasure Chest";
    
    LocalDatabase *db = [[LocalDatabase alloc] init];
    notebook = [[NoteBooks alloc] init];
    notebook = [notebook getWholeClassNotebooksFromNotebookID:[db getCurrentNotebook]];
    
    [self updateTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateTable];
}

- (void) updateTable {
    rewardTitles = [[NSMutableArray alloc] init];
    OutlineDBFunction *odb = [[OutlineDBFunction alloc] init];
    NSMutableArray *rewards = [[NSMutableArray alloc] init];
    rewards = [odb getSavedRewards];
    
    for(id obj in rewards) {
        [rewardTitles addObject:obj[@"reward_name"]];
    }
    
    // get current date
    NSDate* currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    dateString = [dateFormatter stringFromDate:currDate];
    
    [TChestTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rewardTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure cell
    cell.textLabel.text = [rewardTitles objectAtIndex:indexPath.row];
    
    // remove cell highlighting feature of table
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // button to redeem an award
    UIButton *redeemButton = [UIButton buttonWithType:UIButtonTypeSystem];
    redeemButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    UIImage *redeemImage = [UIImage imageNamed:@"icon_token.png"];
    [redeemButton setBackgroundImage:redeemImage forState:UIControlStateNormal];
    [redeemButton addTarget:self action:@selector(tappedRedeemReward:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = redeemButton;
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Rewards to Earn                               Redeem";
    }
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @" ";
    }
    return nil;
}

- (void)tappedRedeemReward:(id)sender forEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [TChestTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:TChestTableView]];
    rowNumberClicked = indexPath.row;
    
    NSString *reward = [rewardTitles objectAtIndex:indexPath.row];
    NSString *alertMsg = [NSString stringWithFormat:@"%@%@%@", @"Are you sure you want to redeem '", reward, @"'?"];
    
    // confirm if user wants to redeem a reward
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMsg message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        // redeem reward
        //NSString *reward = [rewardTitles objectAtIndex:rowNumberClicked];
        OutlineDBFunction *odb = [[OutlineDBFunction alloc] init];
        NSMutableArray *rewards = [odb getSavedRewards];
        [odb updateSavedRewardToRedemmedFromID:rewards[rowNumberClicked][@"id"]];
        [rewardTitles removeObjectAtIndex:rowNumberClicked];
        [TChestTableView reloadData];
    }
}

- (IBAction)goBackToNotebooksBtn:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
