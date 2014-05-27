//
//  weatherrequest.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-23.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "weatherrequest.h"
#import "weathercom.h"

#define BASE_URL @"http://www.weather.com.cn/data/sk/"

@implementation weatherrequest
//cityCode = 101121405
+(void)getWeatherData:(NSDictionary *)params block:(Completion )block{
    NSString *cityCode = [params objectForKey:@"code"];

    NSString *urlstring = [BASE_URL stringByAppendingFormat:@"%@.html",cityCode];
    weathercom *request = [weathercom requestWithURL:[NSURL URLWithString:urlstring]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:60];
    request.block = ^(NSData *data) {
        id ret = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //block(ret);
    };
    [request startAsync];
}

@end
