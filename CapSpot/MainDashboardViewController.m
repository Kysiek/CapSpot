//
//  ViewController.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 20/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import "MainDashboardViewController.h"
#import "CapSpotService.h"
#import "ErrorManager.h"

@interface MainDashboardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *freeSpotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (strong, nonatomic) CapSpotService* capSpotService;

@end

@implementation MainDashboardViewController
BOOL animating;
#pragma mark - UIViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.capSpotService = [CapSpotService getInstance];
    //At the beginning we have to trigger downloading information about free parking spots
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DashbaordModelArrivalNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DashbaordModelWillUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DashbaordModelErrorNotification object:nil];

    [self triggerDownloadingDataIfPossible];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notifications
- (void) receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:DashbaordModelArrivalNotification]) {
        [self updateFreeSpotsLabel];
        [self updateLastUpdateLabel];
        [self stopSpin];
    } else if ([[notification name] isEqualToString:DashbaordModelWillUpdateNotification]) {
        [self startSpin];
    } else if ([[notification name] isEqualToString:DashbaordModelErrorNotification]) {
        [self stopSpin];
        self.lastUpdateLabel.text = @"?";
        self.freeSpotsLabel.text = @"?";
        self.freeSpotsLabel.textColor = [UIColor whiteColor];
        [self createNotificationAboutError:[[notification userInfo] objectForKey:KeyForErrorInSendingNotification]];
    }
}

#pragma mark - UIActions
- (IBAction)didTapRefreshButton:(id)sender {
    [self triggerDownloadingDataIfPossible];
}

#pragma mark - Private Helpers

- (void)triggerDownloadingDataIfPossible {
    [self.capSpotService updateFreeParkingSpots];
}

- (void)updateFreeSpotsLabel {
    NSInteger freeSpots = self.capSpotService.dashboardModel.freeSpots;
    self.freeSpotsLabel.text = [NSString stringWithFormat:@"%ld",(long)freeSpots];
    [self setFreeSpotsLabelColor:freeSpots];
}
- (void)setFreeSpotsLabelColor:(NSInteger)freeSpots {
    UIColor* color;
    if(freeSpots > 60) {
        color = [UIColor colorWithRed:99.0/255.0 green:185.0/255.0 blue:0 alpha:1];
    } else if(freeSpots > 30) {
        color = [UIColor colorWithRed:204.0/255.0 green:158.0/255.0 blue:0 alpha:1];
    } else {
        color = [UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:1];
    }
    self.freeSpotsLabel.textColor = color;
}
- (void)updateLastUpdateLabel {
    self.lastUpdateLabel.text = [self.capSpotService.dashboardModel getDataString];
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.refreshButton.imageView.transform = CGAffineTransformRotate(self.refreshButton.imageView.transform, M_PI / 2			);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}
- (void) startSpin {
    if (!animating) {
        self.refreshButton.enabled = FALSE;
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveLinear];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
    self.refreshButton.enabled = TRUE;
}

- (void)createNotificationAboutError:(ErrorManager*)error {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error",nil)
                                                                   message:error.message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
