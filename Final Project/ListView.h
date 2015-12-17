//  Puppy Playdate App
//  ListView.h
//  by Radhika Mattoo
//
//  ListView segued from MapView/ProfileView that gives list of nearby users in a minimal fashion using a TableView
//
//

#import <UIKit/UIKit.h>

@interface ListView : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *nearbyUsers;
@property (nonatomic) int rowSelected;
@end
