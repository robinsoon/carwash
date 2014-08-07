//
//  opengiftViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-7-22.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface opengiftViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *imgPackage;

@property (weak, nonatomic) IBOutlet UIImageView *imgPackageOpen;

@property (weak, nonatomic) IBOutlet UILabel *txtMoney;

@property (weak, nonatomic) IBOutlet UILabel *txtUnit;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (nonatomic, retain) NSString *bonusInfo;

@end
