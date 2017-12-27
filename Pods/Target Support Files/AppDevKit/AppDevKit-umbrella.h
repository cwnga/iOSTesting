#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppDevKit.h"
#import "UIView+ADKAnimationMacro.h"
#import "AppDevAnimateKit.h"
#import "ADKCamera.h"
#import "AppDevCameraKit.h"
#import "ADKAppUtil.h"
#import "ADKCalculatorHelper.h"
#import "ADKNibCacheManager.h"
#import "ADKStringHelper.h"
#import "ADKViewExclusiveTouch.h"
#import "UIColor+ADKHexPresentation.h"
#import "UIView+ADKGetUIViewController.h"
#import "AppDevCommonKit.h"
#import "UIImage+ADKColorReplacement.h"
#import "UIImage+ADKDrawingTemplate.h"
#import "UIImage+ADKImageFilter.h"
#import "AppDevImageKit.h"
#import "ADKCellDynamicSizeCalculator.h"
#import "ADKCollectionViewDynamicSizeCell.h"
#import "ADKNibSizeCalculator.h"
#import "ADKTableViewDynamicSizeCell.h"
#import "UICollectionView+ADKOperation.h"
#import "AppDevListViewKit.h"
#import "ADKDashedLineView.h"
#import "ADKGradientView.h"
#import "ADKModalMaskView.h"
#import "UIScrollView+ADKInfiniteScrollingView.h"
#import "UIScrollView+ADKPullToRefreshView.h"
#import "UIView+ADKAutoLayoutSupport.h"
#import "ADKAutoLayoutValueObject.h"
#import "AppDevUIKit.h"

FOUNDATION_EXPORT double AppDevKitVersionNumber;
FOUNDATION_EXPORT const unsigned char AppDevKitVersionString[];

