//
//  OrderViewCell.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-23.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImg;
@property (weak, nonatomic) IBOutlet UILabel *cellOrder;
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellPrice;
@property (weak, nonatomic) IBOutlet UILabel *cellcmsPrice;
@property (weak, nonatomic) IBOutlet UILabel *cellLeve;
@property (weak, nonatomic) IBOutlet UILabel *cellMemo;
@property (weak, nonatomic) IBOutlet UILabel *cellOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *cellOrderID;
@property (weak, nonatomic) IBOutlet UILabel *cellAmount;
@property (weak, nonatomic) IBOutlet UILabel *cellOrdersn;
@property (weak, nonatomic) IBOutlet UILabel *cellrow;

@end
