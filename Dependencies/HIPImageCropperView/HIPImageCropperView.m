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
@property (nonatomic, strong) UIActivityIndicatorView *loadIndicator;
@property (nonatomic, assign) CGFloat cropSizeRatio;
@property (nonatomic, assign) CGSize targetSize;
@property (nonatomic, assign) HIPImageCropperViewPosition maskPosition;

- (void)updateOverlay;

- (CGRect)localCropFrame;

- (void)didTriggerDoubleTapGesture:(UITapGestureRecognizer *)tapRecognizer;

@end


@implementation HIPImageCropperView

- (id)initWithFrame:(CGRect)frame
       cropAreaSize:(CGSize)cropSize
           position:(HIPImageCropperViewPosition)position {
    
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    [self setBackgroundColor:[UIColor blackColor]];
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleHeight)];
    
    CGFloat defaultInset = 1.0;
    
    CGSize maxSize = CGSizeMake(self.bounds.size.width - (defaultInset * 2),
                                self.bounds.size.height - (defaultInset * 2));
    
    _borderVisible = YES;
    _maskPosition = position;
    _targetSize = cropSize;
    _cropSizeRatio = 1.0;
    
    if (cropSize.width >= cropSize.height) {
        if (cropSize.width > maxSize.width) {
            _cropSizeRatio = cropSize.width / maxSize.width;
        }
    } else {
        if (cropSize.height > maxSize.height) {
            _cropSizeRatio = cropSize.height / maxSize.height;
        }
    }
    
    cropSize = CGSizeMake(cropSize.width / _cropSizeRatio,
                          cropSize.height / _cropSizeRatio);
    
    CGFloat scrollViewVerticalPosition = 0.0;
    
    switch (_maskPosition) {
        case HIPImageCropperViewPositionBottom:
            scrollViewVerticalPosition = frame.size.height - cropSize.height;
            break;
        case HIPImageCropperViewPositionCenter:
            scrollViewVerticalPosition = (frame.size.height - cropSize.height) / 2;
            break;
        case HIPImageCropperViewPositionTop:
            scrollViewVerticalPosition = 0.0;
            break;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:
                       CGRectMake((self.bounds.size.width - cropSize.width) / 2,
                                  scrollViewVerticalPosition, cropSize.width, cropSize.height)];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setBounces:YES];
    [self.scrollView setBouncesZoom:YES];
    [self.scrollView setAlwaysBounceVertical:YES];
    [self.scrollView setAlwaysBounceHorizontal:YES];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView.layer setMasksToBounds:NO];
    [self.scrollView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(didTriggerDoubleTapGesture:)];
    
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [doubleTapRecognizer setNumberOfTouchesRequired:1];
    
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    switch (_maskPosition) {
        case HIPImageCropperViewPositionBottom:
            [self.scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                                  UIViewAutoresizingFlexibleRightMargin |
                                                  UIViewAutoresizingFlexibleTopMargin)];
            break;
        case HIPImageCropperViewPositionCenter:
            [self.scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                                  UIViewAutoresizingFlexibleRightMargin |
                                                  UIViewAutoresizingFlexibleTopMargin |
                                                  UIViewAutoresizingFlexibleBottomMargin)];
            break;
        case HIPImageCropperViewPositionTop:
            [self.scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                                  UIViewAutoresizingFlexibleRightMargin |
                                                  UIViewAutoresizingFlexibleBottomMargin)];
            break;
    }
    
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleBottomMargin)];
    
    [self.scrollView addSubview:self.imageView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.bounds];
    
    [self.overlayView setUserInteractionEnabled:NO];
    [self.overlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [self.overlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight)];
    
    [self addSubview:self.overlayView];
    
    [self updateOverlay];
    
    self.loadIndicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.loadIndicator setHidesWhenStopped:YES];
    [self.loadIndicator setCenter:self.scrollView.center];
    [self.loadIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleBottomMargin |
                                             UIViewAutoresizingFlexibleTopMargin)];
    
    [self addSubview:self.loadIndicator];
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self updateOverlay];
}

- (void)startLoadingAnimated:(BOOL)animated {
    [self.loadIndicator startAnimating];
    
    [UIView animateWithDuration:(animated) ? 0.2 : 0.0
                     animations:^{
                         [self.imageView setAlpha:0.0];
                         [self.loadIndicator setAlpha:1.0];
                     }];
}

- (void)setOriginalImage:(UIImage *)originalImage {
    [self setOriginalImage:originalImage withCropFrame:CGRectZero];
}

- (void)setOriginalImage:(UIImage *)originalImage
           withCropFrame:(CGRect)cropFrame {
    
    [self.loadIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGImageRef imageRef = CGImageCreateCopy([originalImage CGImage]);
        UIImageOrientation imageOrientation = [originalImage imageOrientation];
        
        if (!imageRef) {
            return;
        }
        
        size_t bytesPerRow = 0;
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
        
        switch (imageOrientation) {
            case UIImageOrientationRightMirrored:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationLeft:
                width = CGImageGetHeight(imageRef);
                height = CGImageGetWidth(imageRef);
                break;
            default:
                break;
        }
        
        CGSize imageSize = CGSizeMake(width, height);
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     bitmapInfo);
        
        CGColorSpaceRelease(colorSpace);
        
        if (!context) {
            CGImageRelease(imageRef);
            
            return;
        }
        
        switch (imageOrientation) {
            case UIImageOrientationRightMirrored:
            case UIImageOrientationRight:
                CGContextTranslateCTM(context, imageSize.width / 2, imageSize.height / 2);
                CGContextRotateCTM(context, -M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height / 2, -imageSize.width / 2);
                break;
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationLeft:
                CGContextTranslateCTM(context, imageSize.width / 2, imageSize.height / 2);
                CGContextRotateCTM(context, M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height / 2, -imageSize.width / 2);
                break;
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                CGContextTranslateCTM(context, imageSize.width / 2, imageSize.height / 2);
                CGContextRotateCTM(context, M_PI);
                CGContextTranslateCTM(context, -imageSize.width / 2, -imageSize.height / 2);
                break;
            default:
                break;
        }
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        CGContextDrawImage(context, CGRectMake(0.0, 0.0, CGImageGetWidth(imageRef),
                                               CGImageGetHeight(imageRef)), imageRef);
        
        CGImageRef contextImage = CGBitmapContextCreateImage(context);
        
        CGContextRelease(context);
        
        if (contextImage != NULL) {
            _originalImage = [UIImage imageWithCGImage:contextImage
                                                 scale:[originalImage scale]
                                           orientation:UIImageOrientationUp];
            
            CGImageRelease(contextImage);
        }
        
        CGImageRelease(imageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGSize convertedImageSize = CGSizeMake(_originalImage.size.width / _cropSizeRatio,
                                                   _originalImage.size.height / _cropSizeRatio);
            
            [self.imageView setAlpha:0.0];
            [self.imageView setImage:_originalImage];
            
            CGSize sampleImageSize = CGSizeMake(fmaxf(convertedImageSize.width, self.scrollView.frame.size.width),
                                                fmaxf(convertedImageSize.height, self.scrollView.frame.size.height));
            
            [self.scrollView setMinimumZoomScale:1.0];
            [self.scrollView setMaximumZoomScale:1.0];
            [self.scrollView setZoomScale:1.0 animated:NO];
            [self.imageView setFrame:CGRectMake(0.0, 0.0, convertedImageSize.width,
                                                convertedImageSize.height)];
            
            CGFloat zoomScale = 1.0;
            
            if (convertedImageSize.width < convertedImageSize.height) {
                zoomScale = (self.scrollView.frame.size.width / convertedImageSize.width);
            } else {
                zoomScale = (self.scrollView.frame.size.height / convertedImageSize.height);
            }
            
            [self.scrollView setContentSize:sampleImageSize];
            
            if (zoomScale < 1.0) {
                [self.scrollView setMinimumZoomScale:zoomScale];
                [self.scrollView setMaximumZoomScale:1.0];
                [self.scrollView setZoomScale:zoomScale animated:NO];
            } else {
                [self.scrollView setMinimumZoomScale:zoomScale];
                [self.scrollView setMaximumZoomScale:zoomScale];
                [self.scrollView setZoomScale:zoomScale animated:NO];
            }
            
            [self.scrollView setContentInset:UIEdgeInsetsZero];
            [self.scrollView setContentOffset:
             CGPointMake((self.imageView.frame.size.width - self.scrollView.frame.size.width) / 2,
                         (self.imageView.frame.size.height - self.scrollView.frame.size.height) / 2)];
            
            if (cropFrame.size.width > 0.0 && cropFrame.size.height > 0.0) {
                CGFloat scale = [[UIScreen mainScreen] scale];
                CGFloat newZoomScale = (_targetSize.width * scale) / cropFrame.size.width;
                
                [self.scrollView setZoomScale:newZoomScale animated:NO];
                
                CGFloat heightAdjustment = (_targetSize.height / _cropSizeRatio) - self.scrollView.contentSize.height;
                CGFloat offsetY = cropFrame.origin.y + (heightAdjustment * _cropSizeRatio * scale);
                
                [self.scrollView setContentOffset:CGPointMake(cropFrame.origin.x / scale / _cropSizeRatio,
                                                              (offsetY / scale / _cropSizeRatio) - heightAdjustment)];
            }
            
            [self.scrollView setNeedsLayout];
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [self.loadIndicator setAlpha:0.0];
                                 [self.imageView setAlpha:1.0];
                             } completion:^(BOOL finished) {
                                 [self.loadIndicator stopAnimating];
                                 
                                 [_delegate imageCropperViewDidFinishLoadingImage:self];
                             }];
        });
    });
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)setBorderVisible:(BOOL)borderVisible {
    _borderVisible = borderVisible;
    
    [self updateOverlay];
}

- (void)setScrollViewTopOffset:(CGFloat)scrollViewTopOffset {
    CGRect scrollViewFrame = _scrollView.frame;
    
    scrollViewFrame.origin.y += scrollViewTopOffset;
    
    [_scrollView setFrame:scrollViewFrame];
    
    [self.loadIndicator setCenter:self.scrollView.center];
    
    [self updateOverlay];
}

- (void)updateOverlay {
    for (UIView *subview in [self.overlayView subviews]) {
        [subview removeFromSuperview];
    }
    
    if (_borderVisible) {
        UIView *borderView = [[UIView alloc] initWithFrame:
                              CGRectInset(self.scrollView.frame, -1.0, -1.0)];
        
        [borderView.layer setBorderColor:[[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor]];
        [borderView.layer setBorderWidth:1.0];
        [borderView setBackgroundColor:[UIColor clearColor]];
        [borderView setAutoresizingMask:self.scrollView.autoresizingMask];
        
        [self.overlayView addSubview:borderView];
    }
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    CGRect biggerRect = self.overlayView.bounds;
    CGRect smallerRect = self.scrollView.frame;
    
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
}

- (UIImage *)processedImage {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGImageRef imageRef = CGImageCreateCopy([_originalImage CGImage]);
    
    if (!imageRef) {
        return nil;
    }
    
    size_t bytesPerRow = 0;
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 _targetSize.width * scale,
                                                 _targetSize.height * scale,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        CGImageRelease(imageRef);
        
        return nil;
    }
    
    CGRect targetFrame = [self localCropFrame];
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, targetFrame, imageRef);
    
    CGImageRef contextImage = CGBitmapContextCreateImage(context);
    UIImage *finalImage = nil;
    
    CGContextRelease(context);
    
    if (contextImage != NULL) {
        finalImage = [UIImage imageWithCGImage:contextImage
                                         scale:scale
                                   orientation:UIImageOrientationUp];
        
        CGImageRelease(contextImage);
    }
    
    CGImageRelease(imageRef);
    
    return finalImage;
}

- (CGRect)localCropFrame {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize originalImageSize = _originalImage.size;
    CGFloat actualHeight = originalImageSize.height * self.scrollView.zoomScale * scale;
    CGFloat actualWidth = originalImageSize.width * self.scrollView.zoomScale * scale;
    CGFloat heightAdjustment = (_targetSize.height / _cropSizeRatio) - self.scrollView.contentSize.height;
    CGFloat offsetX = -(self.scrollView.contentOffset.x * _cropSizeRatio * scale);
    CGFloat offsetY = (self.scrollView.contentOffset.y + heightAdjustment) * _cropSizeRatio * scale;
    CGRect targetFrame = CGRectMake(offsetX, offsetY, actualWidth, actualHeight);
    
    return targetFrame;
}

- (CGRect)cropFrame {
    CGRect localCropFrame = [self localCropFrame];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat heightAdjustment = (_targetSize.height / _cropSizeRatio) - self.scrollView.contentSize.height;
    
    return CGRectMake(-localCropFrame.origin.x, localCropFrame.origin.y - (heightAdjustment * _cropSizeRatio * scale),
                      _targetSize.width / self.scrollView.zoomScale * scale,
                      _targetSize.height / self.scrollView.zoomScale * scale);
}

- (CGFloat)zoomScale {
    return self.scrollView.zoomScale;
}

#pragma mark - Gesture recognizers

- (void)didTriggerDoubleTapGesture:(UITapGestureRecognizer *)tapRecognizer {
    CGFloat currentZoomScale = self.scrollView.zoomScale;
    CGFloat maxZoomScale = self.scrollView.maximumZoomScale;
    CGFloat minZoomScale = self.scrollView.minimumZoomScale;
    CGFloat zoomRange = maxZoomScale - minZoomScale;
    
    if (zoomRange <= 0.0) {
        return;
    }
    
    CGFloat zoomPosition = (currentZoomScale - minZoomScale) / zoomRange;
    
    if (zoomPosition <= 0.5) {
        [self.scrollView setZoomScale:maxZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:minZoomScale animated:YES];
    }
}

@end
