//
//  SetUpNotebookPhotoControllerTutorials.m
//  InitialDesign
//
//  Created by David Wiza on 2/3/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "SetUpNotebookPhotoControllerTutorials.h"
#import "Tutorials.h"

extern Tutorials *tutorials;


@interface SetUpNotebookPhotoControllerTutorials ()

@end

@implementation SetUpNotebookPhotoControllerTutorials

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
	// Do any additional setup after loading the view.
    [tutorials showTutorialOnControl:self.choosePhoto withID:TUT_PHOTO_1 inView:self.contentView withOrientation:POINTING_NONE withCallback:NULL fromSender:self];
}

- (void) keyboardHide
{
    [super keyboardHide];
    [tutorials hideTutorial];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
	[tutorials hideTutorial];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
