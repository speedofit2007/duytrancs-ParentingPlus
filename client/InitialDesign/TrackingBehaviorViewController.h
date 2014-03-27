//
//  TrackingBehaviorViewController.h
//  InitialDesign
//
//  Created by Basem Elazzabi on 2/25/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface TrackingBehaviorViewController : UIViewController

@property (strong,nonatomic,setter = setCurrDate:) NSDate *currDate;
@property (nonatomic, setter = setCurrBalance:) int currBalance;
@property (strong,nonatomic) NSString *currDateStr;

@property (strong, nonatomic) NoteBooks *notebook;
@property (strong, nonatomic) LocalDatabase *ldb;
@property (strong, nonatomic) OutlineDBFunction *function;

@property (nonatomic, setter = setSelectedSticker:) int selectedSticker;
@property (strong, nonatomic) NSMutableArray *stickers;
@property (strong, nonatomic) NSMutableDictionary *stickerImages;
@property (strong, nonatomic) NSArray *stickerImageNames;
- (void)loadNotebook;
- (IBAction)goBackToNotebooks:(id)sender;
- (IBAction)selectSticker:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *stickerScrollView;

@property (weak, nonatomic) IBOutlet UILabel *currBalanceLbl;
@property (weak, nonatomic) IBOutlet UIButton *currDateBtn;
- (IBAction)currDateBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (void)setCurrDate:(NSDate *) date;
- (void)getBehaviorDataFromDB;
- (void)setSelectedSticker:(int)selectedSticker;
- (void)setCurrBalance:(int)currBalance;
@end
