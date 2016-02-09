//
//  CapSpotService.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 28/12/15.
//  Copyright © 2015 Kysiek. All rights reserved.
//

#import "CapSpotService.h"
#import <AFNetworking.h>
#import "ErrorManager.h"

NSString* const DashbaordModelWillUpdateNotification = @"DashbaordModelWillUpdateNotification";
NSString* const DashbaordModelArrivalNotification = @"DashbaordModelArrivalNotification";
NSString* const DashbaordModelErrorNotification = @"DashbaordModelErrorNotification";
NSString* const KeyForErrorInSendingNotification = @"KeyForErrorInSendingNotification";
NSString* const PROD_SERVER_NAME = @"PROD";
NSString* const DEV_SERVER_NAME = @"DEV";

@interface CapSpotService ()
@property (nonatomic,strong) NSString* selectedServerString;
@property (nonatomic,strong) NSDictionary* serverDictionary;

@end
@implementation CapSpotService

static CapSpotService* capSpotService;
static NSString* devURLPath = @"https://mysterious-coast-1799.herokuapp.com";
static NSString* prodURLPath = @"https://mysterious-coast-1799.herokuapp.com";
static NSString* keyForSelectedServerInUserDefaults = @"selectedServer";
static NSString* getFreeParkingPlacesRoute = @"freeParkplaces";

BOOL requestIsBeingMade = NO;

#pragma mark - API Methods

+ (CapSpotService*)getInstance {
    if(capSpotService == nil) {
        capSpotService = [[CapSpotService alloc] init];
        [capSpotService loadDataFromUserDefaults];
        [capSpotService initializeServerDictionary];
    }
    return capSpotService;
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
                            failure:^(ErrorManager *error){
                                NSDictionary* dictionaryToSend = [NSDictionary dictionaryWithObject:error forKey:KeyForErrorInSendingNotification];
                                [[NSNotificationCenter defaultCenter] postNotificationName:DashbaordModelErrorNotification object:nil userInfo:dictionaryToSend];
                            }];
    }
}

- (void)timerTriggersToUpdateData:(NSTimer*)theTimer {
    [self updateFreeParkingSpots];
}
- (void)setServerString:(NSString *)selectedServerString {
    if(selectedServerString != nil) {
        NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:selectedServerString forKey:keyForSelectedServerInUserDefaults];
        self.selectedServerString = selectedServerString;
        [self updateFreeParkingSpots];
    }
}
- (NSString*)getServerString {
    if(self.selectedServerString == nil) {
        [self loadDataFromUserDefaults];
    }
    return self.selectedServerString;
}
#pragma mark - Private Helpers
- (void)httpGETRequestForPath:(NSString*)urlPath
                      success:(void(^)(NSDictionary *resultDictionary))success
                      failure:(void(^)(ErrorManager *error))failure {
    
    requestIsBeingMade = YES;
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@/%@",[self.serverDictionary objectForKey:self.selectedServerString],urlPath] parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {
        if(success != nil) {
            requestIsBeingMade = NO;
            success((NSDictionary *)responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if(failure != nil) {
            requestIsBeingMade = NO;
            failure([[ErrorManager alloc] initWithNSError:error]);
        }
    }];
}
- (void)loadDataFromUserDefaults {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString* selectedServerFromUserDefaults = [prefs stringForKey:keyForSelectedServerInUserDefaults];
    self.selectedServerString = selectedServerFromUserDefaults == nil ? PROD_SERVER_NAME : selectedServerFromUserDefaults;
}
- (void)initializeServerDictionary {
    self.serverDictionary = @{
                              PROD_SERVER_NAME: prodURLPath,
                              DEV_SERVER_NAME: devURLPath
                              };
}
@end
