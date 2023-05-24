//
//  HTMLRequest.h
//  HTMLRequest
//
//  Created by mac on 2023/5/16.
//

#import <Foundation/Foundation.h>
#import <hpple/TFHpple.h>
#import "XSURLCache.h"

NS_ASSUME_NONNULL_BEGIN

/// HTML网络请求和响应
@interface HTMLRequest : NSObject

+ (instancetype)share;

@property (nonatomic) NSString *domain;         //!< 域名。例如：https://miao101.com
@property (nonatomic) XSURLCache *cache;         //!< 缓存

@property (nonatomic) BOOL cacheEnabled;        //!< 是否开启缓存，默认YES
@property (nonatomic) BOOL logEnabled;          //!< 是否开启日志，默认YES

/**
    请求
 
    @param  urlPath             例如：/video/39wcvmb5RjaXmVywLj7cFb
    @param  completion      出错时，error != nil
 */
- (void)request:(NSString *)urlPath completion:(void (^)(NSError *error, TFHpple *doc))completion;

@end

NS_ASSUME_NONNULL_END
