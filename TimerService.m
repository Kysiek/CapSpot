//
//  TimerService.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 31/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import "TimerService.h"
#import "CapSpotService.h"

@interface TimerService()
@property (weak) NSTimer* repeatingTimer;

@end

@implementation TimerService

static TimerService* timerService;

#pragma mark - API Methods

+ (TimerService*)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerService = [[TimerService alloc] initWithObservers];
    });
    return timerService;
}

- (instancetype)initWithObservers {
    if(self = [super init]) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DashbaordModelErrorNotification object:nil];
    }
    return self;
}

#pragma mark - Notifications
- (void) receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:DashbaordModelErrorNotification]) {
        [self invalidateRepeatingTimer];
    }
}

#pragma mark - methods for timer
- (void)startRepeatingTimerForSeconds:(NSInteger)seconds {
    if(self.repeatingTimer != nil) {
        [self invalidateRepeatingTimer];
    }
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                      target:[CapSpotService getInstance]
                                                    selector:@selector(timerTriggersToUpdateData:)
                                                    userInfo:[self userInfo]
                                                     repeats:YES];
    
    self.repeatingTimer = timer;
}

- (void)invalidateRepeatingTimer {
    if(self.repeatingTimer != nil) {
        [self.repeatingTimer invalidate];
        self.repeatingTimer = nil;
    }
}


#pragma mark - private helpers
- (NSDictionary*)userInfo {
    return @{@"StartDate": [NSDate date]};
}

@end
