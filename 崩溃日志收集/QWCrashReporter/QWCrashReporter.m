//
//  QWCrashReporter.m
//  崩溃日志收集
//
//  Created by qwkj on 2017/11/13.
//  Copyright © 2017年 qwkj. All rights reserved.
//

#import "QWCrashReporter.h"
#import <UIKit/UIKit.h>
#import <WZCarshCatcher.h>

#import <QW_Http/CIM_HTTPTool.h>

@implementation QWCrashReporter

+ (void)Install
{

    //初始化log捕捉
    [WZCarshCatcher WZ_initCarshCatcher];

    //获取是否有log
    NSArray *arr = [self getlogs];
    if (arr && arr.count > 0)
    {
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:nil message:@"find a bug" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok" ,   nil];
        [alertV show];
        [self reportCarshLogs:arr];
    }
}

+(nullable NSArray *)getlogs{
    return [WZCarshCatcher WZ_getCrashLogs];
}
+(void)clearLogs{
    [WZCarshCatcher WZ_clearCrashLogs];
}

+ (void)reportCarshLogs:(NSArray *)logs
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:[NSMutableArray arrayWithArray:logs] options:NSJSONWritingPrettyPrinted error:nil];

    if (data)
    {
        //上传服务器
        [CIM_HTTPTool CIM_UploadImagesFileV3:@"http://www.zexianglin.com/EstateService/httpInterface/apk/uploadAppLog"
            parameters:^(NSMutableDictionary *params) {

                params[@"type"] = @"2";
            }
            constructingBodyWithBlock:^(NSMutableArray<QW_ImageData *> *imageModels) {

                QW_ImageData *fileData = [QW_ImageData imageData:data Name:@"file" fileName:@"iOS_Carsh_log" mimeType:@"application/json"];
                [imageModels addObject:fileData];
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
