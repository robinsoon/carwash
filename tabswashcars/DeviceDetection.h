//
//  DeviceDetection.h
//  tabswashcars
//
//  Created by Robinpad on 14-8-7.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

enum {
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
    MODEL_IPHONE,
    MODEL_IPHONE_3G,
    MODEL_IPAD
};

@interface DeviceDetection : NSObject
+ (uint) detectDevice;

+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;
+ (BOOL) isIPodTouch;

@end
