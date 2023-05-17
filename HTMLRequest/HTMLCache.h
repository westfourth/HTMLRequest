//
//  HTMLCache.h
//  HTMLRequest
//
//  Created by mac on 2023/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// HTML缓存
@interface HTMLCache : NSObject

@property (nonatomic) NSDateFormatter *dateFormatter;

/// 最大缓存时长，超过该时长就会从缓存中移除。默认1天
@property (nonatomic) NSTimeInterval maxCacheTime;

/**
    取缓存
 
    1. 不存在，返回nil
    2. 没有超过最大缓存时长，返回data
    3. 超过最大缓存时长，移除缓存，返回nil
 */
- (nullable NSData *)dataForRequest:(NSURLRequest *)req response:(NSURLResponse * _Nullable * _Nullable)response;

/// 存缓存
- (void)storeCachedResponse:(NSURLResponse *)res
                       data:(NSData *)data
                 forRequest:(NSURLRequest *)req;

@end

NS_ASSUME_NONNULL_END
