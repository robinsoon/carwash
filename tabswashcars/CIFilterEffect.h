//
//  CIFilterEffect.h
//  tabswashcars
//
//  Created by Robinpad on 14-8-26.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#ifndef tabswashcars_CIFilterEffect_h
#define tabswashcars_CIFilterEffect_h



#endif

//
//  CIFilterEffect.h
//  CIFilter
//
//  Created by YouXianMing on 14-5-9.
//  Copyright (c) 2014年 Y.X. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 CILinearToSRGBToneCurve
 CIPhotoEffectChrome
 CIPhotoEffectFade
 CIPhotoEffectInstant
 CIPhotoEffectMono
 CIPhotoEffectNoir
 CIPhotoEffectProcess
 CIPhotoEffectTonal
 CIPhotoEffectTransfer
 CISRGBToneCurveToLinear
 CIVignetteEffect
 
 */

@interface CIFilterEffect : NSObject

@property (nonatomic, strong, readonly) UIImage *filterImage;
- (instancetype)initWithImage:(UIImage *)image filterName:(NSString *)name;

@property (nonatomic, strong, readonly) UIImage *QRCodeImage;
- (instancetype)initWithQRCodeString:(NSString *)string width:(CGFloat)width;

@end