//
//  MainViewController.m
//  iOSTesting
//
//  Created by  Anson Ng on 27/12/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "MainViewController.h"
#import "EAImage360Library.h"
#import "EACollectionViewCell.h"
#import "EACollectionViewGalleryImage360Cell.h"


@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, EAImage360LibraryDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) EAImage360Library *image360Library;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray <AVAsset *> *assets;
@property (weak, nonatomic) IBOutlet UIImageView *oriImageView;
@property (weak, nonatomic) IBOutlet UIImageView *comImageView;
@property (weak, nonatomic) IBOutlet UIView *motionContainer1View;
@property (weak, nonatomic) IBOutlet UIView *motionContainer2View;
@property (strong, nonatomic) EACollectionViewGalleryImage360Cell *image360View1;
@property (strong, nonatomic) EACollectionViewGalleryImage360Cell *image360View2;

@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.image360Library.previewLayer.frame =  self.previewView.bounds;
    [self.previewView.layer addSublayer:self.image360Library.previewLayer];
    [self.image360Library startCamera];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.assets = [NSMutableArray array];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *needToStop) {
            ALAssetRepresentation *representation = [result defaultRepresentation];
            NSURL *url = [representation url];
            AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
            if (asset) {
                [self.assets addObject:asset];
            }
        }];
        [self performSelectorOnMainThread:@selector(usePhotolibraryimage) withObject:nil waitUntilDone:NO];
    } failureBlock:^(NSError *error) {

    }];
    /////////////////


    self.image360Library = [[EAImage360Library alloc] init];
    [self.image360Library initCamera];
    self.image360Library.delegate = self;

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib *nib  = [UINib nibWithNibName:@"EACollectionViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"EACollectionViewCell"];
    [self setup];

}
- (void)setup
{
    self.image360View1 = [[[NSBundle mainBundle] loadNibNamed:@"EACollectionViewGalleryImage360Cell" owner:Nil options:nil] lastObject];
    self.image360View1.frame = self.motionContainer1View.bounds;
    [self.motionContainer1View addSubview:self.image360View1];
    self.image360View1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.image360View2 = [[[NSBundle mainBundle] loadNibNamed:@"EACollectionViewGalleryImage360Cell" owner:Nil options:nil] lastObject];
    self.image360View2.frame = self.motionContainer2View.bounds;
    [self.motionContainer2View addSubview:self.image360View2];
    self.image360View2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)usePhotolibraryimage
{
    [self.collectionView reloadData];
}

- (void)showMessage:(NSString *)string
{
    dispatch_async( dispatch_get_main_queue(), ^{
        self.errorLabel.text = string;
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.errorLabel.text = @"";
    });
}
- (void)image360Library:(EAImage360Library *)library error:(NSError *)error
{
    [self showMessage:[NSString stringWithFormat:@"%@", error]];

}
- (void)willGenerateImagesByImage360Library:(EAImage360Library *)eaImage360Library
{
    [self showMessage:@"willGenerateImagesByImage360Library"];

}
- (void)didGenerateImagesByImage360Library:(EAImage360Library *)eaImage360Library images:(NSArray <UIImage *> *)images
{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessage:@"didGenerateImagesByImage360Library"];

        if (images) {
            self.oriImageView.image = images.firstObject;
            [self showMessage:[NSString stringWithFormat: @"didGenerateImagesByImage360Library:%@", NSStringFromCGSize(self.oriImageView.image.size)]];
        }
    });

}
- (IBAction)tapRecord:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.image360Library startCaptureVideo];

    } else {
        [self.image360Library stopCaptureVideo];
    }
    
}

#pragma mark - collectionview
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EACollectionViewCell *cell = (EACollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"EACollectionViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", self.assets[indexPath.row]];
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self imageViewOfAsset:self.assets[indexPath.row]];
}

- (void)imageViewOfAsset:(AVAsset *)asset
{
    //ori
    [EAImage360Library genImagesWithAVAsset:asset preferSize:CGSizeMake(500, 500) maxImageCount:60 processingErrorBlock:^(NSError *error) {

    } complete:^(NSArray<UIImage *> *images) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.oriImageView.image = [images firstObject];
            self.image360View1.images = images;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.image360View2.images = images;
            });

        });

    }];
    [self trimAVAsset:asset mute:NO startTime:0 endTime:1.0f exportAsset:^(AVAsset *splitAsset) {
        [EAImage360Library genImagesWithAVAsset:splitAsset preferSize:CGSizeMake(500, 500) maxImageCount:60 processingErrorBlock:^(NSError *error) {

        } complete:^(NSArray<UIImage *> *images) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.comImageView.image = [images firstObject];
            });

        }];
    }];
}
//
- (void)trimAVAsset:(AVAsset *)asset
               mute:(BOOL)mute
          startTime:(CGFloat)startTime
            endTime:(CGFloat)endTime
        exportAsset:(void (^)(AVAsset *))exportAsset
{
    AVAsset *anAsset = [asset copy];
    endTime = MIN(endTime,  CMTimeGetSeconds(anAsset.duration));

    if (mute) {
        //extract origin video track, create new one
        AVMutableComposition *composition = [AVMutableComposition composition];
        AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack * sourceVideoTrack = [[anAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CMTimeRange x = CMTimeRangeMake(kCMTimeZero, [anAsset duration]);
        [compositionVideoTrack setPreferredTransform:sourceVideoTrack.preferredTransform];
        BOOL muteSuccess = [compositionVideoTrack insertTimeRange:x
                                                 ofTrack:sourceVideoTrack
                                                  atTime:kCMTimeZero
                                              error:nil];
        
        anAsset = composition;
        if (muteSuccess == NO) {
            //TODO: show error can not mute
        }
    }

    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:anAsset presetName:AVAssetExportPresetHighestQuality];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/output_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
        NSURL *url = [NSURL fileURLWithPath:destinationPath];
        exportSession.outputURL = url;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        CMTime start = CMTimeMakeWithSeconds(startTime, 600);
        CMTime duration = CMTimeMakeWithSeconds(endTime, 600);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    break;
                case AVAssetExportSessionStatusCancelled:
                    break;
                case AVAssetExportSessionStatusCompleted: {
                    if (exportAsset) {
                        exportAsset([AVAsset assetWithURL:exportSession.outputURL]);
                    }
                }
                default:
                    break;
            }
        }];
    }
}

- (IBAction)start1:(id)sender
{
    [self.image360View1 startMotionUpdateImage];
}

- (IBAction)stop1:(id)sender
{
    [self.image360View1 stopMotionUpdateImage];
}

- (IBAction)start2:(id)sender
{
    [self.image360View2 startMotionUpdateImage];
}

- (IBAction)stop2:(id)sender
{
    [self.image360View2 stopMotionUpdateImage];
}

@end
