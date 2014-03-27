//
//  StickerTableViewCell.h
//  InitialDesign
//
//  Created by Basem Elazzabi on 2/25/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackingBehaviorViewController.h"

@interface StickerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *sticker1;
@property (weak, nonatomic) IBOutlet UIButton *sticker2;
@property (weak, nonatomic) IBOutlet UIButton *sticker3;
@property (weak, nonatomic) IBOutlet UIButton *sticker4;

@property (weak, nonatomic) TrackingBehaviorViewController* viewController;

@property (nonatomic,setter = setNumOfStickers:) int numOfStickers;
@property (weak, nonatomic, setter = setCellInfo:) NSDictionary* cellInfo;

- (IBAction)stickerClicked:(id)sender;
- (void)setCellInfo:(NSDictionary *) cellStructure;
- (void)setNumOfStickers:(int)numOfStickers;
- (void)updateButton:(UIButton *)button withSticker:(NSString *) sticker;
@end
