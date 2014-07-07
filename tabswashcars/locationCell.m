//
//  locationCell.m
//  tabswashcars
//
//  Created by Robinpad on 14-7-1.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "locationCell.h"

@implementation locationCell

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
