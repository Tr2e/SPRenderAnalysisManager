//
//  SPRenderAnalysisManager.h
//  Test
//
//  Created by Tree on 2021/5/2.
//  Copyright © 2021 Tr2e. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;
@interface SPRenderAnalysisManager : NSObject
@property (readonly, class) NSDictionary *analysisResult;
+ (void)setStartTimestamp:(NSString *)timestamp forKey:(NSString *)key;
+ (void)setRenderTimestamp:(NSString *)timestamp forKey:(NSString *)key;
+ (void)startAnalyzeViewController:(UIViewController *)viewController;
+ (void)stopAnalyzeViewController:(UIViewController *)viewController;
+ (BOOL)hasAnalyzedViewController:(UIViewController *)viewController;
+ (void)clear;
@end

NS_ASSUME_NONNULL_END
