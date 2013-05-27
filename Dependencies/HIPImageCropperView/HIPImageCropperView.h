//
//  HIPImageCropperView.h
//  HIPImageCropper
//
//  Created by Taylan Pince on 2013-05-27.
//  Copyright (c) 2013 Hipo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HIPImageCropperView : UIView <UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame
       cropAreaSize:(CGSize)cropSize;

- (void)setImage:(UIImage *)image;

- (UIImage *)processedImage;

@end
