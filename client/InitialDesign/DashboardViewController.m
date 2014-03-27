//
//  DashboardViewController.m
//  Parenting+
//


#import "DashboardViewController.h"
#import "LocalDatabase.h"
#import "NotebookViewController.h"
#import "BehaviorsViewController.h"
#import "SetUpNotebookPhotoController.h"
#import "NoteBooks.h"
#import "OutlineDBFunction.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@interface DashboardViewController () {
    NSMutableArray *notebooks;
    NSMutableArray *notebookTitles;
    NSMutableArray *notebookImages;
    NSMutableArray *notebookStatus;
    NSMutableArray *notebookId;
    BOOL isGoingToEditNotebook;
    NSIndexPath *cellIndexPathForDeletingNotebook;
}

@property (nonatomic) BOOL useCustomCells;

@end

@implementation DashboardViewController

@synthesize dashboardTableView;

- (void)syncHandle:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    // Info keys: @"table", @"change_type", @"id", @"user_id", @"device_id"
    NSString * tableName = [info objectForKey:@"table"];
    if ([tableName isEqualToString:@"notebooks"]) {
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
}

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

    NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(syncHandle:) name:@"sync" object:nil];    
    /*
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg_sky_grass.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
     */
    
    // If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.dashboardTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    }
    self.useCustomCells = NO;
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
    [self reloadInputViews];
}

- (void)updateTable {
    notebookTitles = [[NSMutableArray alloc] init];
    notebookImages = [[NSMutableArray alloc] init];
    notebookStatus = [[NSMutableArray alloc] init];
    notebookId = [[NSMutableArray alloc] init];
    isGoingToEditNotebook = FALSE;
    
    // for loading dashboard table
    OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
    notebooks = [function getNotebooks];
    
    // get names and images from notebooks
    for (NSDictionary *notebook in notebooks) {
        NSString *bookid = [notebook objectForKey:@"id"];
        NSString *bookName = [notebook objectForKey:@"book_name"];
        NSData *picture = [notebook objectForKey:@"picture"];
        NSString *status = [notebook objectForKey:@"book_status"];
        [notebookTitles addObject:bookName];
        [notebookImages addObject:picture];
        [notebookStatus addObject:status];
        [notebookId addObject:bookid];
    }
    [dashboardTableView reloadData];
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
    return [notebookTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.useCustomCells)
    {
        
        DashboardCell *cell = [self.dashboardTableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        DashboardCell __weak *weakCell = cell;
        
        [cell setAppearanceWithBlock:^{
            //weakCell.leftUtilityButtons = [self leftButtons];
            weakCell.rightUtilityButtons = [self rightButtons];
            weakCell.delegate = self;
            weakCell.containingTableView = tableView;
        } force:NO];
        
        [cell setCellHeight:cell.frame.size.height];
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"cell";
        
        SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier
                                      containingTableView:dashboardTableView // Used for row height and selection
                                       leftUtilityButtons:nil
                                      rightUtilityButtons:[self rightButtons]];
            cell.delegate = self;
        }
        
        cell.textLabel.text = [notebookTitles objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [notebookStatus objectAtIndex:indexPath.row];
        NSData *imgData = [notebookImages objectAtIndex:indexPath.row];
        [cell.imageView setImage: [Utils scaleAndPreserveRatioForImage:[[UIImage alloc] initWithData:imgData]
                                                               toWidth:70.0 andHeight:70.0]];
        // Add a boarder around the image
        [cell.imageView.layer setBorderColor: [[UIColor colorWithRed:.4f green:.5f blue:.6f alpha:.9f] CGColor ]];
        
        CALayer* layer;
        layer = cell.imageView.layer;
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:5.0f];
        [layer setBorderWidth:1.0f];
        
        return cell;
    }
    
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Edit"];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

// Is being called after behaviors page is loaded...
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocalDatabase *db = [[LocalDatabase alloc] init];
    [db setCurrentNotebook: notebookId[indexPath.row]];
    // Main is the name of the storyboard file where the modal view controller is.
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    // Your modal view controller must have a storyboard id set. In this case,
    // I named it modelViewPage
    UITabBarController *modalView =
    [storyboard instantiateViewControllerWithIdentifier:@"tabBarControllerToUserViews"];
    
    // Display the view controller.
    NSLog(@"notebook status: %@", (NSString *)[notebookStatus objectAtIndex:indexPath.row]);
    if ([((NSString *)[notebookStatus objectAtIndex:indexPath.row]) isEqualToString:@"completed"])
    {
        [self presentViewController:modalView
                       animated:YES
                     completion:nil];
    }
    else
    {
        isGoingToEditNotebook = TRUE;
        [self performSelector:@selector(segueToNotebookSetup)
                   withObject:nil
                   afterDelay:0.0];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {

    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.dashboardTableView indexPathForCell:cell];
            // Edit button was pressed
            LocalDatabase *db = [[LocalDatabase alloc] init];
            [db setCurrentNotebook: notebookId[cellIndexPath.row]];
            
            [self performSelector:@selector(segueToNotebookSetup)
                       withObject:nil
                       afterDelay:0.0];
            
            [cell hideUtilityButtonsAnimated:YES];
            isGoingToEditNotebook = TRUE;
            break;
        }
        case 1:
        {
            cellIndexPathForDeletingNotebook = [self.dashboardTableView indexPathForCell:cell];
            // confirm if user wants to delete a notebook
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Notebook" message:@"Are you sure you want to delete this notebook?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
            [alert show];

            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //int price = [[rewardPrices objectAtIndex:rowNumberClicked] intValue];
    
    // delete notebook
    if(buttonIndex == 1)
    {
        // DB deletion functionality.
        LocalDatabase *db = [[LocalDatabase alloc] init];
        [db setCurrentNotebook:notebookId[cellIndexPathForDeletingNotebook.row]];
        NSLog(@"current notebook from dashboard: %@", [db getCurrentNotebook]);
        [db deleteCurrentNotebook];
        
        //[_testArray[cellIndexPath.section] removeObjectAtIndex:cellIndexPath.row];
        [notebookTitles removeObjectAtIndex:cellIndexPathForDeletingNotebook.row];
        [notebookImages removeObjectAtIndex:cellIndexPathForDeletingNotebook.row];
        [notebookStatus removeObjectAtIndex:cellIndexPathForDeletingNotebook.row];
        [notebookId removeObjectAtIndex:cellIndexPathForDeletingNotebook.row];
        
        // remove the associated cell from the Table View
        [self.dashboardTableView deleteRowsAtIndexPaths:@[cellIndexPathForDeletingNotebook] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(void)segueToNotebookSetup
{
    [self performSegueWithIdentifier:@"setupNotebookSegue" sender:self];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - Navigation

// This is useful to have in case we later decide to add custom checks or behavior to the segue(s).
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"trackBehaviorSegue"])
    {
        return YES;
    }
    if ([identifier isEqualToString:@"setupNotebookSegue"])
    {
        return YES;
    }
    if ([identifier isEqualToString:@"accountSettingsSegue"])
    {
        return YES;
    }
    return YES;
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"behaviorSegue"])
    {
        BehaviorsViewController *controller = (BehaviorsViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
    }
    
    if ([[segue identifier] isEqualToString:@"setupNotebookSegue"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SetUpNotebookPhotoController *controller = [[navigationController viewControllers] lastObject];
        if (!isGoingToEditNotebook) {
            controller.status = @"New";
        }
    }
}

@end
