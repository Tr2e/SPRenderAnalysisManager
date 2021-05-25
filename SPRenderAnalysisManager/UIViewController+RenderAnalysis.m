//
//  UIViewController+RenderAnalysis.m
//  Test
//
//  Created by Tree on 2021/5/2.
//  Copyright © 2021 Tr2e. All rights reserved.
//

#import "UIViewController+RenderAnalysis.h"
#import "SPRenderAnalysisManager.h"
#import <objc/runtime.h>

@implementation UIViewController (RenderAnalysis)

+ (void)load {
    SwizzlingMethods(self, @selector(viewDidAppear:), @selector(sp_viewDidAppear:));
    SwizzlingMethods(self, @selector(viewWillDisappear:), @selector(sp_viewWillDisappear:));
}

- (void)sp_viewDidAppear:(BOOL)animated {
    [SPRenderAnalysisManager startAnalyzeViewController:self];
    [self sp_viewDidAppear:animated];
}

- (void)sp_viewWillDisappear:(BOOL)animated {
    [SPRenderAnalysisManager stopAnalyzeViewController:self];
    [self sp_viewWillDisappear:animated];
}

static void SwizzlingMethods(Class c,SEL orig,SEL news){
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, news);
    
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, news, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@end
