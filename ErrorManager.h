//
//  ErrorManager.h
//  CapSpot
//
//  Created by Krzysztof Maciążek on 09/02/16.
//  Copyright © 2016 Kysiek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorManager : NSObject
@property (nonatomic,strong) NSString* message;
- (instancetype)initWithMessage:(NSString*) message;
- (instancetype)initWithNSError:(NSError*)error;
@end
