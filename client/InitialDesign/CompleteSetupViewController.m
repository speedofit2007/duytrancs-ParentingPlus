//
//  CompleteSetupViewController.m
//  Parenting+
//
//  Created by Neil Gebhard on 1/17/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "CompleteSetupViewController.h"
#import "DashboardViewController.h"
#import "LocalDatabase.h"

@interface CompleteSetupViewController ()

@end

@implementation CompleteSetupViewController

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

- (IBAction)completeNotebookClick:(id)sender {
   
    // need to add 'complete' status to notebook in database
    
    [_notebook updateStatusOfNotebookFromNotebook:_notebook];
    LocalDatabase *db = [[LocalDatabase alloc] init];
    [db setCurrentNotebook:@""];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];

    /*
    [self shouldPerformSegueWithIdentifier:@"completeNotebookGoToDashboardSegue" sender:self];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"completeNotebookGoToDashboardSegue"])
    {
    DashboardViewController *controller = (DashboardViewController*)segue.destinationViewController;
    controller.notebook = _notebook;
    }
}

@end
