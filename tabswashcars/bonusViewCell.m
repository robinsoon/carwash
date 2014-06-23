//
//  bonusViewCell.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-17.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "bonusViewCell.h"

@implementation bonusViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectBonusChanged:(id)sender {
    
    //accessoryType = UITableViewCellAccessoryNone;
    //_selectBonus.On = false;
    
    // 选中操作

    //accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    
}



@end
