//
//  opengiftViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-7-22.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "opengiftViewController.h"

@interface opengiftViewController ()

@end

@implementation opengiftViewController

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
    _imgPackageOpen.hidden = true;
    _imgPackage.hidden = false;
    
    _txtMoney.hidden = true;
    _txtUnit.hidden = true;
    
    if (_bonusInfo) {
        _txtMoney.text = _bonusInfo;
    };
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

- (IBAction)btnGetGiftClicked:(id)sender {
    if (_txtMoney.hidden) {
        _imgPackageOpen.hidden = false;
        _imgPackage.hidden = true;
        
        _txtMoney.hidden = false;
        _txtUnit.hidden = false;
        _btnClose.hidden = false;
        
        
    }else{
        _imgPackageOpen.hidden = true;
        _imgPackage.hidden = false;
        
        _txtMoney.hidden = true;
        _txtUnit.hidden = true;
        _btnClose.hidden = true;
    
        [self btnCloseClicked:_btnClose];
    }
    
}

- (IBAction)btnCloseClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"用户已确认红包");
        //传递消息
        /*[[NSNotificationCenter defaultCenter]
         postNotificationName:@"RegisterCompletionNotification"
         object:nil
         userInfo:dataDict];*/
    }];
    
    
}


@end
