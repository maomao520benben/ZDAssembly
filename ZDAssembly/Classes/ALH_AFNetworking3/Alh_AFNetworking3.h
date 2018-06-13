//
//  Alh_AFNetworking3.h
//  AFNetworking3
//
//  Created by 南京夏恒 on 16/6/1.
//  Copyright © 2016年 南京夏恒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AFNetworking;
typedef NS_ENUM(NSInteger, AlhDownloadType) {
    AlhDownloadTypeGet,
    AlhDownloadTypePost
};
@interface Alh_AFNetworking3 : NSObject

/*
 get、post请求
 */
+ (void)downloadDataWithType:(AlhDownloadType)type
                        Path:(NSString *)path
                  Parameters:(NSDictionary *)parameters
                     success:(void (^)(NSData *data))success fail:(void (^)(NSError *error))fail;

/*
 post请求
 */
+ (void)downloadDataWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                    callback:(void (^)(NSDictionary *data))callbackBlock;


//上传视频文件
+ (void)postUploadFileWithPath:(NSString *)path
                    Parameters:(NSDictionary *)parameters
                UploadFilePath:(NSString *)filePath
                       success:(void (^)(NSData *data))success fail:(void (^)(NSError *error))fail;

//上传本地文件
+ (void)postUploadLocalFileParameters:(NSDictionary *)parameters
                             callback:(void (^)(NSDictionary *para))callbackBlock;
//上传多个文件
+ (void)postUploadMutableFileWithPath:(NSString *)path
                           Parameters:(NSDictionary *)parameters
                       UploadFilePath:(NSArray *)filePaths
                              success:(void (^)(NSData *data))success
                                 fail:(void (^)(NSError *error))fail;


/*
 上传图片
 */
+ (void)postUploadImageWithPath:(NSString *)path
                     Parameters:(NSDictionary *)parameters
                    UploadImage:(UIImage *)image
                        success:(void (^)(NSData *data))success fail:(void (^)(NSError *error))fail;
/**
 *  下载文件
 *
 *  @param urlString  下载的RL
 *  @param filepath   下载路径
 *  @param progress   进度Block
 *  @param completion 完成Block
 */
+ (void)downloadFileWithPath:(NSString *)urlString
                    filepath:(NSString *)filepath
                    progress:(void (^)(float progress))progress
                  completion:(void (^)(NSError *error))completion;
@end
