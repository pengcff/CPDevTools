//
//  CPNetworkMonitor.h
//  CPDevTools
//
//  Created by peng on 2017/7/11.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPHttpModel : NSObject

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *baseURL;

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSDictionary *header;

@property (nonatomic, strong) NSData *requestData;
@property (nonatomic, strong) NSData *responseData;

@property (nonatomic, copy) NSString *request;
@property (nonatomic, copy) NSString *response;


@property (nonatomic, strong) NSMutableData *tempData;

@property (nonatomic, strong) NSDate *requestStartTime;
@property (nonatomic, strong) NSDate *requestEndTime;
@property (nonatomic, strong) NSDate *responseStartTime;
@property (nonatomic, strong) NSDate *responseEndTime;

@property (nonatomic, strong) NSError *error;

@end


@interface CPHttpDecoding : NSObject

+ (NSArray <NSString *> *)regularURL;

+ (NSString *)customHttpDecodingWithRequest:(NSData *)request baseURL:(NSString *)baseURL;
+ (NSString *)customHttpDecodingWithResponse:(NSData *)response baseURL:(NSString *)baseURL;

@end



@interface CPNetworkMonitor : NSObject

@property (nonatomic, strong) NSMutableArray *httpList;

+ (instancetype)sharedMonitor;

- (void)start;

- (void)addHttpDecodeClass:(Class)decodeClass;

@end

