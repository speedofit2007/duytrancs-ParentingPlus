//
//  CompleteSetupViewController.h
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteBooks.h"

@interface CompleteSetupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *completeNotebookBtn;
@property (strong, nonatomic) NoteBooks *notebook;

- (IBAction)completeNotebookClick:(id)sender;

@end
