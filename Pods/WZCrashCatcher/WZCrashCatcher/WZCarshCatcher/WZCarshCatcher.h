//
//  WZCarshCatcher.h
//  崩溃日志收集
//
//  Created by qwkj on 2017/11/14.
//  Copyright © 2017年 qwkj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZCarshCatcher : NSObject

+ (void)WZ_initCarshCatcher;

+ (nullable NSArray *)WZ_getCrashLogs;

+ (BOOL)WZ_clearCrashLogs;

@end
