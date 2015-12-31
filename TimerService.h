//
//  TimerService.h
//  CapSpot
//
//  Created by Krzysztof Maciążek on 31/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerService : NSObject

+ (TimerService*)getInstance;
- (void)startRepeatingTimerForMinutes:(NSInteger) minutes;
- (void)invalidateRepeatingTimer;
@end
