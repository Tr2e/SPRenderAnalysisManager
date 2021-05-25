//
//  SPRunloopTimersPirate.m
//  biyao
//
//  Created by Tr2e on 2021/5/12.
//  Copyright © 2021 Tr2e. All rights reserved.
//

#import "SPRunloopTimersPirate.h"
#import "SPRunloopDefine.h"

@implementation SPRunloopTimersPirate
static dispatch_semaphore_t _sp_runloop_lock;

+ (void)load {
    _sp_runloop_lock = dispatch_semaphore_create(1);
}

+ (void)killAllTimers {
    dispatch_semaphore_wait(_sp_runloop_lock, DISPATCH_TIME_FOREVER);
    CFRunLoopRef runloopRef = [NSRunLoop mainRunLoop].getCFRunLoop;
    struct __CFRunLoop trans_runloop = *runloopRef;
    CFMutableSetRef modesRef = trans_runloop._modes;
    NSMutableSet *set = (__bridge NSMutableSet *)(modesRef);
    NSArray *modes = set.allObjects;
    for (NSObject *mode in modes) {
        CFRunLoopModeRef modeRef = (__bridge CFRunLoopModeRef)(mode);
        struct __CFRunLoopMode trans_mode = *modeRef;
        if (trans_mode._timers == NULL) continue;
        CFArrayRef timersRef = trans_mode._timers;
        NSArray *timers = (__bridge NSArray *)timersRef;
        timers = [timers copy];
        for (NSObject *timer in timers) {
            CFRunLoopTimerRef timerRef = (__bridge CFRunLoopTimerRef)(timer);
            CFRunLoopTimerContext context;
            CFRunLoopTimerGetContext(timerRef, &context);
            if (context.retain == NULL) continue;
            CFRunLoopTimerInvalidate(timerRef);
        }
    }
    dispatch_semaphore_signal(_sp_runloop_lock);
}

@end
