//
//  CapSpotService.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 28/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DashboardModel.h"

extern NSString* const DashbaordModelWillUpdateNotification;
extern NSString* const DashbaordModelArrivalNotification;
extern NSString* const DashbaordModelErrorNotification;
extern NSString* const KeyForErrorInSendingNotification;
extern NSString* const PROD_SERVER_NAME;
extern NSString* const DEV_SERVER_NAME;

@interface CapSpotService : NSObject
@property (nonatomic, strong) DashboardModel* dashboardModel;
+ (CapSpotService*)getInstance;
- (void)updateFreeParkingSpots;
- (void)timerTriggersToUpdateData:(NSTimer*)theTimer;
- (NSString*)getServerString;
- (void)setServerString:(NSString*)selectedServerString;
@end
