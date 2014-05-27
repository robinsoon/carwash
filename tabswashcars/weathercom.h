//
//  weathercom.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-23.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>

// 相当于定义一个函数指针
typedef void(^FinishLoadBlock)(NSData *);

@interface weathercom : NSMutableURLRequest <NSURLConnectionDataDelegate>

@property (nonatomic, retain) NSMutableData *data;

@property (nonatomic, retain) NSURLConnection *connection;

@property (nonatomic, copy)FinishLoadBlock block;

- (void)startAsync;

- (void)cancel;


@end
