//
//  commitDetailListCell.m
//  washcarsbusiness
//
//  Created by Robinpad on 14-8-19.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "commitDetailListCell.h"
#import "UIButton+Bootstrap.h"

@implementation commitDetailListCell
@synthesize starView =_starView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initCell];
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
    _subReplyCell.layer.cornerRadius = 6;
    _subReplyCell.layer.masksToBounds = YES;
    _subReplyCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _subReplyCell.layer.borderWidth = 1;

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
    
    //星星评级
    [_starView setImagesDeselected:@"Star0.png" partlySelected:@"Star1.png" fullSelected:@"Star2.png" andDelegate:self];
	//[_starView displayRating:4.5];
    [_starView displayRating:[_Rank floatValue]];

    [self.btnModify primaryStyle];
    
    //[self.btnModify addAwesomeIcon:FAIconCheck beforeTitle:YES];
    
    [self.btnSubmit primaryStyle];
    
    //[self.btnSubmit addAwesomeIcon:FAIconCheck beforeTitle:YES];

}

//设定单元格带有商家回复的样式
- (void)setCellReplyStyle:(BOOL)asReply
{
    
    if (asReply) {
        _isReply = @"1";
        _subReplyCell.hidden = false;
        //_btnModify.hidden = false;
        //_btnSubmit.hidden = true;

    }else{
        _isReply = @"0";
        /*CGRect cellFrame = [self frame];
        cellFrame.size.height = _subCommitCell.frame.size.height + 2;
        [self setFrame:cellFrame];*/
        _subReplyCell.hidden = true;
        //_btnModify.hidden = true;
        //_btnSubmit.hidden = false;
        
     }
    
}

#pragma mark- ActionEvent 触发控制逻辑

-(void)ratingChanged:(float)newRating {
	//_ratingLabel.text = [NSString stringWithFormat:@"%1.1f", newRating];
}

@end
