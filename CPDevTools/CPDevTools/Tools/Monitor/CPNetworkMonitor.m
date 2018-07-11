//
//  CPNetworkMonitor.m
//  CPDevTools
//
//  Created by peng on 2017/7/11.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPNetworkMonitor.h"
#import <objc/runtime.h>

@interface CPHttpProtocol : NSURLProtocol @end

@implementation NSURLSession (CP_Swizzle)

+ (NSURLSession *)CP_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue{
    
    NSMutableArray * urlProtocolClasses = [NSMutableArray arrayWithArray:configuration.protocolClasses];
    [urlProtocolClasses insertObject:[CPHttpProtocol class] atIndex:0];
    configuration.protocolClasses = urlProtocolClasses;
    
    return [self CP_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

@end


@implementation NSURLRequest (CP_Swizzle)

- (NSData *)CP_HTTPBody {
    
    return [NSURLProtocol propertyForKey:@"HTTPBody" inRequest:self];
}

@end

typedef void(*CPHTTPBodySetter)(id, SEL, id);
static CPHTTPBodySetter ori_HTTPBody_Setter;
static void CP_HTTPBody_IMP(id self, SEL _cmd, NSData* HTTPBody) {
    
    if (HTTPBody) {
        [NSURLProtocol setProperty:HTTPBody forKey:@"HTTPBody" inRequest:self];
    }
    
    ori_HTTPBody_Setter(self, _cmd, HTTPBody);
}

@interface CPNetworkMonitor ()

@property (nonatomic, strong) Class decodeClass;

@end

@implementation CPNetworkMonitor

static CPNetworkMonitor *_sharedMonitor;
+ (instancetype)sharedMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMonitor = [[self alloc] init];
    });
    return _sharedMonitor;
}

- (void)start {
    
    Method oriSessionMethod = class_getClassMethod([NSURLSession class], @selector(sessionWithConfiguration:delegate:delegateQueue:));
    Method mySessionMethod = class_getClassMethod([NSURLSession class], @selector(CP_sessionWithConfiguration:delegate:delegateQueue:));
    
    method_exchangeImplementations(oriSessionMethod, mySessionMethod);
    
    
    Method oriHTTPBodyMethod = class_getInstanceMethod([NSMutableURLRequest class], @selector(setHTTPBody:));
    ori_HTTPBody_Setter = (CPHTTPBodySetter)method_getImplementation(oriHTTPBodyMethod);
    
    method_setImplementation(oriHTTPBodyMethod, (IMP)CP_HTTPBody_IMP);
}

- (NSMutableArray *)httpList {
    if (_httpList == nil) {
        _httpList = [NSMutableArray array];
    }
    return _httpList;
}

- (void)addHttpDecodeClass:(Class)decodeClass {
    self.decodeClass = decodeClass;
}

@end


@implementation CPHttpDecoding

+ (NSArray <NSString *> *)regularURL {
    return nil;
};

+ (NSString *)customHttpDecodingWithRequest:(NSData *)request baseURL:(NSString *)baseURL {
    return nil;
}
+ (NSString *)customHttpDecodingWithResponse:(NSData *)response baseURL:(NSString *)baseURL {
    return nil;
}

@end

@implementation CPHttpModel

- (NSMutableData *)tempData {
    if (_tempData == nil) {
        _tempData = [[NSMutableData alloc] init];
    }
    return _tempData;
}

- (void)setURL:(NSString *)URL {
    _URL = URL;
}

- (void)setRequestData:(NSData *)requestData {
    
    _requestData = requestData;
    
    if (requestData) {
        NSError *error;
        NSDictionary *requestDic = [NSJSONSerialization JSONObjectWithData:_requestData
                                                                   options:NSJSONReadingAllowFragments error:&error];
        if (error != nil) {
            _request = [[NSString alloc] initWithData:_requestData encoding:NSUTF8StringEncoding];
            _request = [_request stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }else {
            _request = [requestDic description];
        }
    }
}

- (void)setResponseData:(NSData *)responseData {
    
    _responseData = responseData;
    _response = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    if (_responseData) {
        NSError *error;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:_responseData
                                                                options:NSJSONReadingAllowFragments error:&error];
        if (error != nil) {
            _response = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
        }else {
            _response = [responseDic description];
        }
    }
}

@end


//为了避免 canInitWithRequest 和 canonicalRequestForRequest 出现死循环
static NSString * const HJHTTPHandledIdentifier = @"HJHTTPHandledIdentifier";

@interface CPHttpProtocol ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) CPHttpModel          *httpModel;

@end

@implementation CPHttpProtocol

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

//是否处理对应的request
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:HJHTTPHandledIdentifier inRequest:request] ) {
        return NO;
    }
    return YES;
}

//是否处理request
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:HJHTTPHandledIdentifier
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

//开始加载
- (void)startLoading {
    
    NSURLSessionConfiguration *configuration              = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionDelegateQueue                             = [[NSOperationQueue alloc] init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name                        = @"com.CPNetworkMonitor.session.queue";
    NSURLSession *session                                 = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.sessionDelegateQueue];
    self.dataTask                                         = [session dataTaskWithRequest:self.request];
    [self.dataTask resume];
    
    self.httpModel = [[CPHttpModel alloc] init];
    self.httpModel.requestStartTime = [NSDate date];
    
}

//取消加载
- (void)stopLoading {
    
    // 解析 response，流量统计等
    NSURLRequest *request = self.dataTask.currentRequest;
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.dataTask.response;
    
    self.httpModel.URL = request.URL.absoluteString;
    self.httpModel.baseURL = [NSString stringWithFormat:@"%@://%@",request.URL.scheme,request.URL.host];
    
    self.httpModel.statusCode = response.statusCode;
    self.httpModel.header = response.allHeaderFields;
    
    self.httpModel.requestData  = [request CP_HTTPBody];
    self.httpModel.responseData = [self.httpModel.tempData copy];
    
    self.httpModel.responseEndTime = [NSDate date];
    
    
    Class decodeClass = [CPNetworkMonitor sharedMonitor].decodeClass;
    if (decodeClass) {
        
        NSString *request = [decodeClass customHttpDecodingWithRequest:self.httpModel.requestData
                                                               baseURL:self.httpModel.baseURL];
        self.httpModel.request = request ? request : self.httpModel.request;
        
        NSString *response = [decodeClass customHttpDecodingWithResponse:self.httpModel.responseData
                                                                 baseURL:self.httpModel.baseURL];
        self.httpModel.response = response ? response : self.httpModel.response;
    }
    
    [[CPNetworkMonitor sharedMonitor].httpList insertObject:self.httpModel atIndex:0];
    
    [self.dataTask cancel];
    self.dataTask = nil;
}

#pragma mark - NSURLSessionTaskDelegate

// 3.请求成功或者失败（如果失败，error有值）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.httpModel.error = error;
}

// 发送的body
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t )totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    self.httpModel.requestEndTime = [NSDate date];
}

#pragma mark - NSURLSessionDataDelegate

// 1.接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
    
    self.httpModel.requestEndTime = self.httpModel.requestEndTime ? self.httpModel.requestEndTime : [NSDate date];
    self.httpModel.responseStartTime = [NSDate date];
}

// 2.接收到服务器的数据（可能调用多次）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [self.client URLProtocol:self didLoadData:data];
    
    [self.httpModel.tempData appendData:data];
}


@end

