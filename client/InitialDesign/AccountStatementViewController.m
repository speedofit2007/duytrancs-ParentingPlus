//
//  AccountStatementViewController.m
//  Parenting+
//
//  Created by Neil Gebhard on 2/15/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "AccountStatementViewController.h"
#import "NoteBooks.h"
#import "OutlineDBFunction.h"

@interface AccountStatementViewController () {
    NSMutableArray *rewardNames;
    NSMutableArray *rewardPrices;
    NSMutableArray *rewardsStatuses;
    int tokensEarned;
    int tokensSpent;
    int beginningTokenBalance;
    int endingTokenBalance;
    int tokenCount;
    NSDate *currentDate;
    NSDate *dateOfCreation;
    NoteBooks *notebook;
    LocalDatabase *ldb;
    
}

@end

@implementation AccountStatementViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _myDatePicker.datePickerMode = UIDatePickerModeDate;
    [_myDatePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    currentDate = [NSDate date];
    dateOfCreation = [[NSDate alloc] init];
    notebook = [[NoteBooks alloc] init];
    ldb = [[LocalDatabase alloc] init];
    notebook = [notebook getWholeClassNotebooksFromNotebookID:[ldb getCurrentNotebook]];
    dateOfCreation = [notebook getNotebookCreateDate];
    
    [_myDatePicker setMaximumDate:currentDate];
    [_myDatePicker setMinimumDate:dateOfCreation];
    
    [self updateTable];
}

- (void)datePickerDateChanged:(UIDatePicker *)paramDatePicker {
    NSLog(@"Selected date = %@", paramDatePicker.date);
    
    [self updateTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateTable];
}

#pragma mark - Table view data source

- (void)updateTable {
    
    rewardNames = [[NSMutableArray alloc] init];
    rewardPrices = [[NSMutableArray alloc] init];
    rewardsStatuses = [[NSMutableArray alloc] init];
    
    // get date from date picker
    currentDate = _myDatePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    // get the daily token balance on date
    LocalDatabase *db = [[LocalDatabase alloc] init];
    notebook = [[NoteBooks alloc] init];
    notebook = [notebook getWholeClassNotebooksFromNotebookID:[db getCurrentNotebook]];
    tokenCount = [notebook getTokenBalance];
    _tokenBalanceLabel.text = [NSString stringWithFormat:@"%d", tokenCount];
    
    // get tokens earned on date
    OutlineDBFunction *odb = [[OutlineDBFunction alloc] init];
    tokensEarned = [odb getTokenEarnedWhen:dateString];
    beginningTokenBalance = [odb getBeginningTokenBalanceWhen:dateString];
    endingTokenBalance = beginningTokenBalance + tokensEarned;
    
    NSMutableArray *trackBehaviors = [odb getTrackBehaviorWhen:dateString];
    if (trackBehaviors.count != 0) {
        for(id obj in trackBehaviors) {
            if ([obj[@"bhname"] isEqualToString:@"Less often/Not at all"]) {
                NSString *new = [NSString stringWithFormat:@"Less/Not %@",obj[@"badname"]];
                [rewardNames addObject:new];
            } else {
                [rewardNames addObject:obj[@"bhname"]];
            }
            NSString *tokensEarnedFromBehavior = [NSString stringWithFormat:@"+%@", obj[@"token_earned"]];
            [rewardPrices addObject:tokensEarnedFromBehavior];
            [rewardsStatuses addObject:@"earned"];
        }
    }
    
    // if rewards redeemed on date, get rewards
    NSMutableArray *rewardsRedeemedOrSaved = [odb getRewardsRedeemedOrSavedWhen:dateString];
    tokensSpent = 0;
    if (rewardsRedeemedOrSaved.count != 0) {
        for(id obj in rewardsRedeemedOrSaved) {
            NSString *priceFromRewards = [NSString stringWithFormat:@"-%@", obj[@"price"]];
            [rewardPrices addObject:priceFromRewards];
            [rewardNames addObject:obj[@"reward_name"]];
            [rewardsStatuses addObject:obj[@"reward_status"]];
            tokensSpent += [obj[@"price"] intValue];
        }
    }
    endingTokenBalance -= tokensSpent;
    
    [_myTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rewardNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure cell
    cell.textLabel.text = [rewardNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [rewardsStatuses objectAtIndex:indexPath.row];
    
    // remove cell highlighting feature of table
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // display reward price
    CGRect labelFrame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:labelFrame];
    priceLabel.text = [rewardPrices objectAtIndex:indexPath.row];
    
    if ([priceLabel.text hasPrefix:@"+"]) {
        priceLabel.textColor = [UIColor greenColor];
    }
    else if ([priceLabel.text hasPrefix:@"-"]) {
        priceLabel.textColor = [UIColor redColor];
    }
    
    cell.accessoryView = priceLabel;
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [NSString stringWithFormat:@"Beginning Token Balance: %d", beginningTokenBalance];
    }
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        NSString *footer = [NSString stringWithFormat:@"Ending Token Balance: %d", endingTokenBalance];
        return footer;
    }
    return nil;
}

- (IBAction)goBackToNotebooksBtn:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
