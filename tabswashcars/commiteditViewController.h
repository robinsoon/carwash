//
//  commiteditViewController.h
//  washcarsbusiness
//
//  Created by Robinpad on 14-8-29.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "washcarsAppDelegate.h"
#import "RatingView.h"

@interface commiteditViewController : UIViewController<UITextViewDelegate,RatingViewDelegate>{
    RatingView *starView;
}

@property (nonatomic, retain) IBOutlet RatingView *starView;
@property (nonatomic, retain) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UILabel *txtgoodsname;

@property (weak, nonatomic) IBOutlet UILabel *txtlength;

@property (weak, nonatomic) IBOutlet UITextView *txtContent;

@property (weak, nonatomic) IBOutlet UITextField *txtconnection;

@property (weak, nonatomic) IBOutlet UITextField *txtposition;

@property (weak, nonatomic) IBOutlet UIScrollView *myscrollView;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;


//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

@property (strong, nonatomic) NSString *itemid;           //传入参数id
@property (strong, nonatomic) NSString *itemcontent;           //传入的建议
@property (strong, nonatomic) NSString *itemmode;           //传入的评论原文

@property (strong, nonatomic) NSString *isconnection;           //联系方式
@property (strong, nonatomic) NSString *isposition;           //职位称呼

@property (nonatomic) int wordslimit;

@property (strong, nonatomic) NSString * CouponsCode;
@property (strong, nonatomic) NSString * CouponsStatus;
@property (strong, nonatomic) NSString * CouponsNote;
@property (strong, nonatomic) NSString * CouponsUsedtime;
@property (strong, nonatomic) NSString * CouponsName;
@property (strong, nonatomic) NSString * Address;
@property (strong, nonatomic) NSString * Phone;

@property (strong, nonatomic) NSString *itemrate;   //评论等级
@property (strong, nonatomic) NSString *orderid;    //订单编号
@property (strong, nonatomic) NSString * commitStatus;

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求 Web Service
-(void)startRequest;




@end
