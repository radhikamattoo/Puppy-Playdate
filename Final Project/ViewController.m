//  Puppy Playdate App
//  ViewController.m
//  by Dhruv Gupta
//
//  Initial view controller for login/sign up, segue to mapview
//


#import "ViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Goes to next scene if the user already exists
    
    if([PFUser currentUser]) {
        [PFUser logOut];
        [self goToOtherScene:@"toMap"];
    }
    
    [self.usernameField setReturnKeyType:UIReturnKeyDone];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
    
}
/**Goes to the specified scene indicated by the **/
-(void) goToOtherScene : (NSString*) segue {
    //goes to the messaging scene
    [self performSegueWithIdentifier:segue sender:self];

}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   //after a user signs up, bring them to their newly created profile
    if([[segue identifier] isEqualToString:@"postLoginProfileView"]) {
        [segue destinationViewController];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboard:(id)sender;
{
    //so the 'done' button on the keyboard removes it from the view
    [sender becomeFirstResponder];
    [sender resignFirstResponder];
}


/** When signed in then either login or register **/
- (IBAction)signedIn:(id)sender {
    
    //if signing in (self.state = true)
    if(self.signingIn) {
        [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text
            block:^(PFUser *user, NSError *error) {
                    if (user) {
                        //Logged in successfully! (change label to reflect this)
                        self.errorLabel.text = @"Log In Successful!";
                        self.errorLabel.textColor = [UIColor blueColor];
                        
                        //TODO: Go to profile view instead
                        [self goToOtherScene:@"toMap"];
                        
                        NSLog(@"Signed in!");
                        
                    } else {
                        // The login failed so update error label
                        self.errorLabel.text = [error userInfo][@"error"];
                    }
            }];
    }
    //not signing in, but rather signing up for an acct
    else {
        
        PFUser *user = [PFUser user];
        user.username = self.usernameField.text;
        user.password = self.passwordField.text;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Signed up successfull!
                self.errorLabel.text = @"Signed Up!";
                self.errorLabel.textColor = [UIColor blueColor];
            
                //TODO: Go to profile view instead
                [self goToOtherScene:@"toProfile"];
                //initialize the messaging client
                
                NSLog(@"Signed up!");
                
            } else {
                // The sign up failed so update error label
                self.errorLabel.text = [error userInfo][@"error"];
            }
        }];
    }
    
    
         
}

/** Switch state from login to sign up or vice versa **/
- (IBAction)switchedState:(id)sender {
    self.signingIn = !self.signingIn;
    
    //state is changed to login state
    if(self.signingIn) {
        self.registerLabel.text = @"Log In";
        [self.signUpButton setTitle:@"Sign In" forState:UIControlStateNormal];
        [self.switchLoginLabel setTitle:@"Make a new account" forState:UIControlStateNormal];
    }
    //state is changed to register state
    else {
        self.registerLabel.text = @"Register";
        [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [self.switchLoginLabel setTitle:@"I already have an account" forState:UIControlStateNormal];
    }
}
@end
