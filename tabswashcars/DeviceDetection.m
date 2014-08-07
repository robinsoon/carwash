//
//  DeviceDetection.m
//  tabswashcars
//
//  Created by Robinpad on 14-8-7.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "DeviceDetection.h"

@implementation DeviceDetection

+ (BOOL) isIPodTouch
{
    int model = [DeviceDetection detectDevice];
    if (model == MODEL_IPOD_TOUCH || model == MODEL_IPAD){
        //|| model == MODEL_IPHONE_SIMULATOR){
        return YES;
    }else{
        return NO;
    }
    
}



+ (uint) detectDevice {
    NSString *model= [[UIDevice currentDevice] model];
    
    // Some iPod Touch return "iPod Touch", others just "iPod"
    
    NSString *iPodTouch = @"iPod Touch";
    NSString *iPodTouchLowerCase = @"iPod touch";
    NSString *iPodTouchShort = @"iPod";
    NSString *iPad = @"iPad";
    
    NSString *iPhoneSimulator = @"iPhone Simulator";
    
    uint detected;
    
    if ([model compare:iPhoneSimulator] == NSOrderedSame) {
        // iPhone simulator
        detected = MODEL_IPHONE_SIMULATOR;
    }
    else if ([model compare:iPad] == NSOrderedSame) {
        // iPad
        detected = MODEL_IPAD;
    } else if ([model compare:iPodTouch] == NSOrderedSame) {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    } else if ([model compare:iPodTouchLowerCase] == NSOrderedSame) {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    } else if ([model compare:iPodTouchShort] == NSOrderedSame) {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    } else {
        // Could be an iPhone V1 or iPhone 3G (model should be "iPhone")
        struct utsname u;
        
        // u.machine could be "i386" for the simulator, "iPod1,1" on iPod Touch, "iPhone1,1" on iPhone V1 & "iPhone1,2" on iPhone3G
        
        uname(&u);
        
        if (!strcmp(u.machine, "iPhone1,1")) {
            detected = MODEL_IPHONE;
        } else {
            detected = MODEL_IPHONE_3G;
        }
    }
    return detected;
}

+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator {
    NSString *returnValue = @"Unknown";
    
    switch ([DeviceDetection detectDevice]) {
        case MODEL_IPHONE_SIMULATOR:
            if (ignoreSimulator) {
                returnValue = @"iPhone 3G";
            } else {
                returnValue = @"iPhone Simulator";
            }
            break;
        case MODEL_IPOD_TOUCH:
            returnValue = @"iPod Touch";
            break;
        case MODEL_IPHONE:
            returnValue = @"iPhone";
            break;
        case MODEL_IPHONE_3G:
            returnValue = @"iPhone 3G";
            break;
        default:
            break;
    }
    
    return returnValue;
}



@end
