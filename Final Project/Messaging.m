//  Puppy Playdate App
//  Messaging.m
//  by Radhika Mattoo and Dhruv Gupta
//
//  Allows users to interact in live-time via Parse
//

#import "Messaging.h"
#import "ProfileView.h"
#import <Parse/Parse.h>

@interface Messaging ()

@end

@implementation Messaging

@synthesize chatLog; //array that holds entire chat
@synthesize userClicked; //user that the current uer is messaging
@synthesize chatLogStr; //string that holds current chat sent
@synthesize  objectID; //holds ID of query for chat log to associate with user
@synthesize  curIndex; //holds count of chatLog array

- (void)viewDidLoad {

    [super viewDidLoad];
    
    //automatically bring up keyboard without autocorrection (takes up screen space)
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.textField becomeFirstResponder];

    //allocate the chatlog array to store conversations
    self.chatLog = [[NSMutableArray alloc]init];
    self.chatLogStr = @"";
    
    //find if the chat exists
    PFQuery *chatLogQuery = [PFQuery queryWithClassName:@"Chat"];
    [chatLogQuery whereKey:@"usersInChat" containsAllObjectsInArray:@[[PFUser currentUser].username, userClicked.username]];
    PFObject *obj = [chatLogQuery getFirstObject];
    
    //if it does set the object id to this
    if(obj) {
        NSLog(@"Found object!");
        objectID = obj.objectId;
        chatLogStr = obj[@"chatLog"];
        [self updateTable];
    }
    else {//otherwise create a new chat
        obj = [PFObject objectWithClassName:@"Chat"];
        obj[@"usersInChat"] = @[[PFUser currentUser].username, userClicked.username];
        [obj saveInBackground];
        objectID = obj.objectId;
    }
    
    
    //ask Parse for updates every 0.2 seconds -- how to get 'live messaging'
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                   selector:@selector(update:) userInfo:nil repeats:YES];
    
    //set table view delegates
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorColor:[UIColor clearColor]];

}

-(void) update: (id) sender {
    //check for any incoming messages
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query getObjectInBackgroundWithId:objectID block:^(PFObject *_Nullable object, NSError*_Nullable error) {
        
        //when the chat log is updated update the table
        if(![chatLogStr isEqualToString:object[@"chatLog"]]) {
            chatLogStr = object[@"chatLog"];
            [self updateTable];
        }
    }];
}

-(void) updateTable {
    
    //updates the table with the chatLogStr
    NSArray *splitStr = [chatLogStr componentsSeparatedByString:@","];
    for(int i = curIndex; i < splitStr.count; i++) {
        [chatLog addObject:[splitStr objectAtIndex:i]];
    }
    //update curIndex
    curIndex = (int)chatLog.count;
    [self.tableView reloadData];
    
    //keep the view at the bottom of the view (to see most recent messages)
    [self scrollToBottom];
    
}

//method to keep screen at bottom of tableview
-(void)scrollToBottom{
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return chatLog.count;
}

//stylize the header text, which is just the username
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //create a label for the header and center it
    UILabel * sectionHeader = [[UILabel alloc] init];
    sectionHeader.textAlignment = NSTextAlignmentCenter;
    
    NSString *fullString = [chatLog objectAtIndex:section];
    NSString *prevUser = @"";
    
   //don't show username again if the previous message was from the same user
    if(section - 1 >= 0) {
        prevUser = [[[chatLog objectAtIndex:section - 1] componentsSeparatedByString:@"-"] objectAtIndex:0];
    }
    NSString *user = [[fullString componentsSeparatedByString:@"-"]objectAtIndex:0];
    if(![prevUser isEqualToString:user])
        sectionHeader.text = [[fullString componentsSeparatedByString:@"-"]objectAtIndex:0];
    else
        sectionHeader.text = @"";
    
    //set orange color for current user, blue for user they're talking to
    if([user isEqualToString:[PFUser currentUser].username])
        sectionHeader.textColor = [UIColor orangeColor];
    else
        sectionHeader.textColor = [UIColor blueColor];
    
    return sectionHeader;
}

//make the user the cell title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /*string is in the format "username-this is what the user says blah blah"*/
    if(chatLog.count == 0){
        return @"";
    }
    
    //get string to insert as Title
    NSString *prevUser = @"";
    if(section - 1 >= 0) {
        prevUser = [[[chatLog objectAtIndex:section - 1] componentsSeparatedByString:@"-"] objectAtIndex:0];
    }
    NSString *fullString = [chatLog objectAtIndex:section];
    NSString *user = [[fullString componentsSeparatedByString:@"-"]objectAtIndex:0];
    
     //don't show username again if the previous message was from the same user
    if([prevUser isEqualToString:user])
        return @"";
    return [[NSMutableString alloc] initWithFormat:@"%@", user];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //just want one row of text per cell
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //dont want separator lines
    [_tableView setSeparatorColor:[UIColor whiteColor]];
    
    //get the string the user sent, separated by -
    NSString *chat;
    NSString *fullString = [chatLog objectAtIndex:indexPath.section];
    NSArray *chatArray = [fullString componentsSeparatedByString:@"-"];
    
    //create cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"myIdentifier"];
    //return empty cell if there's nothing to add
    if(chatLog.count == 0){
        return cell;
    }
    
    //is the chatlog empty?
    if(chatArray.count > 1){
        NSString *user = [[fullString componentsSeparatedByString:@"-"]objectAtIndex:0];
        chat = [[fullString componentsSeparatedByString:@"-"]objectAtIndex:1];
        
        cell.textLabel.text =  fullString;
        cell.textLabel.text = chat;
        
        //set orange color for current user, blue for user they're talking to
        if([user isEqualToString:[PFUser currentUser].username])
            cell.textLabel.textColor = [UIColor orangeColor];
        else
            cell.textLabel.textColor = [UIColor blueColor];
        return cell;
    }
    else{
        return cell;
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //arbitrary size, looks good when run
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //arbitrary size, looks good when run
    return 40;
}
- (IBAction)sendPressed:(id)sender {
    if(![self.textField.text isEqualToString:@""]) {
        
        //get the chat object
        PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
        PFObject *chatObj = [query getObjectWithId:objectID];
        PFUser *curUser = [PFUser currentUser];
        
        //get the text they sent, with the current user's username in the string
        NSString *newChatLog = @"";
        NSString *prevChatLog = chatObj[@"chatLog"];
        if(!prevChatLog){
            newChatLog = [NSString stringWithFormat:@"%@-%@",
                         curUser.username, self.textField.text];
        }
        else{
            newChatLog = [NSString stringWithFormat:@"%@,%@-%@", chatObj[@"chatLog"],
                                curUser.username, self.textField.text];
        }
    
        //update chatlog of user with the string just created
        chatObj[@"chatLog"] = newChatLog;
        NSLog(@"Updated chat log: %@", newChatLog);
        [chatObj saveInBackground];
        chatLogStr = newChatLog;
    
        //clear text field
        self.textField.text = @"";
        
        //send to the tableview
        [self updateTable];
    }
}



- (IBAction)goBack:(id)sender {
    //unwind segue and go back to the profile view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //setting up for profile view segue
    if([[segue identifier] isEqualToString:@"toProfile"]) {
        ProfileView *lv = [segue destinationViewController];
        lv.segueUser = userClicked;
        lv.notEditable = YES;
    }
}


@end
