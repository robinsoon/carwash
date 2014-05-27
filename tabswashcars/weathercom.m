//
//  weathercom.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-23.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "weathercom.h"



@implementation weathercom
// 存储异步请求的数据
-(void)startAsync {
    self.data = [[NSMutableData alloc] init];
    // 发起异步请求
    self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
}

- (void)cancel {

    [self.connection cancel];

}

// 异步请求每次返回的数据
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
}

// 异步请求结束数据返回

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {

    self.block(_data);

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"请求网络出错:%@", error);
}


@end

