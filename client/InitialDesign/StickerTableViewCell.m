//
//  StickerTableViewCell.m
//  InitialDesign
//
//  Created by Basem Elazzabi on 2/25/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "StickerTableViewCell.h"

@implementation StickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)updateButton:(UIButton *)button withSticker:(NSString *) sticker{
    if([sticker isEqual: self.viewController.stickerImageNames[0]]){
        // No sticker for this button.
        button.selected = NO;
    }else{
        UIImage *image = self.viewController.stickerImages[sticker];
        [button setImage:image forState:UIControlStateSelected];
        button.selected = YES;
    }
    // Update the cell info
    self.cellInfo[@"data"][[NSString stringWithFormat:@"time%i", (int)button.tag]] = sticker;
}

- (void)setCellInfo:(NSDictionary *) cellStructure{
    _cellInfo = cellStructure;
    NSDictionary *data = cellStructure[@"data"];
    [self updateButton: self.sticker1 withSticker:data[@"time1"]];
    [self updateButton: self.sticker2 withSticker:data[@"time2"]];
    [self updateButton: self.sticker3 withSticker:data[@"time3"]];
    [self updateButton: self.sticker4 withSticker:data[@"time4"]];
}

- (IBAction)stickerClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    TrackingBehaviorViewController * vc = self.viewController;
    
    int selSticker = vc.selectedSticker;
    NSMutableDictionary *data = self.cellInfo[@"data"];
    NSString *stickerName;
    int addedTokens = 1;
    
    // If the button already selected, then we need to deselect it. Otherwise,
    // select it. Also, update the database accordingly.
    
    if(btn.selected){
        stickerName = self.viewController.stickerImageNames[0];
        addedTokens = -1;
    }else{
        // Update the button sticker image
        stickerName = vc.stickerImageNames[selSticker];
    }
    
    if(addedTokens < 0 && vc.currBalance == 0){
        [[[UIAlertView alloc] initWithTitle:@"Balance Limit"
                                   message:@"You can't remove more stickers due to zero balance."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil] show];
        return;
    }
    vc.currBalance += addedTokens;
    [self updateButton:btn withSticker:stickerName];
    
    // Update the database.
    // This line should be removed after implementing triggers in the database. -- Basem.
    [vc.notebook updateTokenBalanceWith:addedTokens];
    
    NSString *dataType = (NSString *)self.cellInfo[@"data_type"];
    if([dataType isEqual:@"BTK"]){
        //currentTokenBalance++;
        [vc.function setTrackGoodBehaviorWithTime: vc.currDateStr
                             andGoodBehaviorid: data[@"id"]
                                      andTime1: data[@"time1"]
                                      andTime2: data[@"time2"]
                                      andTime3: data[@"time3"]
                                      andTime4: data[@"time4"]
         ];
    }else if([dataType isEqual:@"BTC"]){
        //currentTokenBalance++;
        [vc.function setTrackChangeBehaviorWithTime: vc.currDateStr
                                andChangeBehaviorId: data[@"id"]
                                           andTime1: data[@"time1"]
                                           andTime2: data[@"time2"]
                                           andTime3: data[@"time3"]
                                           andTime4: data[@"time4"]
         ];
    }
    
}

- (void)setNumOfStickers:(int)numOfStickers{
    _numOfStickers = numOfStickers;
    self.sticker1.hidden = numOfStickers < 1;
    self.sticker2.hidden = numOfStickers < 2;
    self.sticker3.hidden = numOfStickers < 3;
    self.sticker4.hidden = numOfStickers < 4;
}
@end
