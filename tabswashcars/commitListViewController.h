//
//  commitListViewController.h
//  washcarsbusiness
//
//  Created by Robinpad on 14-8-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "UIImageView+WebCache.h"
#import "washcarsAppDelegate.h"
#import "RatingView.h"
#import "commitDetailListCell.h"

@interface commitListViewController : UITableViewController<RatingViewDelegate>{
    RatingView *starView;
}

@property (nonatomic, retain) IBOutlet RatingView *starView;

@property (weak, nonatomic) IBOutlet UIView *subViewHeader;

@property (weak, nonatomic) IBOutlet UILabel *txtTotal;

@property (weak, nonatomic) IBOutlet UIProgressView *pgsLevel5;

@property (weak, nonatomic) IBOutlet UIProgressView *pgsLevel4;

@property (weak, nonatomic) IBOutlet UIProgressView *pgsLevel3;

@property (weak, nonatomic) IBOutlet UIProgressView *pgsLevel2;

@property (weak, nonatomic) IBOutlet UIProgressView *pgsLevel1;

@property (weak, nonatomic) IBOutlet UITextView *bgScore;

@property (weak, nonatomic) IBOutlet UILabel *txtScore;

@property (weak, nonatomic) IBOutlet UILabel *txtLevel5;

@property (weak, nonatomic) IBOutlet UILabel *txtLevel4;
@property (weak, nonatomic) IBOutlet UILabel *txtLevel3;
@property (weak, nonatomic) IBOutlet UILabel *txtLevel2;
@property (weak, nonatomic) IBOutlet UILabel *txtLevel1;

@property (weak, nonatomic) IBOutlet UITextField *bgCmAll;

@property (weak, nonatomic) IBOutlet UITextField *bgCmBad;

@property (weak, nonatomic) IBOutlet UITextField *bgCmUnRead;

@property (weak, nonatomic) IBOutlet UIButton *btnShowAll;

@property (weak, nonatomic) IBOutlet UIButton *btnShowunRead;

@property (weak, nonatomic) IBOutlet UIButton *btnShowBad;

@property (strong, nonatomic)UIColor *CellBgColor;  //单元格背景色

//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //评价列表
@property (nonatomic,strong) NSMutableArray* listDataBad;  //差评列表
@property (nonatomic,strong) NSMutableArray* listDatanoRead;  //未读评论列表

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

@property (strong, nonatomic) NSString *itemid;           //传入参数id
@property (strong, nonatomic) NSString *itemName;           //传入名称

@property (strong, nonatomic) NSString *itemRank;           //传入总评

@property (strong, nonatomic) NSString *commitid;           //评价ID

@property (strong, nonatomic) NSString *repcontent;           //回复内容

@property (strong, nonatomic) NSString *countbad;           //评价差评
@property (strong, nonatomic) NSString *countnormal;         //中评
@property (strong, nonatomic) NSString *countgood;           //好评

@property (strong, nonatomic) NSString *editTag;            //按钮区分：修改还是回复
@property (nonatomic) int editRow;
@property (nonatomic) int unUnread;
@property (strong, nonatomic) NSString *clearBeforeTag;            //清理未读前的请求标记

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求Web Service
-(void)startRequest;

//翻页
- (int)setPageNext;


@end
