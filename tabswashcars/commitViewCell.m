//
//  commitViewCell.m
//  tabswashcars
//
//  Created by Robinpad on 14-7-17.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "commitViewCell.h"

@implementation commitViewCell
@synthesize starView =_starView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    [_starView setImagesDeselected:@"Star0.png" partlySelected:@"Star1.png" fullSelected:@"Star2.png" andDelegate:self];
	[_starView displayRating:5];

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

-(void)ratingChanged:(float)newRating {
	_ratingLabel.text = [NSString stringWithFormat:@"%1.1f", newRating];
}

@end
