//
//  WZCarshCatcher.m
//  崩溃日志收集
//
//  Created by qwkj on 2017/11/14.
//  Copyright © 2017年 qwkj. All rights reserved.
//

#import "WZCrashCatcher.h"

//你的项目中自定义文件夹名
static NSString *const WZCrashFileDirectory = @"WZCrashCatcherFileDirectory";

@implementation WZCrashCatcher

+ (void)WZ_initCrashCatcher
{
    //carsh 回调注册
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

static inline NSString *WZ_getCachesPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

static void UncaughtExceptionHandler(NSException *exception)
{
    if (exception == nil)
        return;
    NSArray *array = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDictionary *dict = @{ @"appException": @{@"exceptioncallStachSymbols": array, @"exceptionreason": reason, @"exceptionname": name} };
    if (dict)
    {
        [WZCrashCatcher writeCrashFileOnDocumentsException:dict];
    }
}

+ (BOOL)writeCrashFileOnDocumentsException:(NSDictionary *)exception
{

    NSString *crashPath = [WZ_getCachesPath() stringByAppendingPathComponent:WZCrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager createDirectoryAtPath:crashPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (isSuccess)
    {
        NSLog(@"文件夹创建成功");

        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        //设备信息
        NSMutableDictionary *deviceInfos = [NSMutableDictionary dictionary];
        [deviceInfos setObject:[infoDictionary objectForKey:@"DTPlatformVersion"] forKey:@"DTPlatformVersion"];
        [deviceInfos setObject:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"CFBundleShortVersionString"];
        [deviceInfos setObject:[infoDictionary objectForKey:@"UIRequiredDeviceCapabilities"] forKey:@"UIRequiredDeviceCapabilities"];
        //app信息
        NSMutableDictionary *appInfos = [NSMutableDictionary dictionary];
        [appInfos setObject:[infoDictionary objectForKey:@"CFBundleName"] forKey:@"CFBundleName"];
        [appInfos setObject:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"CFBundleShortVersionString"];
        [appInfos setObject:[infoDictionary objectForKey:@"CFBundleIdentifier"] forKey:@"CFBundleIdentifier"];

        //文件名生成
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
        NSString *time = [formatter stringFromDate:date];
        NSString *crashname = [NSString stringWithFormat:@"%@_%@Crashlog.plist", time, infoDictionary[@"CFBundleName"]];

        NSString *filepath = [crashPath stringByAppendingPathComponent:crashname];
        NSMutableDictionary *logs = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
        if (!logs)
        {
            logs = [[NSMutableDictionary alloc] init];
        }
        //日志信息
        NSDictionary *infos = @{ @"Exception": exception,
                                 @"DeviceInfo": deviceInfos,
                                 @"Appinfo": appInfos };
        [logs setObject:infos forKey:[NSString stringWithFormat:@"%@_crashLogs", infoDictionary[@"CFBundleName"]]];
        
        BOOL writeOK = [logs writeToFile:filepath atomically:YES];
        NSLog(@"write result = %d,filePath = %@", writeOK, filepath);
        return writeOK;
    }
    else
    {
        return NO;
    }
}

+ (nullable NSArray *)WZ_getCrashLogs
{

    NSString *crashPath = [WZ_getCachesPath() stringByAppendingPathComponent:WZCrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:crashPath error:nil];
    NSMutableArray *result = [NSMutableArray array];
    if (array.count == 0)
        return nil;
    for (NSString *name in array)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[crashPath stringByAppendingPathComponent:name]];
        !dict?:[result addObject:dict];
    }
    return result;
}
+ (BOOL)WZ_clearCrashLogs
{

    NSString *crashPath = [WZ_getCachesPath() stringByAppendingPathComponent:WZCrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:crashPath])
        return YES; //如果不存在,则默认为删除成功
    NSArray *contents = [manager contentsOfDirectoryAtPath:crashPath error:NULL];
    if (contents.count == 0)
        return YES;
    NSEnumerator *enums = [contents objectEnumerator];
    NSString *filename;
    BOOL success = YES;
    while (filename = [enums nextObject])
    {
        if (![manager removeItemAtPath:[crashPath stringByAppendingPathComponent:filename] error:NULL])
        {
            success = NO;
            break;
        }
    }
    return success;
}


@end
