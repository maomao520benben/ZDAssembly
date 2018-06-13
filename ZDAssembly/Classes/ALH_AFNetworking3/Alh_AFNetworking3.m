//
//  Alh_AFNetworking3.m
//  AFNetworking3
//
//  Created by 南京夏恒 on 16/6/1.
//  Copyright © 2016年 南京夏恒. All rights reserved.
//

#import "Alh_AFNetworking3.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#define Host @"HOST"
@interface Alh_AFNetworking3()<NSURLSessionDelegate>
@property(nonatomic,retain)NSURLSessionDownloadTask *downloadTask;
/**  下载历史记录 */
@property (nonatomic,strong) NSMutableDictionary *downLoadHistoryDictionary;
@end
@implementation Alh_AFNetworking3

+ (void)downloadDataWithType:(AlhDownloadType)type Path:(NSString *)path Parameters:(NSDictionary *)parameters success:(void (^)(NSData *data))success fail:(void (^)(NSError *error))fail {
//    DLog(@"%@\n%@", path, parameters);
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //get获取数据
    if (type == AlhDownloadTypeGet) {
        [manage GET:path parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            fail(error);
        }];
    }
    //post获取数据
    else if (type == AlhDownloadTypePost) {
        [manage POST:path parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            fail(error);
        }];
    }
}
/*
 post请求
 */
+ (void)downloadDataWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                    callback:(void (^)(NSDictionary *data))callbackBlock {
//    DLog(@"%@\n%@", path, parameters);
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manage POST:path parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (dict) {
            callbackBlock(@{@"code":@"0", @"data":dict, @"message":@"返回参数已获取"});
        }
        else {
            callbackBlock(@{@"code":@"-1", @"data":@{@"result":error.localizedDescription}, @"message":error.localizedDescription});
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callbackBlock(@{@"code": @"-1", @"data":@{@"result":error.localizedDescription}, @"message":error.localizedDescription});
    }];
}
//上传图片
+ (void)postUploadImageWithPath:(NSString *)path Parameters:(NSDictionary *)parameters UploadImage:(UIImage *)image success:(void (^)(NSData *data))success fail:(void (^)(NSError *error))fail
{
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manage POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation(image, 1);
        [formData appendPartWithFileData:data name:@"report_pic_path" fileName:@"image.jpg" mimeType:@"jpg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}

//上传视频文件
+ (void)postUploadFileWithPath:(NSString *)path
                    Parameters:(NSDictionary *)parameters
                UploadFilePath:(NSString *)filePath
                       success:(void (^)(NSData *data))success
                          fail:(void (^)(NSError *error))fail
{
    //multipart/form-data
    [SVProgressHUD showWithStatus:@"正在上传文件"];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manage POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        DLog(@"%@", [filePath lastPathComponent]);
        [formData appendPartWithFileData:data name:@"file" fileName:[filePath lastPathComponent] mimeType:@"multipart/form-data"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        fail(error);
    }];
}


//上传本地文件
+ (void)postUploadLocalFileParameters:(NSDictionary *)parameters
                             callback:(void (^)(NSDictionary *para))callbackBlock {
    NSArray *filePathArray;
    if (parameters[@"file_path"] && [parameters[@"file_path"] count] > 0) {
        filePathArray = parameters[@"file_path"];
        for (NSString *filePath in filePathArray) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                callbackBlock(@{@"code":@"-1", @"data":@{@"result":[NSString stringWithFormat:@"%@ 文件不存在", filePath]}, @"message":@"文件不存在"});
                return;
            }
        }
    } else {
        callbackBlock(@{@"code":@"-1", @"data":@{@"result":@"file_path参数错误"}, @"message":@"文件不存在"});
        return;
    }
    if (parameters[@"url"] == nil || ![parameters[@"url"] hasPrefix:@"http"]) {
        callbackBlock(@{@"code":@"-1", @"data":@{@"result":@"url参数错误"}, @"message":@"文件不存在"});
        return;
    }
    [SVProgressHUD showWithStatus:@"正在上传文件"];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manage POST:parameters[@"url"] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *filePath in filePathArray) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            [formData appendPartWithFileData:data name:@"file" fileName:[filePath lastPathComponent] mimeType:@"multipart/form-data"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (dict) {
            callbackBlock(@{@"code":@"0", @"data":dict, @"message":@"返回参数已获取"});
        }
        else {
            callbackBlock(@{@"code":@"-1", @"data":@{@"result":error.localizedDescription}, @"message":error.localizedDescription});
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        callbackBlock(@{@"code": @"-1", @"data":@{@"result":error.localizedDescription}, @"message":error.localizedDescription});
    }];
}



//上传多个文件
+ (void)postUploadMutableFileWithPath:(NSString *)path Parameters:(NSDictionary *)parameters UploadFilePath:(NSArray *)filePaths success:(void (^)(NSData *data))success fail:(void (^)(NSError *error))fail {
    //multipart/form-data
    [SVProgressHUD showWithStatus:@"正在上传文件"];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manage POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *filePath in filePaths) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
//            DLog(@"%@", [filePath lastPathComponent]);
            if ([[filePath lastPathComponent] containsString:@"mp4"]) {
                [formData appendPartWithFileData:data name:@"video" fileName:[filePath lastPathComponent] mimeType:@"multipart/form-data"];
            } else {
                [formData appendPartWithFileData:data name:@"image" fileName:[filePath lastPathComponent] mimeType:@"multipart/form-data"];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        fail(error);
    }];
}
/**
 *  下载文件
 *
 *  @param urlString  下载的RL
 *  @param filepath   下载路径
 *  @param progress   进度Block
 *  @param completion 完成Block
 http://www.cnblogs.com/qingche/p/5362592.html
 */
+ (void)downloadFileWithPath:(NSString *)urlString
                    filepath:(NSString *)filepath
                    progress:(void(^)(float progress))progress
                  completion:(void(^)(NSError *error))completion
{
    //    [SVProgressHUD showWithStatus:@"正在下载文件"];
    //    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//    DLog(@"下载文件：%@\n%@", urlString, filepath);
    [[self new] downloadFileWithFilePath:urlString filepath:filepath progress:progress completion:completion];
    
}
- (void)downloadFileWithFilePath:(NSString *)urlString
                        filepath:(NSString *)filepath
                        progress:(void(^)(float progress))progress
                      completion:(void(^)(NSError *error))completion{
    //远程地址
    NSURL *URL = [NSURL URLWithString:urlString];
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //开始下载
    //监听网络
    AFNetworkReachabilityManager*networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager startMonitoring];
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus state) {
        if(state == AFNetworkReachabilityStatusUnknown || state == AFNetworkReachabilityStatusNotReachable){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NetWork" object:nil];
            [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                [self.downLoadHistoryDictionary setObject:resumeData forKey:Host];
            }];
        }else{
            //如果本地已有下载进度则断点续传
            NSData *downLoadHistoryData = [self.downLoadHistoryDictionary   objectForKey:Host];
            if(downLoadHistoryData.length > 0){
                self.downloadTask = [manager downloadTaskWithResumeData:downLoadHistoryData progress:^(NSProgress * _Nonnull downloadProgress) {
                    progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    return [NSURL fileURLWithPath:filepath];
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    completion(error);
                }];
                [self.downloadTask resume];
            }else{
                //新下载的文件
                self.downLoadHistoryDictionary =[NSMutableDictionary dictionary];
                [self.downLoadHistoryDictionary setObject:@"" forKey:Host];
                self.downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                    // @property int64_t totalUnitCount;     需要下载文件的总大小
                    // @property int64_t completedUnitCount; 当前已经下载的大小
                    progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
                    return [NSURL fileURLWithPath:filepath];
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    //        [SVProgressHUD dismiss];
                    //设置下载完成操作
                    // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
                    completion(error);
                }];
                [self.downloadTask resume];
            }
        }
    }];
}
@end
