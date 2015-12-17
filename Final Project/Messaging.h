//  Puppy Playdate App
//  Messaging.h
//  by Radhika Mattoo and Dhruv Gupta
//
//  Allows users to interact in live-time via Parse
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface Messaging : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, retain) NSMutableArray *chatLog;
@property(nonatomic, retain) PFUser *userClicked;
@property (nonatomic, retain) NSString *chatLogStr;
@property (nonatomic, retain) NSString *objectID;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) int curIndex;

- (IBAction)sendPressed:(id)sender;
@end

