//
//  EAImage360Library.m
//  ECAuctionApp
//
//  Created by Anson Ng on 9/18/16.
//  Copyright © 2016 Yahoo. All rights reserved.
//

#import "EAImage360Library.h"
#import <AppDevKit/AppDevKit.h>
#import <Foundation/Foundation.h>

@interface EAImage360Library() <ADKCameraDelegate>

@property (strong, nonatomic) ADKCamera *camera;
@property (strong, nonatomic) NSURL *videoURL;

@end

@implementation EAImage360Library

- (instancetype)init
{
    self = [super init];
    if (self) {
        _preferSize = CGSizeMake(500.0f, 500.0f);
        _genImageCount = 60.0f;
    }
    return self;
}

- (void)initCamera
{

    if ([ADKCamera cameraPermission] && [ADKCamera microphonePermission]) {
        self.camera = [[ADKCamera alloc] initCamcoderWithDelegate:self quality:AVCaptureSessionPresetHigh position:ADKCameraPositionRear];
        self.camera.delegate = self;
        if ([self.delegate respondsToSelector:@selector(didInitCameraOfImage360Library:)]) {
            [self.delegate didInitCameraOfImage360Library:self];
        }
    } else {
        __weak typeof(self) weakSelf = self;
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    [weakSelf initCamera];
                } else {
                    [self postErrorWithCode:EAImage360LibraryErrorCodeNoGrandPremission userInfo:nil];
                }
            }];
        } else if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    [weakSelf initCamera];
                } else {
                    [self postErrorWithCode:EAImage360LibraryErrorCodeNoGrandPremission userInfo:nil];
                }
            }];
        } else {
            [self postErrorWithCode:EAImage360LibraryErrorCodeNoGrandPremission userInfo:nil];
        }
    }
}

- (CALayer *)previewLayer
{
    return [self.camera captureVideoPreviewLayer];
}

- (void)startCamera
{
    [self.camera startCamera];
}

- (void)stopCamera
{
    [self.camera stopCamera];
}

- (void)startCaptureVideo
{
    self.videoURL = [self genVideoURL];
    __weak typeof (self) weakSelf = self;
    [self.camera startCaptureVideo:^(NSURL *videoOutputURL, NSError *error) {
        if (error) {
            if ([weakSelf.delegate respondsToSelector:@selector(image360Library:error:)]) {
                [weakSelf.delegate image360Library:weakSelf error:error];
            }
            return;
        }

        AVAsset *asset = [AVAsset assetWithURL:videoOutputURL];
        if (asset) {
            if ([weakSelf.delegate respondsToSelector:@selector(willGenerateImagesByImage360Library:)]) {
                [weakSelf.delegate willGenerateImagesByImage360Library:weakSelf];
            }

            [EAImage360Library genImagesWithAVAsset:asset
                                         preferSize:weakSelf.preferSize
                                      maxImageCount:weakSelf.genImageCount
                               processingErrorBlock:^(NSError *error) {
                                   [weakSelf postErrorWithCode:EAImage360LibraryErrorCodeNoGenImagesError userInfo:error.userInfo];
                               } complete:^(NSArray <UIImage *> *images) {
                                   [weakSelf deleteFileWithURL:videoOutputURL];
                                   if ([weakSelf.delegate respondsToSelector:@selector(didGenerateImagesByImage360Library:images:)]) {
                                       [weakSelf.delegate didGenerateImagesByImage360Library:weakSelf images:images];
                                   }
                               }];
        }
    } outputURL:self.videoURL];
}

- (void)stopCaptureVideo
{
    [self.camera stopCaptureVideo];
}

#pragma mark - gen images

+ (void)genImagesWithAVAsset:(AVAsset *)avasset
                  preferSize:(CGSize)preferSize
               maxImageCount:(NSInteger)maxImageCount
        processingErrorBlock:(void (^)(NSError *error))errorBlock
                    complete:(void (^)(NSArray <UIImage *> *images))complete
{
    if (maxImageCount <= 0) {
        return;
    }
    CGFloat dur = CMTimeGetSeconds(avasset.duration);
    if (dur <= 0) {
        return;
    }
    CGFloat fps = (CGFloat)maxImageCount / dur;
    [EAImage360Library genImagesWithAVAsset:avasset
                                 preferSize:preferSize
                                        fps:fps
                       processingErrorBlock:errorBlock
                                   complete:complete];
}

+ (void)genImagesWithAVAsset:(AVAsset *)avasset
                  preferSize:(CGSize)preferSize
                         fps:(CGFloat)fps
        processingErrorBlock:(void (^)(NSError *error))errorBlock
                    complete:(void (^)(NSArray <UIImage *> *images))complete
{
    if (!complete) {
        return;
    }

    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avasset];
    imageGenerator.maximumSize = CGSizeZero;
    fps = (fps <= 0) ? 1 : fps;
    CGFloat segmentSec = 1 / fps;
    NSInteger count = round(CMTimeGetSeconds(avasset.duration) * fps);
    NSMutableArray *timesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        CMTime cmTime = CMTimeMakeWithSeconds(((i * segmentSec)), fps);
        NSValue *tmpValue = [NSValue valueWithCMTime:cmTime];
        if (tmpValue) {
            [timesArray addObject:tmpValue];
        }
    }
    __block NSInteger leaveCount = count;
    NSMutableArray <UIImage *> *images = [NSMutableArray array];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[timesArray copy]
                                         completionHandler:^(
                                                             CMTime requestedTime,
                                                             CGImageRef cgImageRef,
                                                             CMTime actualTime,
                                                             AVAssetImageGeneratorResult result,
                                                             NSError *error
                                                             ) {
                                             leaveCount--;
                                             CGImageRetain(cgImageRef);
                                             if (result == AVAssetImageGeneratorSucceeded) {
                                                 UIImage *image = [UIImage imageWithCGImage:cgImageRef];
                                                 if (image) {
                                                     [images addObject:image];
                                                 }
                                             }
                                             if (error && errorBlock) {
                                                 errorBlock(error);
                                             }
                                             CGImageRelease(cgImageRef);
                                             if (leaveCount == 0) {

                                                 CGSize aspectFillSize = CGSizeZero;
                                                 if ([images firstObject].size.width / [images firstObject].size.height >= preferSize.width / preferSize.height) {

                                                     aspectFillSize = CGSizeMake(images.firstObject.size.width * (preferSize.height / images.firstObject.size.height),
                                                                                 preferSize.height);

                                                 } else {
                                                     aspectFillSize = CGSizeMake(preferSize.width,
                                                                                 images.firstObject.size.height * (preferSize.width / images.firstObject.size.width));

                                                 }

                                                 NSMutableArray *newSizeImages = [NSMutableArray array];
                                                 for (UIImage *image in images) {
                                                     UIImage *newSizeImage = [[image ADKScaleToSize:aspectFillSize] ADKCropRect:CGRectMake((aspectFillSize.width - preferSize.width) / 2,
                                                                                                                                            (aspectFillSize.height - preferSize.height) / 2,
                                                                                                                                            preferSize.width,
                                                                                                                                            preferSize.height)];
                                                     if (newSizeImage) {
                                                         [newSizeImages addObject:newSizeImage];
                                                     }
                                                 }
                                                 complete([newSizeImages copy]);
                                             }
                                         }];
}


- (NSURL *)genVideoURL
{
    //Create temporary URL to record to
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"image360.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
            [self postErrorWithCode:EAImage360LibraryErrorCodeNoGenFileURLError userInfo:nil];
        }
    }
    return outputURL;
}

- (void)deleteFileWithURL:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileURL.absoluteString]) {
        NSError *error;
        if ([fileManager removeItemAtPath:fileURL.absoluteString error:&error] == NO) {
            [self postErrorWithCode:EAImage360LibraryErrorCodeNoGenFileURLError userInfo:nil];
        }
    }
}

#pragma mark - error

- (void)postErrorWithCode:(EAImage360LibraryErrorCode)code
                 userInfo:(NSDictionary *)userInfo

{
    if ([self.delegate respondsToSelector:@selector(image360Library:error:)]) {
        [self.delegate image360Library:self error:[NSError errorWithDomain:NSStringFromClass([self class])
                                                                      code:EAImage360LibraryErrorCodeNoGrandPremission
                                                                  userInfo:userInfo]];
    }
}

#pragma mark - <ADKCameraDelegate>

- (void)ADKCamera:(ADKCamera *)camera didFailWithError:(NSError *)error
{
    [self postErrorWithCode:EAImage360LibraryErrorCodeUnknownError userInfo:error.userInfo];
}

#pragma mark - <ADKCameraLiveVideoDataDelegate>
- (void)ADKCamera:(ADKCamera *)camera didUpdateSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [[CIImage alloc] initWithCVImageBuffer:pixelBuffer];
    sourceImage = [sourceImage imageByApplyingOrientation:UIImageOrientationDownMirrored];
}

#pragma mark - Image

+ (UIImage*)appendImages:(NSArray <UIImage *> *)images
{
    if (images.count == 0) {
        return nil;
    }

    int numberOfImagesPerLine = ceil(sqrt(images.count));
    UIImage *tmpImg = images[0];
    int bigImgWidth = tmpImg.size.width * numberOfImagesPerLine;
    int bigImgHeight = tmpImg.size.height * numberOfImagesPerLine;

    CGSize newImageSize = CGSizeMake(bigImgWidth, bigImgHeight);
    UIGraphicsBeginImageContext(newImageSize);

    for (int i = 0; i < images.count; i++) {
        UIImage *toDraw = (UIImage *)images[i];
        CGFloat drawAtX = (i % numberOfImagesPerLine) * tmpImg.size.width;
        CGFloat drawAtY = (i / numberOfImagesPerLine) * tmpImg.size.height;
        [toDraw drawAtPoint:CGPointMake(drawAtX, drawAtY)];
    }
    UIImage *bigImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return bigImage;
}

+ (NSArray *)splitImage:(UIImage *)image
        smallImageWidth:(CGFloat)smallImageWidth
       smallImageHeight:(CGFloat)smallImageHeight
                  count:(NSUInteger)count
{
    NSInteger numberOfRows = image.size.height / smallImageHeight;
    NSInteger numberOfSmallImagesInRow = image.size.width / smallImageWidth;
    NSInteger smallImagesCount = numberOfRows * numberOfSmallImagesInRow;

    NSMutableArray <UIImage *> *images = [NSMutableArray arrayWithCapacity:smallImagesCount];
    for (NSInteger i = 0; i < smallImagesCount && images.count < count;i++) {
        CGFloat smallImageTop = (int)(i / numberOfSmallImagesInRow) * smallImageHeight;
        CGFloat smallImageLeft = (int)(i % numberOfSmallImagesInRow) * smallImageWidth;
        CGRect popImgFrame = CGRectMake(smallImageLeft, smallImageTop, smallImageWidth, smallImageHeight);
        CGImageRef popCGImage = CGImageCreateWithImageInRect(image.CGImage, popImgFrame);
        UIImage *tmpImage = [UIImage imageWithCGImage:popCGImage];
        if (tmpImage) {
            [images addObject:tmpImage];
        }
        CGImageRelease(popCGImage);
    }
    return [images copy];
}

+ (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)width
{
    CGFloat ratio = width / image.size.width;
    CGSize newSize = CGSizeMake(image.size.width * ratio, image.size.height*ratio);
    UIGraphicsBeginImageContext(newSize); //stick to 1.0 scale or the size may get largger
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)cropCenterSquareImage:(UIImage *)image
{
    CGFloat minLength = MIN(image.size.width, image.size.height);
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    if (minLength == image.size.width) {
        y = (image.size.height - minLength) / 2.0f;
    }

    if (minLength == image.size.height) {
        x = (image.size.width - minLength) / 2.0f;
    }

    CGRect rect = CGRectMake(x, y, minLength, minLength);
    image = [image ADKCropRect:rect];
    return image;
}

@end
