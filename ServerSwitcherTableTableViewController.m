//
//  ServerSwitcherTableTableViewController.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 04/02/16.
//  Copyright © 2016 Kysiek. All rights reserved.
//

#import "ServerSwitcherTableTableViewController.h"
#import "CapSpotService.h"



@interface ServerSwitcherTableTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *prodTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *devTableViewCell;

@end

@implementation ServerSwitcherTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initStaticCellsWithSelectedServer:[[CapSpotService getInstance] getServerString]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)initStaticCellsWithSelectedServer: (NSString*) selectedServer {
    self.prodTableViewCell.textLabel.text = PROD_SERVER_NAME;
    self.devTableViewCell.textLabel.text = DEV_SERVER_NAME;
    if([selectedServer isEqualToString:PROD_SERVER_NAME]) {
        [self.prodTableViewCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else if([selectedServer isEqualToString:DEV_SERVER_NAME]) {
        [self.devTableViewCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* selectedCellLabelText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    if([selectedCellLabelText isEqualToString:PROD_SERVER_NAME] && [self.prodTableViewCell accessoryType] != UITableViewCellAccessoryCheckmark) {
        [self enableDefaultSelectionForCell:self.prodTableViewCell andDeselect:self.devTableViewCell];
    } else if([selectedCellLabelText isEqualToString:DEV_SERVER_NAME] && [self.devTableViewCell accessoryType] != UITableViewCellAccessoryCheckmark) {
        [self enableDefaultSelectionForCell:self.devTableViewCell andDeselect:self.prodTableViewCell];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* sectionFooterView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,50)];
    sectionFooterView.backgroundColor = [UIColor whiteColor];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(15, 15, sectionFooterView.frame.size.width - 30, 50.0)];
    footerLabel.backgroundColor = [UIColor whiteColor];
    [footerLabel setFont:[UIFont fontWithName:@"Verdana" size:12.0]];
    
    footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    footerLabel.numberOfLines = 0;
    
    footerLabel.text = NSLocalizedString(@"Choose a server you want CapSpot to use as a data source. If you do not know which one to choose leave it as it is by default - PROD.",nil);
    
    [sectionFooterView addSubview:footerLabel];
    
    return sectionFooterView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50.0;
}

#pragma mark - private helpers
-(void)enableDefaultSelectionForCell: (UITableViewCell*) tableViewCellToSelect andDeselect: (UITableViewCell*) tableViewCellToDeselect {
    [tableViewCellToDeselect setAccessoryType:UITableViewCellAccessoryNone];
    [tableViewCellToSelect setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [[CapSpotService getInstance] setServerString:tableViewCellToSelect.textLabel.text];
    
}
@end
