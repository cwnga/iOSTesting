//
//  EAMotionManager.m
//  ECAuctionApp
//
//  Created by  Tim Chiang on 2017/1/4.
//  Copyright © 2017年 Yahoo. All rights reserved.
//

#import "EAMotionManager.h"

@interface EAMotionManager()

@property (assign, nonatomic) double roll;
@property (assign, atomic) NSInteger observerCount;
@property (assign, nonatomic) BOOL startedUpdate;
@property (strong, nonatomic) CMAttitude *initialAttitude;

@end

@implementation EAMotionManager

- (void)dealloc
{
    [self stopAttitudeRollUpdates];
}

+ (instancetype)shardedInstance
{
    static dispatch_once_t onceToken;

    static EAMotionManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[EAMotionManager alloc] init];
    });
    return manager;
}

- (void)startAttitudeRollUpdates
{
    if (self.startedUpdate) {
        return;
    }
    self.startedUpdate = YES;
    self.initialAttitude = nil;

    __weak typeof(self) weakSelf = self;
    CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error) {
        if (!weakSelf) {
            return;
        }
        if (!weakSelf.initialAttitude) {
            weakSelf.initialAttitude = motion.attitude;
        }
        
        [motion.attitude multiplyByInverseOfAttitude:weakSelf.initialAttitude];
        weakSelf.roll = motion.attitude.roll * 180 / M_PI;
        if ([weakSelf.delegate respondsToSelector:@selector(motionManager:didUpdateAttitudeRoll:)]) {
            [weakSelf.delegate motionManager:weakSelf didUpdateAttitudeRoll:weakSelf.roll];
        }
    };
    
    self.deviceMotionUpdateInterval = 0.01f;
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [self startDeviceMotionUpdatesToQueue:queue
                              withHandler:handler];
}

- (void)stopAttitudeRollUpdates
{
    self.startedUpdate = NO;
    [self stopDeviceMotionUpdates];
}

#pragma mark - overwrite
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
    self.observerCount++;
    [self startAttitudeRollUpdates];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [super removeObserver:observer forKeyPath:keyPath];
    self.observerCount--;
    if (self.observerCount <= 0) {
        [self stopAttitudeRollUpdates];
    }
}
@end
