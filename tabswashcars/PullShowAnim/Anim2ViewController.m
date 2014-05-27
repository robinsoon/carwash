//
//  Anim2ViewController.m
//  PullShowAnim
//
//  Created by wang hanqing on 13-10-30.
//  Copyright (c) 2013年 wang hanqing. All rights reserved.
//

#import "Anim2ViewController.h"

#define anim_time 0.5
#define height 100

@interface Anim2ViewController ()

@end

@implementation Anim2ViewController

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
    
    self.title = @"抽屉效果2";
    
    [_scrollView setContentSize:CGSizeMake(320, 500)];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(upSwipeHandle:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
//    recognizer 
    [self.view addGestureRecognizer:recognizer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 手势处理

-(void) upSwipeHandle:(UISwipeGestureRecognizer *) recognizer{
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
       
        [_scrollView setContentOffset:CGPointMake(0, height) animated:YES];
        isAnimating = YES;
        [self performSelector:@selector(endAnimation:) withObject:nil afterDelay:anim_time];
        [self performSelector:@selector(delayContentInsets) withObject:nil afterDelay:anim_time];
    }
}

-(void) delayContentInsets{
    [_scrollView setContentInset:UIEdgeInsetsMake(-height, 0, 0, 0)];
    [_scrollView setScrollEnabled:YES];
}

#pragma mark - scroll
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat currentPosition = scrollView.contentOffset.y;
    
//    CGFloat height = 100;//顶部区域高度
    CGFloat height_5 = height/2;//半高
    
    if (isAnimating) {
        return;
    }
        NSLog(@"scrollViewDidScroll====>%f",scrollView.contentOffset.y);
    
    //收起
    if (currentPosition > height_5 && currentPosition < height) {
//        if (!scrollView.isDragging) {
//            [self hideView];
//        }
    } else if (currentPosition >= height) {
        NSLog(@"收起高度");
        [scrollView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
    } else if (currentPosition <= height_5){//放下
        if (!scrollView.isDragging) {
            [self showView];
        }
    }
    
    
}


-(void) showView{
    NSLog( @"---->showView");
//    hidden = YES;
  
    isAnimating = YES;
    [self performSelector:@selector(endAnimation:) withObject:nil afterDelay:anim_time];
    [self performSelector:@selector(dalayScrollNot) withObject:nil afterDelay:anim_time];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [_scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

-(void) dalayScrollNot{
    [_scrollView setScrollEnabled:NO];
}

-(void) hideView{
    NSLog( @"---->hideView");
//    hidden = NO;
    isAnimating = YES;
    [self performSelector:@selector(endAnimation:) withObject:nil afterDelay:anim_time];
    
    [_scrollView setContentOffset:CGPointMake(0, height) animated:YES];
    [UIView animateWithDuration:anim_time animations:^(void){
        
        
    } completion:^(BOOL finished){
        [_scrollView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
    }];
    
//    [_scrollView setContentOffset:CGPointMake(0, height) animated:YES];
//    [_scrollView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
//    [self performSelector:@selector(contentSize11) withObject:nil afterDelay:anim_time];
    
//    [self performSelector:@selector(seting:) withObject:[NSNumber numberWithFloat:-] afterDelay:anim_time];
    
}


-(void)endAnimation:(id)sender {

    @synchronized(self){
        isAnimating = NO;
    }
}


@end
