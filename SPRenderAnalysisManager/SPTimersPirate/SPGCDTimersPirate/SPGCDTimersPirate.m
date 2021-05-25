//
//  SPGCDTimersPirate.m
//  biyao
//
//  Created by Tr2e on 2021/5/13.
//  Copyright © 2021 Tr2e. All rights reserved.
//

#import "SPGCDTimersPirate.h"
#import "fishhook.h"

/* block holder */
@interface SPGCDTimersPirateItem : NSObject
@property (nonatomic, copy) NSString *sourceTag;
@property (nonatomic) dispatch_block_t handler;
@end

@implementation SPGCDTimersPirateItem
@end

/* manage timer blocks */
static NSMutableArray *_sp_gcdtimer_monitor;
static NSString *_sp_source_prefix = @"sp_pirate_";
static dispatch_semaphore_t _sp_gcd_lock;
static bool _sp_rob = false;

/* hook gcd */
static dispatch_source_t
(* orig_dispatch_source_create)(dispatch_source_type_t type,
                                uintptr_t handle,
                                uintptr_t mask,
                                dispatch_queue_t _Nullable queue);

static void
(* orig_dispatch_source_set_event_handler)(dispatch_source_t source,
                                           dispatch_block_t _Nullable handler);

dispatch_source_t
sp_dispatch_source_create(dispatch_source_type_t type,
                          uintptr_t handle,
                          uintptr_t mask,
                          dispatch_queue_t _Nullable queue) {
    NSLog(@"🚀 hook dispatch_source_create success");
    dispatch_source_t source_t = orig_dispatch_source_create(type,
                                                             handle,
                                                             mask,
                                                             queue);
    
    NSString *sourceTag = [NSString stringWithFormat:@"%@%@",_sp_source_prefix,source_t];
    
    NSString *queue_class = NSStringFromClass(queue.class);
    if (type == DISPATCH_SOURCE_TYPE_TIMER &&
        ([queue_class isEqual:@"OS_dispatch_queue_global"] ||
         [queue_class isEqual:@"OS_dispatch_queue_main"])) {
        [_sp_gcdtimer_monitor addObject:sourceTag];
    }
    return source_t;
}

void
sp_dispatch_source_set_event_handler(dispatch_source_t source,
                                     dispatch_block_t _Nullable handler) {
    NSLog(@"🚀 hook dispatch_source_set_event_handler success");
    NSString *sourceTag = [NSString stringWithFormat:@"%@%@",_sp_source_prefix,source];
    dispatch_block_t source_handler = handler;
    if ([_sp_gcdtimer_monitor containsObject:sourceTag]) {
        dispatch_block_t rob_block = ^{
            if (_sp_rob == false && handler != nil) handler();
        };
        source_handler = rob_block;
    }
    orig_dispatch_source_set_event_handler(source,
                                           source_handler);
}



@implementation SPGCDTimersPirate

+ (void)load {
    // 初始化
    _sp_gcdtimer_monitor = [[NSMutableArray alloc] init];
    _sp_gcd_lock = dispatch_semaphore_create(1);
    // 方法替换
    struct rebinding dispatch_source_create_rebinding = { "dispatch_source_create", sp_dispatch_source_create, &orig_dispatch_source_create };
    struct rebinding dispatch_source_set_event_rebinding = { "dispatch_source_set_event_handler", sp_dispatch_source_set_event_handler, &orig_dispatch_source_set_event_handler };
    rebind_symbols((struct rebinding[1]){dispatch_source_create_rebinding}, 1);
    rebind_symbols((struct rebinding[1]){dispatch_source_set_event_rebinding}, 1);
}

+ (void)killAllTimers {
    _sp_rob = true;
}

+ (void)reviveAllTimers {
    _sp_rob = false;
}

@end
