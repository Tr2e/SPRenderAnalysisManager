//
//  SPRenderAnalysisManager.m
//  Test
//
//  Created by Tree on 2021/5/2.
//  Copyright © 2021 Tr2e. All rights reserved.
//

#import "SPRenderAnalysisManager.h"

@implementation SPRenderAnalysisManager
static NSMutableSet *_sp_analysis_set;
static dispatch_semaphore_t _sp_start_lock;
static dispatch_semaphore_t _sp_render_lock;
static NSMutableDictionary *_sp_start_map;
static NSMutableDictionary *_sp_render_map;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sp_start_lock = dispatch_semaphore_create(1);
        _sp_render_lock = dispatch_semaphore_create(1);
        _sp_start_map = [[NSMutableDictionary alloc] init];
        _sp_render_map = [[NSMutableDictionary alloc] init];
        _sp_analysis_set = [[NSMutableSet alloc] init];
    });
}

+ (NSDictionary *)analysisResult {
    @synchronized (self) {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithCapacity:_sp_render_map.count];
        for (NSString *key in _sp_render_map.allKeys) {
            NSString *render = [_sp_render_map objectForKey:key];
            NSString *start = [_sp_start_map objectForKey:key];
            if (start == nil || start.floatValue == 0) continue;
            NSNumber *timeinterval = [NSNumber numberWithDouble:(MAX(render.doubleValue - start.doubleValue, 0))];
            [temp setObject:timeinterval.stringValue forKey:key];
        }
        return [temp copy];
    }
}

+ (void)startAnalyzeViewController:(id)viewController {
    // 获取控制器
    NSString *key = NSStringFromClass([viewController class]);
    // 判断已分析
    if ([self hasAnalyzedViewController:viewController]) return;
    // 获取时间戳
    NSNumber *timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
    // 更新时间戳
    [self setStartTimestamp:timestamp.stringValue forKey:key];
}

+ (void)stopAnalyzeViewController:(id)viewController {
    // 获取控制器
    NSString *key = NSStringFromClass([viewController class]);
    // 记录已分析
    [_sp_analysis_set addObject:key];
}

+ (BOOL)hasAnalyzedViewController:(id)viewController {
    NSString *key = NSStringFromClass([viewController class]);
    return [_sp_analysis_set containsObject:key];
}

+ (void)setStartTimestamp:(NSString *)timestamp forKey:(NSString *)key {
    dispatch_semaphore_wait(_sp_start_lock, DISPATCH_TIME_FOREVER);
    [_sp_start_map setObject:timestamp forKey:key];
    dispatch_semaphore_signal(_sp_start_lock);
}

+ (void)setRenderTimestamp:(NSString *)timestamp forKey:(NSString *)key {
    dispatch_semaphore_wait(_sp_render_lock, DISPATCH_TIME_FOREVER);
    [_sp_render_map setObject:timestamp forKey:key];
    dispatch_semaphore_signal(_sp_render_lock);
}

+ (void)clear {
    [_sp_start_map removeAllObjects];
    [_sp_render_map removeAllObjects];
}

@end
