//
//  BMBatteryManager.h
//  Battery
//
//  Created by John Kueh on 19/01/2016.
//  Copyright © 2016 Beaconmaker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMBatteryManager : NSObject
+ (BMBatteryManager *)sharedManager;

- (void)setApiKey:(NSString *)apiKey;
- (void)startUpdatingWithInterval:(NSTimeInterval)interval;
- (void)stopUpdating;
@end
