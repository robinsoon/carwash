//
//  signinTableViewCell.h
//  tabswashcars
//
//  Created by Robinpad on 14-8-6.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface signinTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *txtNumber;

@property (weak, nonatomic) IBOutlet UILabel *txtDate;

@property (weak, nonatomic) IBOutlet UITextView *txtContent;

@end
