//
//  commitViewCell.h
//  tabswashcars
//
//  Created by Robinpad on 14-7-17.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface commitViewCell : UITableViewCell <RatingViewDelegate>{
    RatingView *starView;
}

@property (nonatomic, retain) IBOutlet RatingView *starView;
@property (nonatomic, retain) IBOutlet UILabel *ratingLabel;


@property (weak, nonatomic) IBOutlet UILabel *lbUsername;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;

@property (weak, nonatomic) IBOutlet UITextView *lbContent;

-(void)ratingChanged:(float)newRating;

@end
