//
//  MagnifierView.m
//  HaoBao
//  QQ:297184181
//  Created by haobao on 13-11-26.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "MagnifierView.h"

@implementation MagnifierView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:CGRectMake(0, 0, 320, 35)]) {
        
		// make the circle-shape outline with a nice border.
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 0.5;
		self.layer.masksToBounds = YES;
	}
	return self;
}

- (void)setTouchPoint:(CGPoint)pt {
	_touchPoint = pt;
	self.center = CGPointMake(pt.x, pt.y);
}

- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, 1.1, 1.1);
	CGContextTranslateCTM(context,-1*(_touchPoint.x),-1*(_touchPoint.y));
	[self.viewToMagnify.layer renderInContext:context];
}

- (void)dealloc
{
    self.viewToMagnify=nil;
}





@end
