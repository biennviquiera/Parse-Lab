//
//  ChatViewController.m
//  Parse Lab
//
//  Created by Bienn Viquiera on 6/27/22.
//

#import "ChatViewController.h"
#import "ChatCell.h"
#import <Parse/Parse.h>

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) PFObject *chatMessage;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Do any additional setup after loading the view.
    self.chatMessage = [PFObject objectWithClassName:@"Message_FBU2021"];
    self.chatMessage[@"text"] = self.chatMessageField.text;
    self.chatMessage[@"user"] = PFUser.currentUser;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
    
    
    

}
- (IBAction)didTapSend:(id)sender {
    [self.chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
         if (succeeded) {
             NSLog(@"The message was saved!");
             self.chatMessageField.text = @"";
         } else {
             NSLog(@"Problem saving message: %@", error.localizedDescription);
         }
     }];
    
}

//table view methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    
    //get text from array of objects
    PFObject *currentObj = self.arrayOfMessages[indexPath.row];
//    NSLog(@"%@", currentObj);
    cell.cellMessage.text = currentObj[@"text"];
    
    PFUser *user = currentObj[@"user"];
    if (user != nil) {
        // User found! update username label with username
        cell.userLabel.text = user.username;
    } else {
        // No user found, set default username
        cell.userLabel.text = @"🤖";
    }
    return cell;
}

- (void)onTimer {
   // Add code to be run periodically
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Message_FBU2021"];
    [query includeKey:@"user"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
//            NSLog(@"%@", posts);
            self.arrayOfMessages = posts;
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
//    NSLog(@"refresh triggered");
    [self.tableView reloadData];
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
