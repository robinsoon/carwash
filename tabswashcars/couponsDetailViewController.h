//
//  couponsDetailViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-6-12.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PoiSearchViewController.h"
#import "OrderDetailViewController.h"


@interface couponsDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *lbCouponsCode;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbnote;
@property (weak, nonatomic) IBOutlet UILabel *lbusedtime;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UITextView *lbAddress;
@property (weak, nonatomic) IBOutlet UITextView *lbPhone;

@property (weak, nonatomic) IBOutlet UIButton *btntoMap;
@property (weak, nonatomic) IBOutlet UIButton *btnShowOrder;


@property (strong, nonatomic) NSString * CouponsCode;
@property (strong, nonatomic) NSString * CouponsStatus;
@property (strong, nonatomic) NSString * CouponsNote;
@property (strong, nonatomic) NSString * CouponsUsedtime;
@property (strong, nonatomic) NSString * CouponsName;
@property (strong, nonatomic) NSString * orderID;
@property (strong, nonatomic) NSString * Address;
@property (strong, nonatomic) NSString * Phone;

@property (strong, nonatomic) NSString * goodsid;
@property (strong, nonatomic) NSString * commitStatus;

@property (nonatomic) CLLocationCoordinate2D Locationpt; //初始坐标位置

@end
