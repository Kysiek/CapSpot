//
//  DashboardModel.h
//  CapSpot
//
//  Created by Krzysztof Maciążek on 28/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DashboardModel : NSObject
@property (nonatomic) NSInteger freeSpots;
@property (nonatomic, strong) NSDate* lastUpdateDate;
- (instancetype) initWithFreeSpots:(NSInteger)freeSpots lastUpdateDate: (NSDate*)date;
+ (DashboardModel*) dashboardModelFromDictionary:(NSDictionary*)dictionary;
- (NSString*) getDataString;
@end
