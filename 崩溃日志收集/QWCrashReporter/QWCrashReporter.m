//
//  QWCrashReporter.m
//  崩溃日志收集
//
//  Created by qwkj on 2017/11/13.
//  Copyright © 2017年 qwkj. All rights reserved.
//

#import "QWCrashReporter.h"
#import <UIKit/UIKit.h>
#import <WZCrashCatcher/WZCrashCatcher.h>

#import <QW_Http/CIM_HTTPTool.h>

@implementation QWCrashReporter

+ (void)Install
{

    //初始化log捕捉
    [WZCrashCatcher WZ_initCrashCatcher];

    //获取是否有log
    NSArray *arr = [self getlogs];
    if (arr && arr.count > 0)
    {
        [self reportCarshLogs:arr];
    }
}

+(nullable NSArray *)getlogs{
    return [WZCrashCatcher WZ_getCrashLogs];
}
+(void)clearLogs{
    [WZCrashCatcher WZ_clearCrashLogs];
}

+ (void)reportCarshLogs:(NSArray *)logs
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:[NSMutableArray arrayWithArray:logs] options:NSJSONWritingPrettyPrinted error:nil];

    if (data)
    {
        //上传服务器
        [CIM_HTTPTool CIM_UploadFileV3:@"http://www.zexianglin.com/EstateService/httpInterface/apk/uploadAppLog"
            parameters:^(NSMutableDictionary *params) {

                params[@"type"] = @"2";
            }
            constructingBodyWithBlock:^(NSMutableArray<QW_fileData *> *fileModels) {

                QW_fileData *fileData = [QW_fileData fileData:data Name:@"file" fileName:@"iOS_Carsh_log" mimeType:@"application/json"];
                [fileModels addObject:fileData];
            }
            success:^(id jsonData) {
                //上传成功清理logs
                [self clearLogs];
            }
            failure:^(NSString *errorStr) {

            }
            connectfailure:^(BOOL *isShowErrorAlert){

            }];
    }

}



@end
