//
//  HTMLRequest.m
//  HTMLRequest
//
//  Created by mac on 2023/5/16.
//

#import "HTMLRequest.h"

static void IDLog(NSString *format, ...) {
    if (HTMLRequest.share.logEnabled == NO) return;
    va_list ap;
    va_start(ap, format);
    NSLogv(format, ap);
    va_end(ap);
}


@implementation HTMLRequest

+ (instancetype)share {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheEnabled = YES;
        self.logEnabled = YES;
        self.cache = XSURLCache.share;
    }
    return self;
}

- (void)request:(NSString *)urlPath completion:(void (^)(NSError *error, TFHpple *doc))completion {
    NSString *urlString = nil;
    if ([urlPath hasPrefix:@"http"]) {
        urlString = urlPath;
    } else {
        if (urlPath == nil) urlPath = @"";
        urlString = [self.domain stringByAppendingString:urlPath];
    }
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    req.cacheDuration = 24 * 60 * 60;           //  24小时
    
    if (self.cacheEnabled) {
        //  取缓存
        NSURLResponse *response = nil;
        NSData *data = [self.cache dataForRequest:req response:&response];
        if (data) {
            IDLog(@">>> 缓存: %@", url);
            TFHpple *doc = [TFHpple hppleWithHTMLData:data];
            if (completion) completion(nil, doc);
            return;
        }
    }
    
    IDLog(@">>> 请求: %@", url);
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        IDLog(@">>> 响应: %@\n%@", ((NSHTTPURLResponse *)response).URL, content);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (completion) completion(error, nil);
                return;
            }
            
            //
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            if (res.statusCode != 200) {
                NSString *des = [NSHTTPURLResponse localizedStringForStatusCode:res.statusCode];
                NSError *err = [NSError errorWithDomain:self.domain code:res.statusCode userInfo:@{NSLocalizedDescriptionKey: des}];
                if (completion) completion(err, nil);
                return;
            }
            
            if (self.cacheEnabled) {
                //  存缓存
                [self.cache storeCachedResponse:response data:data forRequest:req];
            }
            
            //
            TFHpple *doc = [TFHpple hppleWithHTMLData:data];
            if (completion) completion(nil, doc);
        });
    }];
    [task resume];
}

@end
