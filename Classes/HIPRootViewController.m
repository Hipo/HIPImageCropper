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
@property (nonatomic, strong) NSArray *photoButtons;

- (void)didTapPhotoButton:(id)sender;
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
    
    _cropperView = [[HIPImageCropperView alloc]
                    initWithFrame:self.view.bounds
                    cropAreaSize:CGSizeMake(300.0, 300.0)
                    position:HIPImageCropperViewPositionCenter];
    
    [self.view addSubview:_cropperView];
    
    [_cropperView setOriginalImage:[UIImage imageNamed:@"portrait.jpg"]];
    
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
    
    NSMutableArray *photoButtons = [NSMutableArray array];
    CGFloat buttonSize = screenSize.size.width / 3.0;
    
    for (NSUInteger i = 0; i < 3; i++) {
        UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [photoButton addTarget:self
                        action:@selector(didTapPhotoButton:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [photoButton setFrame:CGRectMake(i * buttonSize, 0.0, buttonSize, 50.0)];
        
        NSString *buttonTitle = nil;
        
        switch (i) {
            case 0:
                buttonTitle = NSLocalizedString(@"Portrait", nil);
                break;
            case 1:
                buttonTitle = NSLocalizedString(@"Landscape", nil);
                break;
            case 2:
                buttonTitle = NSLocalizedString(@"Wide", nil);
                break;
            default:
                break;
        }

        [photoButton setTitle:buttonTitle forState:UIControlStateNormal];

        [self.view addSubview:photoButton];
        
        [photoButtons addObject:photoButton];
    }
    
    _photoButtons = [[NSArray alloc] initWithArray:photoButtons];
}

#pragma mark - Button actions

- (void)didTapPhotoButton:(id)sender {
    NSUInteger buttonIndex = [_photoButtons indexOfObject:sender];
    NSString *resourceName = nil;
    
    switch (buttonIndex) {
        case 0:
            resourceName = @"portrait.jpg";
            break;
        case 1:
            resourceName = @"landscape.jpg";
            break;
        case 2:
            resourceName = @"landscape-wide.jpg";
            break;
        default:
            break;
    }
    
    if (resourceName == nil) {
        return;
    }
    
    [self.cropperView setOriginalImage:[UIImage imageNamed:resourceName]];
}

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
