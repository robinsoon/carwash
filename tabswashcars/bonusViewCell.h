//
//  bonusViewCell.h
//  tabswashcars
//
//  Created by Robinpad on 14-6-17.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface bonusViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbname;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;

@property (weak, nonatomic) IBOutlet UISwitch *selectBonus;

@property (weak, nonatomic) IBOutlet UILabel *lbTypeid;

@property (weak, nonatomic) IBOutlet UILabel *lbbonusID;

@property (weak, nonatomic) IBOutlet UILabel *lbStatus;

@property (weak, nonatomic) IBOutlet UILabel *lbSN;
@property (weak, nonatomic) IBOutlet UILabel *lbtype_name;
@property (weak, nonatomic) IBOutlet UILabel *lbuse_startdate;
@property (weak, nonatomic) IBOutlet UILabel *lbuse_enddate;
@property (weak, nonatomic) IBOutlet UILabel *lbuse_limit;
@property (weak, nonatomic) IBOutlet UILabel *lborder_id;


@end
