//
//  SetUpNotebookPhotoController.h
//  Parenting+SetUpNotebookPicture
//
//  Created by TC on 12/1/13.
//  Copyright (c) 2013 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NoteBooks.h"

@interface SetUpNotebookPhotoController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newMedia;
- (IBAction)cameraRollClk:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollBtn;
@property (weak, nonatomic) IBOutlet UIButton *useCameraBtn;
- (IBAction)useCameraClk:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *chooseFromStockBtn;
- (IBAction)chooseFromStockClk:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *choosePhotoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *choosePhoto;
@property (weak, nonatomic) IBOutlet UITextField *childNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTxt;
- (IBAction)choosePreMadePhoto:(id)sender;

@property (strong, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@property (strong, nonatomic) IBOutlet UIScrollView *nbScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, retain) NSString  *chosenImage;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NoteBooks *notebook;

- (IBAction)nextClk:(id)sender;
- (IBAction)closeButton:(id)sender;
- (void)getSelection:(id)sender;
- (IBAction)pickDateClk:(id)sender;
-(IBAction)keyboardAdapter: (UITextField*)textfieldName;
- (void)keyboardHide;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (NSString *)saveImage:(UIImage*)image withName:(NSString*)imageName;
@end
