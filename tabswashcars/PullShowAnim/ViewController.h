//
//  ViewController.h
//  PullShowAnim
//
//  Created by wang hanqing on 13-10-29.
//  Copyright (c) 2013年 wang hanqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIScrollViewDelegate>{
    
   
    BOOL hidden;
    BOOL isAnimating;
    CGFloat _lastPosition;
    
}

@property (strong, nonatomic) IBOutlet UIView *view_1;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollV;
@end
