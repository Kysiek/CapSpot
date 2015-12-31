//
//  CapSpotService.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 28/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import "CapSpotService.h"
#import <AFNetworking.h>

NSString* const DashbaordModelWillUpdateNotification = @"DashbaordModelWillUpdateNotification";
NSString* const DashbaordModelArrivalNotification = @"DashbaordModelArrivalNotification";
NSString* const DashbaordModelErrorNotification = @"DashbaordModelErrorNotification";

@implementation CapSpotService

static CapSpotService* networkService;
static NSString* rootURLPath = @"https://mysterious-coast-1799.herokuapp.com";
static NSString* getFreeParkingPlacesRoute = @"freeParkplaces";

BOOL requestIsBeingMade = NO;

#pragma mark - API Methods

+ (CapSpotService*)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkService = [[CapSpotService alloc] init];
    });
    return networkService;
}

- (void)updateFreeParkingSpots {
    if(!requestIsBeingMade) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DashbaordModelWillUpdateNotification object:nil];
        [self httpGETRequestForPath:getFreeParkingPlacesRoute
                            success:^(NSDictionary *resultDictionary) {
                                if(resultDictionary && [resultDictionary isKindOfClass:[NSDictionary class]]) {
                                    self.dashboardModel = [DashboardModel dashboardModelFromDictionary:resultDictionary];
                                }
                                
                                //In the following line a notification is being sent that appropriate JSON had been downloaded
                                [[NSNotificationCenter defaultCenter] postNotificationName:DashbaordModelArrivalNotification object:nil];
                            }
                            failure:^(NSError *error){
                                [[NSNotificationCenter defaultCenter] postNotificationName:DashbaordModelErrorNotification object:nil];
                            }];
    }
    
}

- (void)timerTriggersToUpdateData:(NSTimer*)theTimer {
    [self updateFreeParkingSpots];
}
#pragma mark - Private Helpers
- (void)httpGETRequestForPath:(NSString*)urlPath success:(void(^)(NSDictionary *resultDictionary))success failure:(void(^)(NSError *error))failure {
    requestIsBeingMade = YES;
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@/%@",rootURLPath,urlPath] parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {
        if(success != nil) {
            requestIsBeingMade = NO;
            success((NSDictionary *)responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if(failure != nil) {
            requestIsBeingMade = NO;
            failure(error);
        }
    }];
}

@end
