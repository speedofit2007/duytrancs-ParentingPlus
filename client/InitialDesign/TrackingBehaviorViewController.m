//
//  TrackingBehaviorViewController.m
//  InitialDesign
//
//  Created by Basem Elazzabi on 2/25/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "TrackingBehaviorViewController.h"
#import "LocalDatabase.h"
#import "OutlineDBFunction.h"
#import "StickerTableViewCell.h"
#import "LabelTableViewCell.h"
#import "Utils.h"
#import "PickBehaviorDateToLoadViewController.h"

@interface TrackingBehaviorViewController ()

@end

@implementation TrackingBehaviorViewController{
    NSDateFormatter *dateFormatter;
    NSMutableArray *behaviorToKeepStatsFromDB;
    NSMutableArray *behaviorToChangeStatsFromDB;
    NSMutableArray *checkInTimes;
    NSMutableArray *cellStructure;
}

- (void)syncHandle:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    // Info keys: @"table", @"change_type", @"id", @"user_id", @"device_id"
    NSString * tableName = [info objectForKey:@"table"];
    if (![tableName isEqualToString:@"rewards"] && ![tableName isEqualToString:@"savedrewards"] && ![tableName isEqualToString:@"tokenhistory"]) {
        [self performSelectorOnMainThread:@selector(loadNotebook) withObject:nil waitUntilDone:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(syncHandle:) name:@"sync" object:nil];
    dateFormatter = [[NSDateFormatter alloc]init];
    
    // Those are the stickers that we will use.
    _stickerImageNames = @[
                           @"no-sticker-100px.png",
                           @"sticker01.png",
                           @"sticker02.png",
                           @"sticker03.png",
                           @"sticker04.png",
                           @"sticker05.png",
                           @"sticker06.png",
                           @"sticker07.png",
                           @"sticker08.png",
                           ];
    
    // Load sticker images.
    self.stickers = [[NSMutableArray alloc] init];
    self.stickerImages = [[NSMutableDictionary alloc] init];
    _selectedSticker = 0;
    float x = 3.0;
    
    self.stickerImages[@"no-sticker-100px.png"] = [UIImage imageNamed: @"rect"];
    
    for(int i=1;i<=8;++i){
        NSString *imageName = [NSString stringWithFormat: @"sticker0%i.png" ,i];
        
        UIImage *image = [UIImage imageNamed: imageName];
        image = [Utils scaleAndPreserveRatioForImage:image toWidth:32. andHeight:32.0];
        self.stickerImages[imageName] = image;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(selectSticker:)
                forControlEvents:UIControlEventTouchDown];
        button.frame = CGRectMake(x, 3, 32, 32);
        [button setImage:image forState: UIControlStateNormal];
        button.tag = i;
        [self.stickerScrollView addSubview:button];
        [self.stickers addObject:button];
        x += 38;
    }
    self.selectedSticker = 1;
    // Set the current date to today and load the data from the DB;
    self.currDate = [NSDate date];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadNotebook];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectSticker:(id)sender{
    self.selectedSticker = ((UIButton *)sender).tag;
}

- (void)setSelectedSticker:(int)selectedSticker{
    UIButton *btn;
    // If there is a sticker that is already selected before, we need to
    // deselect it.
    if(_selectedSticker > 0){
        btn = self.stickers[_selectedSticker - 1];
        btn.backgroundColor = nil;
    }
    _selectedSticker = selectedSticker;
    btn = self.stickers[_selectedSticker - 1];
    btn.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
}
- (IBAction)currDateBtnClicked:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PickBehaviorDateToLoadViewController *modalView = [storyboard instantiateViewControllerWithIdentifier:@"pickDateForBehaviorTracking"];
    modalView.parent = self;
    [self presentViewController:modalView animated:YES completion:nil];
}

-(void)setCurrDate:(NSDate *)date{
    _currDate = date;
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    _currDateStr = [dateFormatter stringFromDate: date];
    [dateFormatter setDateFormat:@"dd-MM-YYYY"];
    [self.currDateBtn setTitle: [dateFormatter stringFromDate: date] forState:UIControlStateNormal];
    [self loadNotebook];
}
- (void)setCurrBalance:(int)currBalance{
    _currBalance =  currBalance;
    self.currBalanceLbl.text = [NSString stringWithFormat:@"%i", currBalance];
}
-(void)loadNotebook{
    self.notebook = [[NoteBooks alloc] init];
    self.ldb = [[LocalDatabase alloc] init];
    self.notebook = [self.notebook getWholeClassNotebooksFromNotebookID:[self.ldb getCurrentNotebook]];
    self.function = [[OutlineDBFunction alloc]init];
    [self getBehaviorDataFromDB];
    self.currBalance = [self.notebook getTokenBalance];
    [self.tableView reloadData];

}

- (IBAction)goBackToNotebooks:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)getBehaviorDataFromDB
{
    behaviorToKeepStatsFromDB = [self.function getTrackGoodBehaviorsWhen:self.currDateStr];
    behaviorToChangeStatsFromDB = [self.function getTrackThingsToDoInsteadWhen:self.currDateStr];
    checkInTimes = [self.notebook getBehaviorsCheckinTime];
    
    cellStructure = [[NSMutableArray alloc] init];
    
    // We always have two rows, one for the title Behaviors to keep and another for
    // Behaviors to change.
    
    [cellStructure addObject: @{@"cell_type": @"H1BlueCell", @"data_type": @"Label", @"data": @"Behaviors to Keep"}];
    
    // For each behavior to keep, we have a row for title and a row for the stickers.
    for(id btk in behaviorToKeepStatsFromDB){
        [cellStructure addObject: @{@"cell_type": @"H2Cell", @"data_type": @"Label", @"data": ((NSString *)btk[@"bhname"]) }];
        [cellStructure addObject: @{@"cell_type": @"Sticker", @"data_type": @"BTK", @"data": btk}];
    }
    
    [cellStructure addObject: @{@"cell_type": @"H1RedCell", @"data_type": @"Label", @"data": @"Behaviors to Change"}];
    
    // For each behavior to change, we have row for the title, and a row for the stickers.
    NSString *lastBTC = @"";
    for(id btk in behaviorToChangeStatsFromDB){
        if(![lastBTC isEqual: btk[@"badBehavior_name"]]){
            lastBTC = btk[@"badBehavior_name"];
            [cellStructure addObject: @{@"cell_type": @"H2Cell", @"data_type": @"Label", @"data": lastBTC}];
        }
        [cellStructure addObject: @{@"cell_type": @"H3Cell", @"data_type": @"Label", @"data": ((NSString *)btk[@"bhname"]) }];
        [cellStructure addObject: @{@"cell_type": @"Sticker", @"data_type": @"BTC", @"data": btk}];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellStructure count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    NSDictionary *cellInfo = cellStructure[indexPath.row];
    if( [((NSString *)cellInfo[@"cell_type"]) isEqual:@"H1BlueCell"] ||
        [((NSString *)cellInfo[@"cell_type"]) isEqual:@"H1RedCell"] || 
        [((NSString *)cellInfo[@"cell_type"]) isEqual:@"H2Cell"] ||
        [((NSString *)cellInfo[@"cell_type"]) isEqual:@"H3Cell"]
       ){
        
        NSString *simpleTableIdentifier = cellInfo[@"cell_type"];
        
        LabelTableViewCell *lblCell = (LabelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier  forIndexPath:indexPath];
        lblCell.label.text = cellInfo[@"data"];
        cell = lblCell;
        
    }else if([((NSString *)cellInfo[@"cell_type"]) isEqual:@"Sticker"]){
        
        NSString *simpleTableIdentifier = @"StickerCell";
        
        StickerTableViewCell *stickerCell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier  forIndexPath:indexPath];
        stickerCell.viewController = self;
        stickerCell.numOfStickers = [checkInTimes count];
        stickerCell.cellInfo = cellInfo;
        cell = stickerCell;
        
    }
    return cell;
    
}

@end
