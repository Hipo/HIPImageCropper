//
//  HIPImageCropperView.m
//  HIPImageCropper
//
//  Created by Taylan Pince on 2013-05-27.
//  Copyright (c) 2013 Hipo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HIPImageCropperView.h"


@interface HIPImageCropperView ()

@property (nonatomic, readwrite, strong) UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) UIImageView *imageView;
@property (nonatomic, readwrite, strong) UIView *overlayView;

- (void)updateOverlay;

@end


@implementation HIPImageCropperView

- (id)initWithFrame:(CGRect)frame
       cropAreaSize:(CGSize)cropSize {

    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }
    
    [self setBackgroundColor:[UIColor blackColor]];
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleHeight)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:
                       CGRectInset(self.bounds, (frame.size.width - cropSize.width) / 2,
                                   (frame.size.height - cropSize.height) / 2)];

    [self.scrollView setDelegate:self];
    [self.scrollView setAlwaysBounceVertical:YES];
    [self.scrollView setAlwaysBounceHorizontal:YES];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView.layer setMasksToBounds:NO];
    [self.scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin)];
    
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.scrollView addSubview:self.imageView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.bounds];
    
    [self.overlayView setUserInteractionEnabled:NO];
    [self.overlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    [self.overlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight)];
    
    [self addSubview:self.overlayView];
    
    [self updateOverlay];
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self updateOverlay];
}

- (void)setImage:(UIImage *)image {
    [self.imageView setImage:image];
    [self.imageView sizeToFit];
    
    CGFloat zoomScale = 1.0;
    
    if (self.imageView.frame.size.width < self.imageView.frame.size.height) {
        zoomScale = (self.scrollView.frame.size.width / self.imageView.frame.size.width);
    } else {
        zoomScale = (self.scrollView.frame.size.height / self.imageView.frame.size.height);
    }
    
    [self.scrollView setContentSize:self.imageView.frame.size];
    [self.scrollView setMinimumZoomScale:zoomScale];
    [self.scrollView setMaximumZoomScale:1.0];
    [self.scrollView setZoomScale:zoomScale];
    [self.scrollView setContentOffset:CGPointMake((self.imageView.frame.size.width - self.scrollView.frame.size.width) / 2,
                                                  (self.imageView.frame.size.height - self.scrollView.frame.size.height) / 2)];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)updateOverlay {
    for (UIView *subview in [self.overlayView subviews]) {
        [subview removeFromSuperview];
    }
    
    UIView *borderView = [[UIView alloc] initWithFrame:self.scrollView.frame];
    
    [borderView.layer setBorderColor:[[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor]];
    [borderView.layer setBorderWidth:1.0];
    [borderView setBackgroundColor:[UIColor clearColor]];
    [borderView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin)];
    
    [self.overlayView addSubview:borderView];
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    CGSize maskSize = borderView.frame.size;
    CGRect biggerRect = self.overlayView.bounds;
    CGRect smallerRect = CGRectMake((biggerRect.size.width - maskSize.width) / 2.0,
                                    (biggerRect.size.height - maskSize.height) / 2.0,
                                    maskSize.width, maskSize.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    
    [maskWithHole setFrame:self.bounds];
    [maskWithHole setPath:[maskPath CGPath]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    
    [self.overlayView.layer setMask:maskWithHole];
    
    [borderView setFrame:CGRectInset(smallerRect, -1.0, -1.0)];
}

- (UIImage *)processedImage {
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, YES, scale);
    
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    
    [self.scrollView.layer renderInContext:graphicsContext];
    
    UIImage *finalImage = nil;
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();

    CGRect targetFrame = CGRectMake(self.scrollView.contentOffset.x * scale,
                                    self.scrollView.contentOffset.y * scale,
                                    self.scrollView.frame.size.width * scale,
                                    self.scrollView.frame.size.height * scale);

    CGImageRef contextImage = CGImageCreateWithImageInRect([sourceImage CGImage], targetFrame);
    
    if (contextImage != NULL) {
        finalImage = [UIImage imageWithCGImage:contextImage
                                         scale:scale
                                   orientation:UIImageOrientationUp];

        CGImageRelease(contextImage);
    }
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

@end
