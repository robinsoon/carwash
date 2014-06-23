//
//  RegisterViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-6-10.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Bootstrap.h"
@interface RegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtRepPass;

@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (strong, nonatomic) NSString *UserID;

@end
