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

@end
