//  Puppy Playdate App
//  ViewController.h
//  by Dhruv Gupta
//
//  Initial view controller for login/sign up, segue to mapview
//


#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *registerLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *switchLoginLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic) BOOL signingIn;

- (IBAction)signedIn:(id)sender;
- (IBAction)switchedState:(id)sender;

@end

