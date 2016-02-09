//
//  SettingsViewControllerTableViewController.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 30/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import "SettingsViewControllerTableViewController.h"
#import "TimerService.h"
#import "CapSpotService.h"

@interface SettingsViewControllerTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *refreshTimeLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *refreshTimePickerCell;
@property (weak, nonatomic) IBOutlet UIPickerView *refreshTimePickerView;
@property (nonatomic, strong) NSArray* refreshTimePickerViewElements;
@property (nonatomic, strong) NSDictionary* refreshTimeMap;

@property (nonatomic) NSInteger selectRefreshTime;
@property (nonatomic) NSInteger previouslySelectedRefreshTime;
@end

@implementation SettingsViewControllerTableViewController

static NSInteger const refreshSection = 0;
static NSInteger const capSpotServerSection = 1;
static NSInteger const refreshTimePickerIndex = 2;
static NSInteger const refreshTimeCellIndex = 1;
static NSInteger const capSpotServerCellIndex = 0;
static NSInteger const selectedServerLabelTag = 1;
static CGFloat const refreshTimePickerCellHeight = 164.0f;

BOOL refreshTimePickerIsShowing = NO;
BOOL automaticRefreshSwitchIsOn = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshTimePickerViewElements = @[@"10 seconds", @"30 seconds", @"1 minute"];
    self.refreshTimeMap = @{self.refreshTimePickerViewElements[0] : @10,
                            self.refreshTimePickerViewElements[1]: @30,
                            self.refreshTimePickerViewElements[2]: @60};
    self.selectRefreshTime = 0;
    self.previouslySelectedRefreshTime = -1;
    [self setupRefreshTimeLabel];
}
- (void)viewWillAppear:(BOOL)animated {
    [self initializeSwitchServerCell];
}

- (void)initializeSwitchServerCell {
    UITableViewCell* capSpotServerCell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:capSpotServerCellIndex inSection:capSpotServerSection]];
    UILabel* selectedServerLabel = [capSpotServerCell viewWithTag:selectedServerLabelTag];
    selectedServerLabel.text = [[CapSpotService getInstance] getServerString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)didChangeAutomaticRefreshSwitch:(id)sender {
    UISwitch* automaticRefreshSwitch = (UISwitch*)sender;
    if(automaticRefreshSwitch.on) {
        automaticRefreshSwitchIsOn = YES;
        [self startTimer];
    } else {
        automaticRefreshSwitchIsOn = NO;
        [self stopTimer];
    }
    [self.tableView reloadData];
}
#pragma mark - PickerView delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.refreshTimePickerViewElements.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return NSLocalizedString(self.refreshTimePickerViewElements[row], nil);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectRefreshTime = row;
    [self setupRefreshTimeLabel];
}
#pragma mark - Table view delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.row == refreshTimePickerIndex){
        height =  refreshTimePickerIsShowing ? refreshTimePickerCellHeight : 0.0f;
    } else if (indexPath.row > 0) {
        height =  automaticRefreshSwitchIsOn ? 44.0f : 0.0f;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == refreshTimeCellIndex && indexPath.section == refreshSection) {
        if(refreshTimePickerIsShowing) {
            [self hideRefreshTimePickerCell];
            if(self.previouslySelectedRefreshTime != self.selectRefreshTime) {
                [self startTimer];
            }
        } else {
            [self showRefreshTimePickerCell];
            self.previouslySelectedRefreshTime = self.selectRefreshTime;
        }
    } else if(indexPath.row == capSpotServerCellIndex && indexPath.section == capSpotServerSection) {
        [self performSegueWithIdentifier:@"chooseCapSpotServerSeque" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - private Helpers

- (void)setupRefreshTimeLabel {
    self.refreshTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Refresh dashboard every: %@", nil), NSLocalizedString(self.refreshTimePickerViewElements[self.selectRefreshTime],nil)];
}
- (void)showRefreshTimePickerCell {
    refreshTimePickerIsShowing = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.refreshTimePickerView.hidden = NO;
    self.refreshTimePickerView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.refreshTimePickerView.alpha = 1.0f;
        
    }];
}

- (void)hideRefreshTimePickerCell {
    
    refreshTimePickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.refreshTimePickerView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.refreshTimePickerView.hidden = YES;
                     }];
}
- (void) startTimer {
    [[TimerService getInstance] startRepeatingTimerForSeconds:[[self.refreshTimeMap objectForKey:self.refreshTimePickerViewElements[self.selectRefreshTime]] integerValue]];
}
- (void) stopTimer {
    [[TimerService getInstance] invalidateRepeatingTimer];
}

@end
