//
//  OrderForm.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "OrderForm.h"

@implementation OrderForm
- (NSArray *)fields
{
    return @[
             
             //we want to add a group header for the field set of fields
             //we do that by adding the header key to the first field in the group
             
             @{FXFormFieldKey: @"itemname", FXFormFieldTitle:@"商品", FXFormFieldHeader: @"购买"},
             
             //we don't need to modify these fields at all, so we'll
             //just refer to them by name to use the default settings
             @{FXFormFieldKey: @"itemprice", FXFormFieldTitle:@"单价"},
             @{FXFormFieldKey: @"itemamount", FXFormFieldTitle:@"数量", FXFormFieldCell: [FXFormStepperCell class]},
             @{FXFormFieldKey: @"totalprice", FXFormFieldTitle:@"总价",FXFormFieldHeader: @"统计"},
             
             
             @{FXFormFieldTitle: @"提交订单", FXFormFieldHeader: @"", FXFormFieldAction: @"submitOrderForm:"},
             
             ];
}

@end
