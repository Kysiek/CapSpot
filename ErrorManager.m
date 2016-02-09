//
//  ErrorManager.m
//  CapSpot
//
//  Created by Krzysztof Maciążek on 09/02/16.
//  Copyright © 2016 Kysiek. All rights reserved.
//

#import "ErrorManager.h"

@implementation ErrorManager

const NSString* keyForMessage = @"NSLocalizedDescription";

- (instancetype)initWithMessage:(NSString *)message{
    if(self = [super init]) {
        self.message = message;
    }
    return self;
}
- (instancetype)initWithNSError:(NSError *)error {
    NSDictionary* userInfo = error.userInfo;
    return [self initWithMessage:[userInfo objectForKey:keyForMessage]];
}
@end
