//
//  ImageSelectorViewController.h
//  Parenting+
//
//  Created by Azadi Sean Walsh on 1/24/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"
#import "SetUpNotebookPhotoController.h"

@interface ImageSelectorViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *image1Btn;
@property (weak, nonatomic) IBOutlet UIButton *image2Btn;
@property (weak, nonatomic) IBOutlet UIButton *image3Btn;
@property (weak, nonatomic) IBOutlet UIButton *image4Btn;
@property (weak, nonatomic) IBOutlet UIButton *saveAndContinueBtn;
@property (strong, nonatomic) NoteBooks *notebook;
@property (weak, nonatomic) SetUpNotebookPhotoController* parent;

- (IBAction)image1Clk:(id)sender;
- (IBAction)image2Clk:(id)sender;
- (IBAction)image3Clk:(id)sender;
- (IBAction)image4Clk:(id)sender;
- (IBAction)saveAndContinueClk:(id)sender;

- (IBAction)goBackClk:(id)sender;
@end
