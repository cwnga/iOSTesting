//
//  EACollectionViewGalleryImage360Cell.m
//  ECAuctionApp
//
//  Created by  Tim Chiang on 2017/1/5.
//  Copyright © 2017年 Yahoo. All rights reserved.
//

#import "EACollectionViewGalleryImage360Cell.h"
#import "EASKImageView.h"
#import "EAMotionManager.h"
static int kObservingEAMotionManagerRollChangesContext;
@interface EACollectionViewGalleryImage360Cell () <EAMotionManagerDelegate>

@property (weak, nonatomic) IBOutlet EASKImageView *skImageView;
@property (weak, nonatomic) IBOutlet UIView *dotView;
@property (assign, nonatomic) BOOL observedRollValue;

@end

@implementation EACollectionViewGalleryImage360Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.image360TypeImageView.layer.cornerRadius = 2.5f;
    self.image360TypeImageView.layer.masksToBounds = YES;

    self.dotView.layer.cornerRadius = CGRectGetHeight(self.dotView.frame) / 2.0f;
    self.dotView.layer.masksToBounds = YES;
    self.dotView.center = CGPointMake(CGRectGetWidth(self.dotView.superview.frame) / 2.0f , CGRectGetHeight(self.dotView.superview.frame) /2.0f);

}

- (void)dealloc
{
    [self stopMotionUpdateImage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (context == &kObservingEAMotionManagerRollChangesContext) {
        [self motionManager:[EAMotionManager shardedInstance] didUpdateAttitudeRoll:[EAMotionManager shardedInstance].roll];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.images = nil;
}

- (void)updateDotPositionWithRatio:(CGFloat)ratio
{
    if (ratio < 0) {
        ratio = 0;
    }
    if (ratio > 1) {
        ratio = 1;
    }
    self.dotView.center = CGPointMake(ratio * CGRectGetWidth(self.dotView.superview.frame), CGRectGetHeight(self.dotView.superview.frame) /2.0f);
}

- (void)setImages:(NSArray<UIImage *> *)images
{
    _images = images;
    if (_images.count > 1) {
        [self startMotionUpdateImage];
        [self showImageWithIndex:0];
    }
}

- (void)showImageWithIndex:(NSInteger)index
{
    if (index < self.images.count) {
        self.skImageView.image = self.images[index];
        [self updateDotPositionWithRatio:((CGFloat)index / (CGFloat)self.images.count)];
        if ([self.delegate respondsToSelector:@selector(collectionViewGalleryImage360Cell:didShowImageIndex:)]) {
            [self.delegate collectionViewGalleryImage360Cell:self didShowImageIndex:index];
        }
    }
}

#pragma mark - Motion update

- (void)startMotionUpdateImage
{
    if (!self.observedRollValue) {
        self.observedRollValue = YES;
        [[EAMotionManager shardedInstance] addObserver:self forKeyPath:@"roll" options:NSKeyValueObservingOptionNew context:&kObservingEAMotionManagerRollChangesContext];
    }
}

- (void)stopMotionUpdateImage
{
    if (self.observedRollValue) {
        [[EAMotionManager shardedInstance] removeObserver:self forKeyPath:@"roll" context:&kObservingEAMotionManagerRollChangesContext];
        self.observedRollValue = NO;
    }
}

#pragma mark - <EAMotionManagerDelegate>

- (void)motionManager:(EAMotionManager *)manager didUpdateAttitudeRoll:(double)roll
{
    if (self.images.count > 0) {
        CGFloat value = 0.0f;
        value = (self.images.count / 2);
        NSInteger index = round([self normalizedWithRoll:roll min:-value max:value] * self.images.count - 1);
        [self showImageWithIndex:index];
    }
}

#pragma mark - normalized

- (CGFloat)normalizedWithRoll:(double)roll min:(CGFloat)min max:(CGFloat)max
{
    CGFloat normalizedValue;
    if (max == min) {
        normalizedValue = 1;
    } else if (roll >= max) {
        normalizedValue = 1;
    } else if (roll <= min) {
        normalizedValue = 0;
    } else {
        normalizedValue = (roll - min) / (max - min);
    }
    return normalizedValue;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.image360TypeImageView.layer.cornerRadius = 2.5f;
    self.image360TypeImageView.layer.masksToBounds = YES;
}

@end
