//
//  HIPImageCropperView.h
//  HIPImageCropper
//
//  Created by Taylan Pince on 2013-05-27.
//  Copyright (c) 2013 Hipo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, HIPImageCropperViewPosition) {
    HIPImageCropperViewPositionCenter,
    HIPImageCropperViewPositionTop,
    HIPImageCropperViewPositionBottom,
};

@protocol HIPImageCropperViewDelegate;

@interface HIPImageCropperView : UIView <UIScrollViewDelegate>

@property (nonatomic, readwrite, strong) UIImage *originalImage;
@property (nonatomic, assign) CGFloat scrollViewTopOffset;
@property (nonatomic, assign) BOOL borderVisible;
@property (nonatomic, weak) id <HIPImageCropperViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
       cropAreaSize:(CGSize)cropSize
           position:(HIPImageCropperViewPosition)position;

- (UIImage *)processedImage;
- (CGRect)cropFrame;
- (CGFloat)zoomScale;

- (void)startLoadingAnimated:(BOOL)animated;

- (void)setOriginalImage:(UIImage *)originalImage
           withCropFrame:(CGRect)cropFrame;

@end


@protocol HIPImageCropperViewDelegate <NSObject>
@required
- (void)imageCropperViewDidFinishLoadingImage:(HIPImageCropperView *)cropperView;
@end
