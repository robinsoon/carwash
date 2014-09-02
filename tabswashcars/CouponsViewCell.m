//
//  CouponsViewCell.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-12.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "CouponsViewCell.h"
#import "UIButton+Bootstrap.h"

@implementation CouponsViewCell

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

- (IBAction)btncommitClicked:(id)sender {
    
    
}

//单元格初始化
- (void)initCell
{
    /*
     //评论的背景 -- 圆角矩形
     _subCommitCell.layer.cornerRadius = 6;
     _subCommitCell.layer.masksToBounds = YES;
     _subCommitCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
     _subCommitCell.layer.borderWidth = 1;
     */
    
    //回复的背景 -- 圆角矩形
//    _subReplyCell.layer.cornerRadius = 6;
//    _subReplyCell.layer.masksToBounds = YES;
//    _subReplyCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _subReplyCell.layer.borderWidth = 1;
//    
    /*
     _txtContent.layer.cornerRadius = 6;
     _txtContent.layer.masksToBounds = YES;
     _txtContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
     _txtContent.layer.borderWidth = 1;
     */
    /*
     _txtReplyContent.layer.cornerRadius = 6;
     _txtReplyContent.layer.masksToBounds = YES;
     _txtReplyContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
     _txtReplyContent.layer.borderWidth = 1;
     */
    
    [self.btnCommit primaryStyle];
    _btnCommit.hidden = true;
    _lbCommitstatus.hidden = true;
    //[self.btnCommit addAwesomeIcon:FAIconCheck beforeTitle:YES];
}

//设定单元格带有商家回复的样式
- (void)setCellCommitStyle:(BOOL)asCommit
{
    
    if (asCommit) {
        //可以评价
        _isCommit = @"1";

        _btnCommit.hidden = false;
        _lbCommitstatus.hidden = true;
        
    }else{
        //已评价
        _isCommit = @"0";
        /*CGRect cellFrame = [self frame];
         cellFrame.size.height = _subCommitCell.frame.size.height + 2;
         [self setFrame:cellFrame];*/
        _btnCommit.hidden = true;
        _lbCommitstatus.hidden = false;
        
    }
    
}


@end
