//
//  aboutViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-30.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "aboutViewController.h"

@interface aboutViewController ()

@end

@implementation aboutViewController

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
    
    self.scrollview1.contentSize = CGSizeMake(320,480);
    [self.scrollview1 addSubview:self.subview1];
    
    //标记出版本号
    _txtAppName.text = [NSString stringWithFormat:@"去洗车 v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
    
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

@end
