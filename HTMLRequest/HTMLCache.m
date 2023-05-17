//
//  HTMLCache.m
//  HTMLRequest
//
//  Created by mac on 2023/5/16.
//

#import "HTMLCache.h"

@implementation HTMLCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxCacheTime = 24 * 60 * 60;
        self.dateFormatter = [self.class dateFormatter];
    }
    return self;
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *df = [NSDateFormatter new];
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    df.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'GMT'";
    return df;
}

/// 取缓存
- (nullable NSData *)dataForRequest:(NSURLRequest *)req response:(NSURLResponse * _Nullable * _Nullable)response {
    if (![req.HTTPMethod isEqualToString:@"GET"]) {
        return nil;
    }
    
    NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:req];
    *response = cachedURLResponse.response;
    if (cachedURLResponse == nil) {
        return nil;
    }
    
    NSString *dateStr = [((NSHTTPURLResponse *)cachedURLResponse.response).allHeaderFields objectForKey:@"Date"];
    NSDate *date = [self.dateFormatter dateFromString:dateStr];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    
    if (interval < self.maxCacheTime) {
        return cachedURLResponse.data;
    } else {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:req];
        return nil;
    }
}

/// 存缓存
- (void)storeCachedResponse:(NSURLResponse *)res
                       data:(NSData *)data
                 forRequest:(NSURLRequest *)req {
    if (![req.HTTPMethod isEqualToString:@"GET"]) {
        return;
    }
    NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:res data:data];
    [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:req];
}

@end
