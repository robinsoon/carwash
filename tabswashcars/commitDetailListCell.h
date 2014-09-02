//
//  commitDetailListCell.h
//  washcarsbusiness
//
//  Created by Robinpad on 14-8-19.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface commitDetailListCell : UITableViewCell<RatingViewDelegate>{
    RatingView *starView;
}


@property (weak, nonatomic) IBOutlet UILabel *txtNumber;

@property (weak, nonatomic) IBOutlet UILabel *txtName;

@property (weak, nonatomic) IBOutlet UILabel *txtShopName;

@property (weak, nonatomic) IBOutlet RatingView *starView;

@property (weak, nonatomic) IBOutlet UILabel *txtAddDate;

@property (weak, nonatomic) IBOutlet UITextView *txtContent;


@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (weak, nonatomic) IBOutlet UIButton *btnModify;

@property (weak, nonatomic) IBOutlet UILabel *txtReply;

@property (weak, nonatomic) IBOutlet UILabel *txtReplyDate;

@property (weak, nonatomic) IBOutlet UITextView *txtReplyContent;

@property (weak, nonatomic) IBOutlet UIView *subCommitCell;

@property (weak, nonatomic) IBOutlet UIView *subReplyCell;

@property (strong, nonatomic) NSString *comment_id;
@property (strong, nonatomic) NSString *Rank;
@property (strong, nonatomic) NSString *content;           //评论内容
@property (strong, nonatomic) NSString *repcontent;        //回复内容
@property (strong, nonatomic) NSString *isReply;           //是否有回复
@property (nonatomic) int iserial;

- (void)initCell;

- (void)setCellReplyStyle:(BOOL)isReply;

@end
