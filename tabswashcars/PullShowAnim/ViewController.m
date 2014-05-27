//
//  ViewController.m
//  PullShowAnim
//
//  Created by wang hanqing on 13-10-29.
//  Copyright (c) 2013年 wang hanqing. All rights reserved.
//

#import "ViewController.h"
#import "Anim2ViewController.h"
#define anim_time 0.5

@interface ViewController ()

@end

@implementation ViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"抽屉效果1"];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightOnClick:)];
    self.navigationItem.rightBarButtonItem = button;
    
    [_scrollV setDelegate:self];
    [_scrollV setContentSize:CGSizeMake(320, 500)];//设置较大的高度，scrollview可以滚动
    
    
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 跳转

-(void) rightOnClick:(id) sender{
    Anim2ViewController *anim = [[Anim2ViewController alloc] init];
    [self.navigationController pushViewController:anim animated:YES];
}

#pragma mark - 下拉、隐藏效果

-(void) showView{
    NSLog( @"---->showView");
    hidden = YES;
    isAnimating = YES;
    [self performSelector:@selector(endAnimation:) withObject:nil afterDelay:anim_time];
    [UIView animateWithDuration:anim_time animations:^(void){
        [_scrollV setFrame:CGRectMake(0, _scrollV.frame.origin.y+100, 320, _scrollV.frame.size.height)];
        [_view_1 setFrame:CGRectMake(0, _view_1.frame.origin.y+100, 320, _view_1.frame.size.height)];
    }];
   
}

-(void) hideView{
    NSLog( @"---->hideView");
    hidden = NO;
    isAnimating = YES;
    [self performSelector:@selector(endAnimation:) withObject:nil afterDelay:anim_time];
    [UIView animateWithDuration:anim_time animations:^(void){
        [_scrollV setFrame:CGRectMake(0, _scrollV.frame.origin.y-100, 320, _scrollV.frame.size.height)];
        [_view_1 setFrame:CGRectMake(0, _view_1.frame.origin.y-100, 320, _view_1.frame.size.height)];
    } completion:^(BOOL finished){
        //滚动的顶部
//        [_scrollV setContentOffset:CGPointMake(0, 0) animated:YES];
    }];
    
}

-(void)endAnimation:(id)sender {
    @synchronized(self){
        isAnimating = NO;
    }
}

#pragma mark - scroll

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"0=====Scroll-->%f",scrollView.contentOffset.y);
    
    CGFloat currentPostion = scrollView.contentOffset.y;
    
    if (currentPostion - _lastPosition > 25 ) {
        NSLog(@"ScrollUp now");
        _lastPosition = currentPostion;
        
        if (isAnimating) {
            return;
        }
        if (hidden) {
            [self hideView];
        }
        
    } else if (_lastPosition - currentPostion > 25) {
        NSLog(@"ScrollDown now");
        _lastPosition = currentPostion;
        
        if (isAnimating) {
            return;
        }
        if (scrollView.contentOffset.y < 0 && !hidden) {
            [self showView];
        }
        
    }
    
}

//
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"1=====scrollViewWillBeginDecelerating-->isDragging:%@,-->isDecelerating:%@",scrollView.isDragging?@"YES":@"NO",scrollView.isDecelerating?@"YES":@"NO");
//}
//
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    NSLog(@"2=====scrollViewWillBeginDragging-->isDragging:%@,-->isDecelerating:%@",scrollView.isDragging?@"YES":@"NO",scrollView.isDecelerating?@"YES":@"NO");
//}
//
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"3=====scrollViewDidEndDecelerating-->isDragging:%@,-->isDecelerating:%@ \n",scrollView.isDragging?@"YES":@"NO",scrollView.isDecelerating?@"YES":@"NO");
//}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"4=====scrollViewDidEndDragging-->isDragging:%@,-->isDecelerating:%@",scrollView.isDragging?@"YES":@"NO",scrollView.isDecelerating?@"YES":@"NO");
//}

@end
