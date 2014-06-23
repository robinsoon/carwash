//
//  ShopCartViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "ShopCartViewController.h"

@interface ShopCartViewController ()

@end

@implementation ShopCartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.lbBuyCount resignFirstResponder];
    [self.lbUsedMoney resignFirstResponder];
    
}

//修改数量
- (IBAction)buyCountDidEnd:(id)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)lbusedMoneyDidEnd:(id)sender {
    
    [sender resignFirstResponder];
}

@end
