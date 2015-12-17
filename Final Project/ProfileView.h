//  Puppy Playdate App
//  ProfileView.h
//  by Radhika Mattoo
//
//  Profile view for both current user and viewing other users' profiles. Uses scroll view for the 4 images of a profile
//  Segues to Messaging, TableView, and MapView
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface ProfileView : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UITextField *dogname;
@property (weak, nonatomic) IBOutlet UITextField *dogbreed;
@property (weak, nonatomic) IBOutlet UITextField *doginfo;
@property (weak, nonatomic) IBOutlet UIButton *edit;

//for sending information to Profile View from List View segue 
@property PFUser *segueUser;
@property (nonatomic) bool notEditable;

@end

