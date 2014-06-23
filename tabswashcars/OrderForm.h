//
//  OrderForm.h
//  tabswashcars
//
//  Created by Robinpad on 14-6-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXForms.h"

@interface OrderForm : NSObject <FXForm>
@property (nonatomic, copy) NSString *itemname;
@property (nonatomic, assign) NSNumber *itemprice;
@property (nonatomic, assign) NSUInteger *itemamount;
@property (nonatomic, copy) NSString *itemid;
@property (nonatomic, copy) NSString *totalprice;
@property (nonatomic, copy) NSString *orderid;
@end
