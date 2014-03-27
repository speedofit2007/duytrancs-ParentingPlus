//
//  TrackBehaviorController.m
//  InitialDesign
//


#import "TrackBehaviorViewController.h"
#import "BehaviorsViewController.h"
#import "RewardsViewController.h"
#import "NoteBooks.h"
#import "LocalDatabase.h"

@interface TrackBehaviorViewController ()

@end

@implementation TrackBehaviorViewController

// TODO: Replace this int assignment with a call to the DB which will retrieve the number of tokens earned so far in the current day.
NSInteger dailyTokensEarned = 0;
NSInteger totalTokenBalance;
NSInteger tokenValue = 2;
// Used to track the amount added last for the purposes of the Undo button.
NSInteger lastTokenAmountAdded;

NoteBooks *notebook;
NoteBooks *mybook;

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
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    NoteBooks *mybook = [[NoteBooks alloc] init];
    LocalDatabase *db = [[LocalDatabase alloc]init];
    mybook = [mybook getWholeClassNotebooksFromNotebookID:[db getCurrentNotebook]];
    
    // display rule 1
    NSMutableArray *behaviorsToChange = [mybook getBehaviorsToChange];
    if (behaviorsToChange.count < 1) {
            _rule1Lbl.hidden = YES;
            _rule1TitleLbl.hidden = YES;
    } else {
        NSDictionary *behaviorToChange1 = [behaviorsToChange objectAtIndex:0];
        NSString *rule1 = [behaviorToChange1[@"reminders"] capitalizedString];
        _rule1Lbl.text = rule1;
    }
    
    // display rule 2
    if (behaviorsToChange.count < 2) {
        _rule2Lbl.hidden = YES;
        _rule2TitleLbl.hidden = YES;
    } else {
        NSDictionary *behaviorToChange2 = [behaviorsToChange objectAtIndex:1];
        NSString *rule1 = [behaviorToChange2[@"reminders"] capitalizedString];
        _rule2Lbl.text = rule1;
    }
    
    totalTokenBalance = [mybook getTokenBalance];
    _notebookNameLbl.text = [mybook getArrayBooks][@"book_name"];
    NSString *oldPicture = [mybook getArrayBooks][@"picture"];
    if ([oldPicture isEqualToString:@"default-pic01.png"] == FALSE &&
        [oldPicture isEqualToString:@"default-pic02.png"] == FALSE &&
        [oldPicture isEqualToString:@"default-pic03.png"] == FALSE &&
        [oldPicture isEqualToString:@"default-pic04.png"] == FALSE) {
        [_notebookImage setImage:[[UIImage alloc]initWithContentsOfFile:oldPicture]];
    } else
        _notebookImage.image = [UIImage imageNamed:[mybook getArrayBooks][@"picture"]];
    [self updateLabels];
    
    // Duy: Here is where we need to check if the notebook is incomplete.
    // If incomplete, take this branch.
    if ([[mybook getArrayBooks][@"book_status"] isEqualToString:@"incomplete"])
    {
        _rewardsTabItem.enabled = NO;
        _infoTabItem.enabled = NO;
        _behaviorTabItem.enabled = NO;
        _settingsTabItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{    
     return YES;
}

- (void) updateLabels
{
    //_dailyTokenBalance.text = [NSString stringWithFormat:@"Daily token balance: %ld", (long)dailyTokensEarned];
    NoteBooks *book = [[NoteBooks alloc] init];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd-YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    _dailyTokenBalance.text = [NSString stringWithFormat:@"Daily Token Balance: %d",[book dailyTokenBalanceWhen:dateString]];
    _currentTokenBalance.text = [NSString stringWithFormat:@"Current Token Balance: %ld", (long)[book getTokenBalance]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    if ([[segue identifier] isEqualToString:@"behaviorViewSegue"])
    {
        //BehaviorsViewController *controller = (BehaviorsViewController*)segue.destinationViewController;
        //controller.notebook = _notebook;
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLabels];
}

@end
