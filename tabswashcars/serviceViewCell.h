//
//  serviceViewCell.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface serviceViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImg;
@property (weak, nonatomic) IBOutlet UILabel *cellOrder;
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellPrice;
@property (weak, nonatomic) IBOutlet UILabel *cellcmsPrice;
@property (weak, nonatomic) IBOutlet UILabel *cellLeve;
@property (weak, nonatomic) IBOutlet UITextView *cellMemo;
@property (weak, nonatomic) IBOutlet UILabel *cellDistance;

@end
