//
//  OrderSubmitViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "OrderSubmitViewController.h"

@interface OrderSubmitViewController ()

@end

@implementation OrderSubmitViewController

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
- (void)submitOrderForm:(UITableViewCell<FXFormFieldCell> *)cell
{
    //we can lookup the form from the cell if we want, like this:
    OrderForm *form = cell.field.form;
    
    if(form.itemamount>0)
    {
    
    
    }
}
@end
