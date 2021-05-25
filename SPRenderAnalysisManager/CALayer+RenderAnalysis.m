//
//  CALayer+RenderAnalysis.m
//  Test
//
//  Created by Tree on 2021/5/2.
//  Copyright © 2021 Tr2e. All rights reserved.
//

#import "CALayer+RenderAnalysis.h"
#import "SPRenderAnalysisManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation CALayer (RenderAnalysis)

static IMP origin_display_impl;
static dispatch_semaphore_t lock;
static NSMutableDictionary *analysisResult;

+ (void)load {
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    BOOL jumped = NO;
    for (unsigned int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL sel = method_getName(method);
        if ([[NSString stringWithUTF8String:sel_getName(sel)] isEqualToString:NSStringFromSelector(@selector(display))]) {
            if (jumped == NO) {
                jumped = YES; continue; }
            origin_display_impl = method_getImplementation(method);
        }
    }
}

- (UIViewController *)basedViewController {
    UIViewController *vc = objc_getAssociatedObject(self, _cmd);
    if (vc == nil) {
        UIView *view = (UIView *)self.delegate;
        while (view != nil && ![view.nextResponder isKindOfClass:[UIViewController class]]) {
            view = (UIView *)view.nextResponder;
        }
        vc = (UIViewController *)view.nextResponder;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).viewControllers.lastObject;
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }
        objc_setAssociatedObject(self, _cmd, vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return vc;
}

- (NSString *)basedViewControllerName {
    return NSStringFromClass([[self basedViewController] class]);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)display {
    origin_display_impl();
    // 获取控制器
    UIViewController *vc = [self basedViewController];
    if (!vc) return;
    // 获取时间戳
    NSNumber *timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
    // 更新时间戳
    if (![SPRenderAnalysisManager hasAnalyzedViewController:vc]) {
        [SPRenderAnalysisManager setRenderTimestamp:timestamp.stringValue forKey:NSStringFromClass([vc class])];
    }
}

@end
