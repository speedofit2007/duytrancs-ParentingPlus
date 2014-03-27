//
//  TrackBehaviorController.h
//  initialDesign
//


#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface TrackBehaviorViewController : UIViewController
// Buttons

// Labels
@property (weak, nonatomic) IBOutlet UILabel *currentTokenBalance;
@property (weak, nonatomic) IBOutlet UILabel *dailyTokenBalance;
@property (strong, nonatomic) IBOutlet UILabel *notebookNameLbl;

@property (weak, nonatomic) IBOutlet UIImageView *notebookImage;
@property (strong, nonatomic) IBOutlet UILabel *rule1Lbl;
@property (strong, nonatomic) IBOutlet UILabel *rule2Lbl;
@property (strong, nonatomic) IBOutlet UILabel *rule1TitleLbl;
@property (strong, nonatomic) IBOutlet UILabel *rule2TitleLbl;

@property (strong, nonatomic) NoteBooks *notebook;
@property (strong, nonatomic) NoteBooks *mybook;
// Click handlers

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rewardsTabItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoTabItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *behaviorTabItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsTabItem;

@end
