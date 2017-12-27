//
//  EAImage360Library.h
//  ECAuctionApp
//
//  Created by Anson Ng on 9/18/16.
//  Copyright © 2016 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM (NSUInteger, EAImage360LibraryErrorCode) {
    EAImage360LibraryErrorCodeNoGrandPremission = 0,
    EAImage360LibraryErrorCodeNoGenFileURLError,
    EAImage360LibraryErrorCodeNoGenImagesError,
    EAImage360LibraryErrorCodeUnknownError,
};

@class EAImage360Library;

@protocol EAImage360LibraryDelegate <NSObject>

@optional

- (void)image360Library:(EAImage360Library *)library error:(NSError *)error;
- (void)willGenerateImagesByImage360Library:(EAImage360Library *)eaImage360Library;
- (void)didGenerateImagesByImage360Library:(EAImage360Library *)eaImage360Library images:(NSArray <UIImage *> *)images;

@end

@interface EAImage360Library : NSObject

@property (weak, nonatomic) id <EAImage360LibraryDelegate>delegate;
@property (assign, nonatomic) CGSize preferSize;//default: CGSizeMake(500.0f, 500.0f);
@property (assign, nonatomic) NSInteger genImageCount; //default:60

+ (UIImage*)appendImages:(NSArray <UIImage *> *)images;
+ (NSArray *)splitImage:(UIImage *)image
        smallImageWidth:(CGFloat)smallImageWidth
       smallImageHeight:(CGFloat)smallImageHeight
                  count:(NSUInteger)count;
+ (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)width;
+ (UIImage *)cropCenterSquareImage:(UIImage *)image;
+ (void)genImagesWithAVAsset:(AVAsset *)avasset
                  preferSize:(CGSize)preferSize
               maxImageCount:(NSInteger)maxImageCount
        processingErrorBlock:(void (^)(NSError *error))errorBlock
                    complete:(void (^)(NSArray <UIImage *> *images))complete;
+ (void)genImagesWithAVAsset:(AVAsset *)avasset
                  preferSize:(CGSize)preferSize
                         fps:(CGFloat)fps
        processingErrorBlock:(void (^)(NSError *error))errorBlock
                    complete:(void (^)(NSArray <UIImage *> *images))complete;
- (void)initCamera;
- (CALayer *)previewLayer;
- (void)startCamera;
- (void)stopCamera;
- (void)startCaptureVideo;
- (void)stopCaptureVideo;

@end
