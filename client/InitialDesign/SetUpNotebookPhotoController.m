//
//  ViewController.m
//  Parenting+
//
//  Created by TC on 12/1/13.
//  Copyright (c) 2013 Capstone Team B. All rights reserved.
//

#import "SetUpNotebookPhotoController.h"
#import "BehaviorsToKeepViewController.h"
#import "LocalDatabase.h"
#import "NoteBooks.h"
#import "OutlineDBFunction.h"
#import "ImageSelectorViewController.h"
#import "DatePickerViewController.h"
#import "Utils.h"

// saved variables
NSString *oldName;
NSString *oldAge;
NSString *oldPicture;
UIImage *oldImage;
NSString *currentPicture;
int defaultPic;

@interface SetUpNotebookPhotoController ()
@end

@implementation SetUpNotebookPhotoController
BOOL hasSavedNotebook = NO;
BOOL exist = NO;
NSDate *Date;
NSDateFormatter *dateFormat;

@synthesize chosenImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    //self.birthdayPicker = [[UIDatePicker alloc] init];
    [_birthdayPicker addTarget:self  action:@selector(getSelection:) forControlEvents:UIControlEventValueChanged];
    
    if (chosenImage.length > 0){
        defaultPic = 0;
        _choosePhoto.image = [UIImage imageNamed:chosenImage];
    }
    /*
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg_sky_grass.jpg"] drawInRect:self.view.bounds];
    //UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     */
    //self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    // _nextButton.backgroundColor = [UIColor orangeColor];
    //[_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    LocalDatabase *db = [[LocalDatabase alloc] init];
    //NSString *myid = [NSString stringWithFormat:@"%@",db.getCurrentNotebook];
    
    exist = NO;
    if ([db.getCurrentNotebook length] > 0 && [_status isEqualToString:@"New"] == FALSE) {
        _notebook = [[NoteBooks alloc] init];
        _notebook = [_notebook getWholeClassNotebooksFromNotebookID:db.getCurrentNotebook];
        oldName = _childNameTxt.text = [NSString stringWithString:[_notebook getArrayBooks][@"book_name"]];
        oldAge = _birthdayTxt.text = [NSString stringWithString:[_notebook getArrayBooks][@"age"]];
        NSData* imgData = [_notebook getArrayBooks][@"picture"];
        oldImage = [[UIImage alloc] initWithData:imgData];
        [_choosePhoto setImage:oldImage];
        exist = YES;
    }
    if ([chosenImage length] == 0) chosenImage = @"default-pic01.png";
    
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(keyboardHide)];
    tapScroll.cancelsTouchesInView = NO;
    [_nbScrollView addGestureRecognizer: tapScroll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.nbScrollView layoutIfNeeded];
    self.nbScrollView.contentSize = self.contentView.bounds.size;
}

- (IBAction)chooseFromStockClk:(id)sender
{
    
}

- (void)getSelection:(id)sender
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-YYYY"];
    NSDate *pickerDate = [_birthdayPicker date];
    
    NSString *choice = [dateFormat stringFromDate:pickerDate];
    _birthdayTxt.text = choice;
}

// makes the screen raise up so that none of the text fields are blocked by the keyboard
-(IBAction)keyboardAdapter: (UITextField*)textfieldName
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.35];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [textfieldName isFirstResponder])
    {
        //_nbScrollView.frame = CGRectMake(0,(-(textfieldName.frame.origin.y) + 200),320,818);
        [_nbScrollView setContentOffset:CGPointMake(0, ((textfieldName.frame.origin.y) - 200)) animated: YES];
        [UIView commitAnimations];
    }
    if ([[UIScreen mainScreen] bounds].size.height <= 480 && [textfieldName isFirstResponder])
    {
        //[self.view setFrame:CGRectMake(0,(-(textfieldName.frame.origin.y) + 150),320,580)];
        [UIView commitAnimations];
    }
}

// makes the screen return to its normal position after the keyboard has retracted
- (void)keyboardDidHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        //_nbScrollView.frame = CGRectMake(0,0,320, 446);
        [_nbScrollView setContentOffset:CGPointMake(0, 0) animated: YES];
        [UIView commitAnimations];
    }
    else {
        //[self.view setFrame:CGRectMake(0,0,320,446)];
        [UIView commitAnimations];
    }
    
}

// hide the keyboard when user taps outside of keyboard
- (void) keyboardHide
{
    [self.view endEditing:YES];
}

- (IBAction)useCameraClk:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = ([[UIImagePickerController alloc] init]);
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        NSLog(@"%@", imagePicker);
        [self presentViewController:imagePicker animated:YES completion:Nil];
        _newMedia = YES;
    }
}
- (IBAction)cameraRollClk:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        NSLog(@"%@", imagePicker);
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = NO;
    }
}

#pragma mark UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [Utils scaleAndPreserveRatioForImage:info[UIImagePickerControllerOriginalImage]
                                                      toWidth:200.0 andHeight:200.0];
        _choosePhoto.image = image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Save failed" message:@"Failed to save image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// hides keyboard after hitting next
-(BOOL)textFieldReturn:(id)sender
{
    // Does the first textfield have the focus? If yes, go to the next one
    if ([_childNameTxt isFirstResponder])
    {
        [_birthdayTxt becomeFirstResponder];
        return YES;
    }
    else  // No more text fields to fill in, hide the keyboard
    {
        [_birthdayTxt resignFirstResponder];
    }
    return NO;
}




- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"goToBehaviorsToKeepSegue"])
    {
        OutlineDBFunction *function = [[OutlineDBFunction alloc] init];
        BOOL process = [function checkNotebookNameExist:_childNameTxt.text];
        if ([_birthdayTxt.text length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Age Check"
                                                            message:@"The Current Age is Empty, Please use different one!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            // Display the alert to the user
            [alert show];
            return FALSE;
        }
        if (process == TRUE || [_childNameTxt.text length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name Check"
                                                            message:@"The Current Name is already Existed or empty, Please use different one!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            // Display the alert to the user
            [alert show];
            return FALSE;
        }
        // load notebook into database
        if (exist == NO) {
            LocalDatabase *db = [[LocalDatabase alloc] init];
            [db setCurrentNotebook:@""];
            if (_choosePhoto.image != nil) {
                NSData *imgData = UIImagePNGRepresentation(_choosePhoto.image);
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"book_name":_childNameTxt.text,
                                                                                                  @"age":_birthdayTxt.text,
                                                                                                  @"tokens":@"0",
                                                                                                  @"picture":@""}];
                _notebook = [[NoteBooks alloc] initWithNoteBook:dictionary];
                process = [function updateCameraImage:imgData];
            } else {
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"book_name":_childNameTxt.text,
                                                                                                  @"age":_birthdayTxt.text,
                                                                                                  @"tokens":@"0",
                                                                                                  @"picture":chosenImage}];
                _notebook = [[NoteBooks alloc] initWithNoteBook:dictionary];
            }
            exist = YES;
        }  else {
            // this works
            if ([oldName isEqualToString:_childNameTxt.text] == FALSE)
                _notebook = [_notebook updateNotebookWithNewName:_childNameTxt.text fromNotebook:_notebook];
            if ([oldAge isEqualToString:_birthdayTxt.text] == FALSE)
                _notebook = [_notebook updateNotebookWithNewAge:_birthdayTxt.text fromNotebook:_notebook];
            if ([function image:oldImage isEqualTo:_choosePhoto.image] == FALSE) {
                NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(_choosePhoto.image)];
                _notebook = [_notebook updateNotebookWithNewPicture:imgData fromNotebook:_notebook];
            }
            //if ([oldPicture isEqualToString:chosenImage] == FALSE)
            //    _notebook = [_notebook updateNotebookWithNewPicture:chosenImage fromNotebook:_notebook];
        }
        
        // saved old values
        oldAge = [NSString stringWithString:[_notebook getArrayBooks][@"age"]];
        oldName = [NSString stringWithString:[_notebook getArrayBooks][@"book_name"]];
        CGImageRef cgImage = [_choosePhoto.image CGImage];
        oldImage = [[UIImage alloc] initWithCGImage:cgImage];
        //oldPicture = [NSString stringWithString:chosenImage];
    }
    
    return TRUE;
}

- (IBAction)nextClk:(id)sender {
    //[self shouldPerformSegueWithIdentifier:@"goToBehaviorsToKeepSegue" sender:self];
}

- (IBAction)closeButton:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)pickDateClk:(id)sender {
    // Main is the name of the storyboard file where the modal view controller is.
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    // Your modal view controller must have a storyboard id set. In this case,
    // I named it modelViewPage
    DatePickerViewController *modalView = [storyboard instantiateViewControllerWithIdentifier:@"DatePicker"];
    // This is an easy workaround to get the parent view controller that called
    // the modal view controller. In this case, I'm assuming that all view controlelrs
    // that will be displayed as modals should inherite the AbstractModalViewController.
    // Once they do, they will have a property called parent. So, all you have to do now
    // is just set it before you display the view controller and then you can use it
    // from inside the modal view controller.
    modalView.parent = self;
    
    // Now let's do some action. Display the view controller.
    [self presentViewController:modalView
                       animated:YES
                     completion:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // add code to pass data to another view controller during a segue
    if ([[segue identifier] isEqualToString:@"goToBehaviorsToKeepSegue"])
    {
        BehaviorsToKeepViewController *controller = (BehaviorsToKeepViewController*)segue.destinationViewController;
        controller.notebook = _notebook;
    }
}

- (NSString *)saveImage:(UIImage*)image withName:(NSString*)imageName{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.85); //convert image into .png format. //had to fix this to jpeg. Png's dont save roatation information - tom
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imageName]]; //add our image to the path
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    return fullPath;
}


- (IBAction)choosePreMadePhoto:(id)sender {
    // M/Users/capstonestudent/Desktop/kidzplan2-22-3/Main-Project/Design/UI Prototypes/InitialDesign/InitialDesign.xcodeprojain is the name of the storyboard file where the modal view controller is.
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    // Your modal view controller must have a storyboard id set. In this case,
    // I named it modelViewPage
    ImageSelectorViewController *modalView =
    [storyboard instantiateViewControllerWithIdentifier:@"selectPreMadePhotoViewController"];
    modalView.parent = self;
    // Display the view controller.
    [self presentViewController:modalView
                       animated:YES
                     completion:nil];
    
}

@end
