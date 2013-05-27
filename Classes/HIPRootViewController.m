//
//  HIPRootViewController.m
//  HIPImageCropper
//
//  Created by Taylan Pince on 2013-05-27.
//  Copyright (c) 2013 Hipo. All rights reserved.
//

#import "HIPImageCropperView.h"
#import "HIPRootViewController.h"


@interface HIPRootViewController ()

@property (nonatomic, strong) HIPImageCropperView *cropperView;
@property (nonatomic, strong) UIImageView *imageView;

- (void)didTapCaptureButton:(id)sender;

- (void)gestureRecognizerDidTap:(UIGestureRecognizer *)tapRecognizer;

@end


@implementation HIPRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (!self) {
        return nil;
    }

    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    self.cropperView = [[HIPImageCropperView alloc]
                        initWithFrame:self.view.bounds
                        cropAreaSize:CGSizeMake(screenSize.size.width - 40.0,
                                                screenSize.size.width - 40.0)];
    
    [self.cropperView setImage:[UIImage imageNamed:@"portrait.jpg"]];
    
    [self.view addSubview:self.cropperView];
    
    UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [captureButton setTitle:NSLocalizedString(@"Capture", nil) forState:UIControlStateNormal];
    [captureButton sizeToFit];
    [captureButton setFrame:CGRectMake(self.view.frame.size.width - captureButton.frame.size.width - 10.0,
                                       self.view.frame.size.height - captureButton.frame.size.height - 10.0,
                                       captureButton.frame.size.width, captureButton.frame.size.height)];
    
    [captureButton setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleLeftMargin)];
    
    [captureButton addTarget:self
                      action:@selector(didTapCaptureButton:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:captureButton];
}

#pragma mark - Button actions

- (void)didTapCaptureButton:(id)sender {
    if (self.imageView != nil) {
        [self.imageView removeFromSuperview];

        self.imageView = nil;
    }
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    [self.imageView setImage:[self.cropperView processedImage]];
    
    [self.view addSubview:self.imageView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(gestureRecognizerDidTap:)];
    
    [self.imageView addGestureRecognizer:tapRecognizer];
}

- (void)gestureRecognizerDidTap:(UIGestureRecognizer *)tapRecognizer {
    [self.imageView removeFromSuperview];
    
    self.imageView = nil;
}

@end
