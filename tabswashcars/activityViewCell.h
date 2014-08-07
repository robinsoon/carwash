//
//  activityViewCell.h
//  tabswashcars
//
//  Created by Robinpad on 14-7-29.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface activityViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *lbNumber;

@property (weak, nonatomic) IBOutlet UILabel *lbName;

@property (weak, nonatomic) IBOutlet UIImageView *imgPoster;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UILabel *lbDateHead;

@property (strong, nonatomic) NSString *itemid;           //传入参数id
@property (strong, nonatomic) NSString *action;           //传入参数act

@end
