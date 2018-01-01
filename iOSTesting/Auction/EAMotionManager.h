//
//  EAMotionManager.h
//  ECAuctionApp
//
//  Created by  Tim Chiang on 2017/1/4.
//  Copyright © 2017年 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@class EAMotionManager;

@protocol EAMotionManagerDelegate <NSObject>

@optional

- (void)motionManager:(EAMotionManager *)manager didUpdateAttitudeRoll:(double)roll;

@end

@interface EAMotionManager : CMMotionManager

@property (weak, nonatomic) id<EAMotionManagerDelegate> delegate;
@property (assign, nonatomic, readonly) double roll; //NOTE: to be observe

+ (instancetype)shardedInstance;
- (void)startAttitudeRollUpdates;
- (void)stopAttitudeRollUpdates;

@end
