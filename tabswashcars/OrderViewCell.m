//
//  OrderViewCell.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-23.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "OrderViewCell.h"

@implementation OrderViewCell

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

@end
