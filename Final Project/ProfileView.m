//  Puppy Playdate App
//  ProfileView.m
//  by Radhika Mattoo
//
//  Profile view for both current user and viewing other users' profiles. Uses scroll view for the 4 images of a profile
//  Segues to Messaging, TableView, and MapView
//

#import "ProfileView.h"
#import "ListView.h"
#import "Messaging.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>


@interface ProfileView ()
@property (weak, nonatomic) IBOutlet UIButton *done;

@property (weak, nonatomic) IBOutlet UIButton *message;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *addImage;
@property NSMutableArray *images;
@property (nonatomic) int numImages;
@property CGFloat scrollheight;
@property CGFloat scrollwidth;
@end

@implementation ProfileView
@synthesize edit;
@synthesize notEditable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set scroll width/height variables for future use; taken from storyboard
    _scrollheight = 341;
    _scrollwidth = 355;
    
    
    //check if the username passed from list view equals that of the user
    //if it does, enable the edit button. otherwise leave them disabled
    _addImage.hidden = YES;
    _message.hidden = NO;
    
    //notEditable is used by other views when seguing to profile view to indicate own profile or other user's profile
    edit.hidden = self.notEditable;
    
    //it's the user's profile, allow editing and adding images
    if(!edit.hidden) {
        PFUser *curUser = [PFUser currentUser];
        _segueUser = curUser;
        _addImage.hidden = NO;
        _message.hidden = YES;
        
        NSLog(@"Edit isn't hidden");
    }
    
    
    [_username setText:_segueUser.username];
    [_dogname setText: _segueUser[@"dogName"]];
    [_dogbreed setText: _segueUser[@"dogBreed"]];
    [_doginfo setText: _segueUser[@"dogDescription"]];

    _dogname.userInteractionEnabled = NO;
    _dogbreed.userInteractionEnabled = NO;
    _doginfo.userInteractionEnabled = NO;
    
    //make borders invisible
    _dogname.layer.borderColor=[[UIColor orangeColor]CGColor];
     _dogbreed.layer.borderColor=[[UIColor orangeColor]CGColor];
     _doginfo.layer.borderColor=[[UIColor orangeColor]CGColor];
    
    [_dogname setReturnKeyType:UIReturnKeyDone];
    [_dogbreed setReturnKeyType:UIReturnKeyDone];
    [_doginfo setReturnKeyType:UIReturnKeyDone];
    
    //should never be enabled
    _username.userInteractionEnabled = NO;
    
    //instantiate images array
    _images = [[NSMutableArray alloc] init];
    
    
    //if we're looking at someone ELSE's profile and they only have, say, 3 images, then we restrict the scroll view
    //size to scrollwidth*_images.count
    _numImages = 4;
    
    //get images for specific user from PARSE
    UIImage *image1 = [UIImage imageNamed:@"image3.jpg"]; //just a filler to see how it looks
    UIImage *image2 = [UIImage imageNamed: @"image3.jpg"];
    UIImage *image3 = [UIImage imageNamed: @"image3.jpg"];
    UIImage *image4 = [UIImage imageNamed: @"image3.jpg"];
    
    //375, 253 are the width, height of the allocated scrollview in ProfileView
    [_images addObject:image1];
    [_images addObject:image2];
    [_images addObject:image3];
    [_images addObject:image4];
    
    //Adds all the images to the scroll view
    for(int i = 1; i <= 4; i++) {
        UIImage *image = [_images objectAtIndex:(i - 1)];
        PFImageView *imageView = [[PFImageView alloc] initWithFrame: CGRectMake(_scrollwidth * (i - 1), 0, _scrollwidth, _scrollheight)];
        imageView.image = image;
        imageView.file = (PFFile *)_segueUser[[NSString stringWithFormat:@"pic%d",i]];
        imageView.tag = i;
        [imageView loadInBackground];
        _numImages = i;
        [_images replaceObjectAtIndex:(i-1) withObject:imageView];
        if(imageView.file == NULL) {
            //only show image if first image or editable
            if(!edit.hidden || i == 1)
                [_scrollView addSubview:imageView];
            break;
        } else
            [_scrollView addSubview:imageView];
        
    }
    
   
    
    _scrollView.contentSize = CGSizeMake(_scrollwidth*_numImages,_scrollheight);
    _scrollView.pagingEnabled = YES;
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated{
}

- (IBAction)editTap:(UIButton *)sender {
    [edit setTitle:@"Edit Mode" forState:UIControlStateNormal];
    edit.userInteractionEnabled = NO;
    
    
    _dogname.userInteractionEnabled = YES;
    _dogbreed.userInteractionEnabled = YES;
    _doginfo.userInteractionEnabled = YES;
    
    //set borders
    _dogname.layer.cornerRadius=8.0f;
    _dogname.layer.masksToBounds=YES;
    _dogname.layer.borderColor=[[UIColor orangeColor]CGColor];
    _dogname.layer.borderWidth= 1.0f;
    
    _dogbreed.layer.cornerRadius=8.0f;
    _dogbreed.layer.masksToBounds=YES;
    _dogbreed.layer.borderColor=[[UIColor orangeColor]CGColor];
    _dogbreed.layer.borderWidth= 1.0f;
    
    _doginfo.layer.cornerRadius=8.0f;
    _doginfo.layer.masksToBounds=YES;
    _doginfo.layer.borderColor=[[UIColor orangeColor]CGColor];
    _doginfo.layer.borderWidth= 1.0f;

}

- (IBAction)doneTap:(UIButton *)sender {
    
    //if the user is just editing, we want them pressing 'done' to just stop edit mode.
    if(_dogname.userInteractionEnabled){
        //check to make sure no entries are empty and that they've uploaded 4 pictures
        if([_dogname.text isEqualToString:@""] || [_dogbreed.text isEqualToString:@""]  || [_doginfo.text isEqualToString:@""] || ([PFUser currentUser][@"pic4"] == nil)){
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Wait!"
                                                                           message:@"You must fill have all fields completed before proceeding!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            //reset values
            [self.view endEditing:YES];
            edit.userInteractionEnabled = YES;
            [edit setTitle:@"Edit" forState:UIControlStateNormal];
            
            //dont want user interaction
            _dogname.userInteractionEnabled = NO;
            _dogbreed.userInteractionEnabled = NO;
            _doginfo.userInteractionEnabled = NO;
            
            //make borders invisible again
            _dogname.layer.borderColor=[[UIColor whiteColor]CGColor];
            _dogbreed.layer.borderColor=[[UIColor whiteColor]CGColor];
            _doginfo.layer.borderColor=[[UIColor whiteColor]CGColor];
            
            
            //if any of the user information has changed, send to PARSE
            PFUser *user = [PFUser currentUser];
            user[@"dogName"] = _dogname.text;
            user[@"dogBreed"] = _dogbreed.text;
            user[@"dogDescription"] = _doginfo.text;
        }
        
    }
    //else, they're segueing back to whichever view they came from
    else{
        [self dismissViewControllerAnimated: YES completion: nil];
    }

}
- (void) editMode{
    [edit setTitle:@"Edit Mode" forState:UIControlStateNormal];
    edit.userInteractionEnabled = NO;
    
    //set all values to editable
    _dogname.userInteractionEnabled = YES;
    _dogbreed.userInteractionEnabled = YES;
    _doginfo.userInteractionEnabled = YES;
    
    //set borders for readability while editing
    _dogname.layer.cornerRadius=8.0f;
    _dogname.layer.masksToBounds=YES;
    _dogname.layer.borderColor=[[UIColor orangeColor]CGColor];
    _dogname.layer.borderWidth= 1.0f;
    
    _dogbreed.layer.cornerRadius=8.0f;
    _dogbreed.layer.masksToBounds=YES;
    _dogbreed.layer.borderColor=[[UIColor orangeColor]CGColor];
    _dogbreed.layer.borderWidth= 1.0f;
    
    _doginfo.layer.cornerRadius=8.0f;
    _doginfo.layer.masksToBounds=YES;
    _doginfo.layer.borderColor=[[UIColor orangeColor]CGColor];
    _doginfo.layer.borderWidth= 1.0f;
}

 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if([[segue identifier] isEqualToString:@"toMessaging"]) {
         Messaging *lv = (Messaging*)[segue destinationViewController];
         lv.userClicked = _segueUser;
     }
 }

-(void)textFieldDidBeginEditing:(UITextField *)textField { //Keyboard becomes visible
    
   // self.view.center =  CGPointMake(200, 150);
}

//to make the keyboard dissapear when done is tapped
- (IBAction)dismissKeyboard:(id)sender;
{
    [sender becomeFirstResponder];
    [sender resignFirstResponder];
}

/*
 Creates an image picker to bring up the camera roll to let the user select an image
 */

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    //is the library currently available?
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    //initialize the picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    // Displays saved pictures and movies
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    mediaUI.allowsEditing = YES;
    
    
    mediaUI.delegate = delegate;
    [self presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}
//handles the image that's returned from the camera roll
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        //find free frame within scroll view and place it into that page
        CGFloat width = _scrollView.frame.size.width;
        int page = (int)(_scrollView.contentOffset.x + (0.5 * width)) / width + 1;
        NSLog(@"Page is: %d", page);
        NSString *fileUsed = [NSString stringWithFormat:@"pic%d", page];
        
        //save image to Parse
        NSData* imageData = UIImagePNGRepresentation(imageToUse);
        PFFile *uploadFile = [PFFile fileWithData:imageData];
        [uploadFile save];
        
        PFUser *user = _segueUser;
        [user setObject:uploadFile forKey:fileUsed];
        [user saveInBackground];
        
        
        PFImageView *prevView = (PFImageView*)[_images objectAtIndex:(page - 1)];
        [prevView removeFromSuperview];
        
        //place image into an imageview
        PFImageView *imageView = [[PFImageView alloc] initWithFrame: CGRectMake(_scrollwidth * (page - 1), 0, _scrollwidth, _scrollheight)];
        imageView.image = prevView.image;
        imageView.file = uploadFile;
        [imageView loadInBackground];
        
        [_images replaceObjectAtIndex:(page-1) withObject:imageView];
        
        //place the imageview into the scroll view
        [_scrollView addSubview:imageView];
       
        //increase the width of the scroll view
        //if there are less than 4 images now
        if(page == _numImages && _numImages < 4) {
            
            _numImages++;
            _scrollView.contentSize = CGSizeMake(_scrollwidth*_numImages,_scrollheight);
            PFImageView *imageView2 = [[PFImageView alloc] initWithFrame: CGRectMake(_scrollwidth * (_numImages - 1), 0, _scrollwidth, _scrollheight)];
            imageView2.image = (UIImage*)[_images objectAtIndex:(_numImages - 1)];
            [imageView2 loadInBackground];
            [_images replaceObjectAtIndex:(_numImages-1) withObject:imageView2];
            [_scrollView addSubview:imageView2];
        }
        
    }
    //dismiss the camera roll view
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //if they don't pick a picture, just remove the camera roll from the view
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

//Did the user press 'add button'? 
- (IBAction)bringUpCamera:(id)sender {
    [self startMediaBrowserFromViewController: self
                                usingDelegate: self];
    
}


@end
