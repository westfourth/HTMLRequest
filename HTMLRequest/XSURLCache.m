//
//  XSURLCache.m
//  HTMLRequest
//
//  Created by mac on 2023/5/16.
//

#import "XSURLCache.h"
#import <objc/runtime.h>

NSString *const XSURLCacheResponseDate = @"Response-Date";

@implementation XSURLCache

+ (instancetype)share {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *df = [NSDateFormatter new];
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    df.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'GMT'";
    return df;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [XSURLCache dateFormatter];
    }
    return self;
}

/// 取缓存
- (nullable NSData *)dataForRequest:(NSURLRequest *)req
                           response:(NSURLResponse * _Nullable * _Nullable)response {
    if (![req.HTTPMethod isEqualToString:@"GET"]) {
        return nil;
    }
    
    //  响应
    NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:req];
    *response = cachedURLResponse.response;
    if (cachedURLResponse == nil) {
        return nil;
    }
    
    //  时间
    NSDictionary *userInfo = cachedURLResponse.userInfo;
    NSString *responseDateString = userInfo[XSURLCacheResponseDate];
    NSDate *date = [self.dateFormatter dateFromString:responseDateString];
    if (date == nil) {
        return nil;
    }
    
    //  超时
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    if (interval > req.cacheDuration) {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:req];
        return nil;
    }
    
    return cachedURLResponse.data;
}

/// 存缓存
- (void)storeCachedResponse:(NSURLResponse *)res
                       data:(NSData *)data
                 forRequest:(NSURLRequest *)req {
    if (![req.HTTPMethod isEqualToString:@"GET"]) {
        return;
    }
    
    if (res == nil || data.length == 0) {
        return;
    }
    
    NSString *responseDateString = [self.dateFormatter stringFromDate:[NSDate date]];
    NSDictionary *userInfo = @{XSURLCacheResponseDate: responseDateString};
    NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:res data:data userInfo:userInfo storagePolicy:NSURLCacheStorageAllowed];
    [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:req];
}

@end



@implementation NSURLRequest (XSURLCache)

- (NSTimeInterval)cacheDuration {
    return [objc_getAssociatedObject(self, @selector(cacheDuration)) doubleValue];
}

- (void)setCacheDuration:(NSTimeInterval)cacheDuration {
    objc_setAssociatedObject(self, @selector(cacheDuration), @(cacheDuration), OBJC_ASSOCIATION_ASSIGN);
}

@end
