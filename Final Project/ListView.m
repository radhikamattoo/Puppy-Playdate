//  Puppy Playdate App
//  ListView.m
//  by Radhika Mattoo
//
//  ListView segued from MapView/ProfileView that gives list of nearby users in a minimal fashion using a TableView
//
//

#import "ListView.h"
#import "ProfileView.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
@interface ListView ()
@property CGFloat imageSize;

@property NSMutableString *currentUser;

@property NSMutableString *username;
@property NSMutableString *dogname;
@property NSMutableString *dogbreed;
@property NSMutableString *doginfo;

@end

@implementation ListView
@synthesize nearbyUsers;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    PFUser *curUser = [PFUser currentUser];
    
    ///fill in current user's username
    _currentUser = [NSMutableString stringWithString:curUser.username];

    //fill with first value of _nearbyUsers; is used as header of each table section
    PFUser *user1 = [nearbyUsers objectAtIndex:0];
    _username = [NSMutableString stringWithString:user1.username];
    _dogname = [NSMutableString stringWithString:user1[@"dogName"]];

    //set up table view
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    //tableview style
    _tableView.layer.borderWidth = 2.0;
    _tableView.layer.borderColor = [UIColor orangeColor].CGColor;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //get number of online users from parse and return value
    return nearbyUsers.count;
}
/*
 Always 1, we want each user to have their own section so it sort of mimics instagram
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//setting up the style of the header, which is just "username, dogname"
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //create label
    UILabel * sectionHeader = [[UILabel alloc] init];
    
    //center the text
    sectionHeader.textAlignment = NSTextAlignmentCenter;
    
    //set header style
    sectionHeader.textColor = [UIColor orangeColor];
    sectionHeader.backgroundColor = [UIColor whiteColor];
    sectionHeader.layer.borderColor = [[UIColor orangeColor] CGColor];
    
    //put users into cell in order of nearness (via nearbyusers array)
    PFUser *user = [nearbyUsers objectAtIndex:section];
    NSString *headerText = @"";
    
    //set header text
    headerText =  [[NSMutableString alloc] initWithFormat:@"%@, %@", user.username, user[@"dogName"]];
    sectionHeader.text = headerText;

    return sectionHeader;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //get user/dogname from _nearbyUsers to display in header
    PFUser *user = [nearbyUsers objectAtIndex:section];
    if(!user[@"dogName"]){
        return [[NSMutableString alloc] initWithFormat:@"%@, Dog Enthusiast", user.username];
    }
    return [[NSMutableString alloc] initWithFormat:@"%@, %@", user.username, user[@"dogName"]];

}
/*
 Creates a cell and returns; resizes image to standard size and makes the title of the section the username and dogname
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //create table cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"myIdentifier"];
    
    
    //insert first profile image from PARSE
    UIImage *defaultImage = [UIImage imageNamed: @"image3.jpg"];
    //UIImage *image = [UIImage imageNamed: @"insert current user's image here"];
    
    
    //redraw image so that it fits into an image view centered within the cell
    CGFloat height = cell.frame.size.height*3;
    
    CGFloat width = cell.frame.size.width/2;
    
    CGSize cellSize = CGSizeMake(width *1.5, height*1.5);
    
    UIGraphicsBeginImageContext(cellSize);
    [defaultImage drawInRect:CGRectMake(0, 0, width *1.5, height *1.5)];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //create image view
     PFImageView *imgview = [[PFImageView alloc] initWithImage:cellImage];
    imgview.image = cellImage;
    imgview.file = (PFFile*)[nearbyUsers objectAtIndex:indexPath.section][@"pic1"];
    

    [imgview loadInBackground];
    
    //for heightForRowAtIndexPath function - want to let image fit properly into cell
     _imageSize = cellImage.size.height*1.5;
    
    //center the image within the cell
    imgview.center = CGPointMake(cell.contentView.bounds.size.width/2 + 25,cell.contentView.bounds.size.height*3);
    
    //set up cell properties like bgcolor, text, and location of text within cell
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderColor = [[UIColor orangeColor] CGColor];
    cell.layer.borderWidth = 2.0;
    
    //add image as subview of cell (aka insert image into cell)
    [cell addSubview:imgview];
    
    
    
    return cell;
}
/*
 Set height for cell according to the size of the image
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _imageSize;
}

/*
 For setting the separator line in table cells; ios7+ lets cells implement their own margins independent of the
 table overall
 */
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


/*
 Segues from table view to profile view when row is tapped (i.e. goes to the corresponding profile
 when the cell is tapped)
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //get the cell it selected
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];

    //set dogbreed, doginfo from _nearbyUsers
    self.rowSelected = (int)indexPath.section;
    
    //pass it to the segue
    [self performSegueWithIdentifier:@"toProfile" sender:cell];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //'sender' parameter here is the selected cell

    if ([[segue identifier] isEqualToString:@"toProfile"]){
        //send the username to the Profile view so it knows what profile to bring up
        ProfileView *view = [segue destinationViewController];
       
        //segue setup
        view.segueUser = [nearbyUsers objectAtIndex:self.rowSelected];
        view.notEditable = YES;
        NSLog(@"Segueing to profile");
        
        
    }

}


@end



