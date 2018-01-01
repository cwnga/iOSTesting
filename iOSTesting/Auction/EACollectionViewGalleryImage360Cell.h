//
//  EACollectionViewGalleryImage360Cell.h
//  ECAuctionApp
//
//  Created by  Tim Chiang on 2017/1/5.
//  Copyright © 2017年 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EASKImageView.h"

static NSString * const EACollectionViewGalleryImage360CellIdentifier = @"EACollectionViewGalleryImage360Cell";

@class EACollectionViewGalleryImage360Cell;


@protocol EACollectionViewGalleryImage360CellDelegate <NSObject>
- (void)collectionViewGalleryImage360Cell:(EACollectionViewGalleryImage360Cell *)cell didShowImageIndex:(NSInteger)index;
@end

@interface EACollectionViewGalleryImage360Cell : UICollectionViewCell

@property (strong, nonatomic) NSArray <UIImage *> *images;
@property (weak, nonatomic) IBOutlet UIImageView *image360TypeImageView;
@property (weak, nonatomic) id <EACollectionViewGalleryImage360CellDelegate> delegate;

- (void)showImageWithIndex:(NSInteger)index;
- (void)stopMotionUpdateImage;
- (void)startMotionUpdateImage;

@end
