//
//  DashboardModel.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 28/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import "DashboardModel.h"

@implementation DashboardModel
static NSString* dateFormatter = @"HH:mm dd.MM.yyyy";
static NSString* freeSpotsKey = @"freeParkplaces";
static NSString* lastUpdateKey = @"lastDateUpdate";


+ (DashboardModel*) dashboardModelFromDictionary:(NSDictionary*)dictionary {
    return [[DashboardModel alloc] initWithFreeSpots:[[dictionary objectForKey:freeSpotsKey] integerValue]
                                      lastUpdateDate:[NSDate dateWithTimeIntervalSince1970:([[dictionary objectForKey:lastUpdateKey] doubleValue] / 1000.000)]];
}

- (instancetype)initWithFreeSpots:(NSInteger)freeSpots lastUpdateDate:(NSDate *)date {
    if(self = [super init]) {
        self.freeSpots = freeSpots;
        self.lastUpdateDate = date;
    }
    return self;
}

- (NSString*)getDataString {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatter];
    return [formatter stringFromDate:self.lastUpdateDate];
}
@end