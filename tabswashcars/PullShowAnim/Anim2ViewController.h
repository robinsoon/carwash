//
//  Anim2ViewController.h
//  PullShowAnim
//
//  Created by wang hanqing on 13-10-30.
//  Copyright (c) 2013年 wang hanqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Anim2ViewController : UIViewController<UIScrollViewDelegate>{
    
    BOOL isAnimating;
    
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


@end
