//
//  serviceViewCell.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "serviceViewCell.h"

@implementation serviceViewCell

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

//为了使用户触摸事件不被 Memo滚动中断
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    [super hitTest:point withEvent:event];
    //修改事件链第一响应者为 Cell
    return self;
    
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    return YES;
    
}




@end
