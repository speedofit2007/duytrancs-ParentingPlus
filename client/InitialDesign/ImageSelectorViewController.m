//
//  ImageSelectorViewController.m
//  Parenting+
//
//  Created by Sean Walsh on 1/24/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "ImageSelectorViewController.h"
#import "SetUpNotebookPhotoController.h"

@interface ImageSelectorViewController ()

@end

@implementation ImageSelectorViewController
NSString *imageSelected;

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
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveAndContinueClk:(id)sender
{
    self.parent.chosenImage = imageSelected;
    self.parent.choosePhoto.image = [UIImage imageNamed:imageSelected];
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
    [self shouldPerformSegueWithIdentifier:@"savePhotoSelectionReturnToNotebookSetup" sender:self];
     */
}

- (IBAction)goBackClk:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"savePhotoSelectionReturnToNotebookSetup"])
    {
        return YES;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"savePhotoSelectionReturnToNotebookSetup"])
    {
        SetUpNotebookPhotoController *controller = (SetUpNotebookPhotoController*)segue.destinationViewController;
        controller.chosenImage = imageSelected;
    }
}

- (IBAction)image1Clk:(id)sender {
    imageSelected = @"default-pic01.png";
    _image1Btn.layer.borderColor = [[UIColor blackColor]CGColor];
    _image1Btn.layer.borderWidth = 1.0f;
    
    _image2Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image2Btn.layer.borderWidth = 1.0f;
    
    _image3Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image3Btn.layer.borderWidth = 1.0f;
    
    _image4Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image4Btn.layer.borderWidth = 1.0f;
    
    _saveAndContinueBtn.enabled = YES;
}

- (IBAction)image2Clk:(id)sender {
    imageSelected = @"default-pic02.png";
    _image2Btn.layer.borderColor = [[UIColor blackColor]CGColor];
    _image2Btn.layer.borderWidth = 1.0f;

    _image1Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image1Btn.layer.borderWidth = 1.0f;
    
    _image3Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image3Btn.layer.borderWidth = 1.0f;
    
    _image4Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image4Btn.layer.borderWidth = 1.0f;
    
    _saveAndContinueBtn.enabled = YES;
}

- (IBAction)image3Clk:(id)sender {
    imageSelected = @"default-pic03.png";
    _image3Btn.layer.borderColor = [[UIColor blackColor]CGColor];
    _image3Btn.layer.borderWidth = 1.0f;

    _image1Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image1Btn.layer.borderWidth = 1.0f;
    
    _image2Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image2Btn.layer.borderWidth = 1.0f;
    
    _image4Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image4Btn.layer.borderWidth = 1.0f;

    _saveAndContinueBtn.enabled = YES;

}

- (IBAction)image4Clk:(id)sender {
    imageSelected = @"default-pic04.png";
    _image4Btn.layer.borderColor = [[UIColor blackColor]CGColor];
    _image4Btn.layer.borderWidth = 1.0f;

    _image1Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image1Btn.layer.borderWidth = 1.0f;
    
    _image2Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image2Btn.layer.borderWidth = 1.0f;
    
    _image3Btn.layer.borderColor = [[UIColor clearColor]CGColor];
    _image3Btn.layer.borderWidth = 1.0f;

    _saveAndContinueBtn.enabled = YES;
}
@end
