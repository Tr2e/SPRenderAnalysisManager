//
//  SPTimersPirate.m
//  biyao
//
//  Created by Tr2e on 2021/5/14.
//  Copyright © 2021 com.biyao. All rights reserved.
//

#import "SPTimersPirate.h"
#import "SPGCDTimersPirate.h"
#import "SPRunloopTimersPirate.h"

@implementation SPTimersPirate

+ (void)killAllTimers {
    [SPGCDTimersPirate killAllTimers];
    [SPRunloopTimersPirate killAllTimers];
}

+ (void)reviveAllTimers {
    [SPGCDTimersPirate reviveAllTimers];
}

@end
