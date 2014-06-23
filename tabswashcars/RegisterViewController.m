//
//  RegisterViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-10.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

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
    
    [self.btnSubmit successStyle];
    
    [self.btnSubmit addAwesomeIcon:FAIconKey beforeTitle:YES];
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
- (IBAction)txtUsernameEdited:(id)sender {
    [sender resignFirstResponder];
    [_txtPassword becomeFirstResponder];
}
- (IBAction)txtPasswordEdited:(id)sender {
    [sender resignFirstResponder];
    [_txtPhone becomeFirstResponder];
}
- (IBAction)txtPhoneEdited:(id)sender {
    [sender resignFirstResponder];
    [self btnSubmitClicked:_btnSubmit];
}

//用户注册信息
- (IBAction)btnSubmitClicked:(id)sender {
    [self RegDone:_btnSubmit];
    
}

- (IBAction)RegDone:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Modal View done");
        //构造消息
        _UserID = @"2692";
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"isLogin",_UserID, @"ID",_txtUserName.text, @"name",_txtPassword.text, @"password", nil];

        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RegisterCompletionNotification"
         object:nil
         userInfo:dataDict];
    }];
}

@end
