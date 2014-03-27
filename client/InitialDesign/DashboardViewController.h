//
//  DashboardViewController.h
//  Parenting+
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"
#import "SWTableViewCell.h"
#import "DashboardCell.h"

@interface DashboardViewController : UIViewController <SWTableViewCellDelegate>

// Buttons
@property (weak, nonatomic) IBOutlet UIBarButtonItem *setUpNotebookBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *accountSettingsBtn;

@property (strong, nonatomic) NoteBooks *notebook;
// Views
@property (retain, nonatomic) IBOutlet UITableView *dashboardTableView;


@end
