//
//  CouponsViewCell.h
//  tabswashcars
//
//  Created by Robinpad on 14-6-12.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface CouponsViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbNumber;

@property (weak, nonatomic) IBOutlet UILabel *lbCouponsCode;

@property (weak, nonatomic) IBOutlet UILabel *lbBuyDate;

@property (weak, nonatomic) IBOutlet UILabel *lbStatus;

@property (weak, nonatomic) IBOutlet UILabel *lbName;

@property (strong, nonatomic) NSString * orderID;   //订单ID
@property (strong, nonatomic) NSString * orderSn;   //订单Sn
@property (strong, nonatomic) NSString * orderName;   //订单名称
@property (strong, nonatomic) NSString * Address;
@property (strong, nonatomic) NSString * Phone;

@property (nonatomic) CLLocationCoordinate2D Locationpt; //初始坐标位置




@end
