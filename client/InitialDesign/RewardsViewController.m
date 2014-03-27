//
//  RewardsViewController.m
//  Parenting+
//
//  Created by Sean Walsh on 1/6/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "RewardsViewController.h"
#import "NoteBooks.h"

@interface RewardsViewController () {
    NSMutableArray *rewardTitles;
    NSMutableArray *rewardPrices;
    NSInteger rowNumberClicked;
    NSString *dateString;
    NoteBooks *notebook;
    int tokenCount;
}

@end

@implementation RewardsViewController

@synthesize rewardsTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    self.title = @"Rewards";
    
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

- (void)updateTable {
    tokenCount = [notebook getTokenBalance];
    _tokenBalanceLabel.text = [NSString stringWithFormat:@"%d", tokenCount];
    
    rewardTitles = [[NSMutableArray alloc] init];
    rewardPrices = [[NSMutableArray alloc] init];
    NSMutableArray *rewards = [[NSMutableArray alloc] init];
    rewards = [notebook getRewards];
    
    for(id obj in rewards) {
        [rewardTitles addObject:obj[@"reward_name"]];
        [rewardPrices addObject:obj[@"price"]];
    }
    
    // get current date
    NSDate* currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    dateString = [dateFormatter stringFromDate:currDate];
    
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
    
    // display reward price
    CGRect labelFrame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:labelFrame];
    priceLabel.text = [rewardPrices objectAtIndex:indexPath.row];
    
    // button to redeem an award
    UIButton *redeemButton = [UIButton buttonWithType:UIButtonTypeSystem];
    redeemButton.frame = CGRectMake(40.0f, 0.0f, 40.0f, 40.0f);
    UIImage *redeemImage = [UIImage imageNamed:@"icon_token.png"];
    [redeemButton setBackgroundImage:redeemImage forState:UIControlStateNormal];
    [redeemButton addTarget:self action:@selector(tappedRedeemReward:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    // create a view to add to the accessory view of each cell (hack)
    CGRect accessoryContainerFrame = CGRectMake(0.0f, 0.0f, 85.0f, 40.0f);
    UIView *accessoryContainer = [[UIView alloc] initWithFrame:accessoryContainerFrame];
    [accessoryContainer addSubview:redeemButton];
    [accessoryContainer addSubview:priceLabel];
    cell.accessoryView = accessoryContainer;
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Rewards to Earn                     Price  Redeem";
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
    NSIndexPath *indexPath = [rewardsTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:rewardsTableView]];
    rowNumberClicked = indexPath.row;
    int price = [[rewardPrices objectAtIndex:rowNumberClicked] intValue];
    
    // user has enough tokens to redeem
    if (price <= tokenCount) {
        NSString *reward = [rewardTitles objectAtIndex:indexPath.row];
        NSString *alertMsg = [NSString stringWithFormat:@"%@", reward];
        NSString *tokenCountMsg = [NSString stringWithFormat:@"Token balance: %d", tokenCount];
        
        // confirm if user wants to redeem a reward
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMsg message:tokenCountMsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", @"Redeem", nil];
        [alert show];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Sorry, not enough tokens." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    OutlineDBFunction *db = [[OutlineDBFunction alloc] init];
    int price = [[rewardPrices objectAtIndex:rowNumberClicked] intValue];
    
    // save reward
    if(buttonIndex == 1)
    {
        NSString *reward = [rewardTitles objectAtIndex:rowNumberClicked];
        tokenCount = tokenCount - price;
        [db SaveRedeemRewards:reward andPrice:price andStatus:@"saved" when:dateString];
        [notebook updateTokenBalanceWith:-price];
    }
    
    // redeem reward
    else if (buttonIndex == 2)
    {
        NSString *reward = [rewardTitles objectAtIndex:rowNumberClicked];
        tokenCount = tokenCount - price;
        [db SaveRedeemRewards:reward andPrice:price andStatus:@"redeemed" when:dateString];
        [notebook updateTokenBalanceWith:-price];
    }
    
    // update token balance
    _tokenBalanceLabel.text = [NSString stringWithFormat:@"%d", tokenCount];
}

- (IBAction)goBackToNotebooksBtn:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
