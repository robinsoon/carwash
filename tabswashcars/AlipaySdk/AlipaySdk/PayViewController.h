//
//  PayViewController.h
//  MQPDemo
//
//  Created by ChaoGanYing on 13-7-3.
//  Copyright (c) 2013年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlixLibService.h"

@interface PayViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic,assign) SEL result;//这里声明为属性方便在于外部传入。
@property (retain, nonatomic) IBOutlet UITextField *name;
@property (retain, nonatomic) IBOutlet UITextView *info;
@property (retain, nonatomic) IBOutlet UITextField *price;
-(void)paymentResult:(NSString *)result;
- (IBAction)onPay:(id)sender;
@end
