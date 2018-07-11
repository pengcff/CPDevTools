//
//  DSKHttpDecoding.m
//  CPDevTools
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DSKHttpDecoding.h"
//#import "YSXBase64String.h"

@implementation NSDictionary (MyLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    
    NSMutableString *mStr = [NSMutableString string];
    NSMutableString *tab = [NSMutableString stringWithString:@""];
    for (int i = 0; i < level; i++) {
        [tab appendString:@"\t"];
    }
    [mStr appendString:@"{\n"];
    NSArray *allKey = self.allKeys;
    for (int i = 0; i < allKey.count; i++) {
        id value = self[allKey[i]];
        NSString *lastSymbol = (allKey.count == i + 1) ? @"":@";";
        if ([value respondsToSelector:@selector(descriptionWithLocale:indent:)]) {
            [mStr appendFormat:@"\t%@%@ = %@%@\n",tab,allKey[i],[value descriptionWithLocale:locale indent:level + 1],lastSymbol];
        } else {
            [mStr appendFormat:@"\t%@%@ = %@%@\n",tab,allKey[i],value,lastSymbol];
        }
    }
    [mStr appendFormat:@"%@}",tab];
    return mStr;
}

@end

@implementation DSKHttpDecoding

#if 0
+ (NSArray <NSString *> *)regularURL {
    
    return @[YSX_server_url,
             YSX_kill_server_url,
             @"http://116.204.15.166",
             @"http://test.gamevideoshow.com"];
}

+ (NSString *)customHttpDecodingWithRequest:(NSData *)request
                                    baseURL:(NSString *)baseURL {
    
    if ([[DSKHttpDecoding regularURL] containsObject:baseURL] == NO) {
        return nil;
    }
    
    NSString *decodeRequest;
    NSString *requestInfo = [[NSString alloc] initWithData:request encoding:NSUTF8StringEncoding];
    
    NSString *result = [requestInfo stringByReplacingOccurrencesOfString:@"encrypt=" withString:@""];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (result) {
        
        NSData *AESCodeData = [[NSData  alloc] initWithBase64EncodedString:result
                                                                   options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData *unCodeData = [YSXBase64String AES256ParmDecryptWithData:AESCodeData Key:YSXAESCodeKey];
        
        decodeRequest =  [[NSJSONSerialization JSONObjectWithData:unCodeData options:NSJSONReadingAllowFragments error:nil] description];
    }
    
    return decodeRequest;
}

+ (NSString *)customHttpDecodingWithResponse:(NSData *)response
                                     baseURL:(NSString *)baseURL {
    
    if ([[DSKHttpDecoding regularURL] containsObject:baseURL] == NO) {
        return nil;
    }
    
    NSString *decodeResponse;
    NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:response
                                                                 options:NSJSONReadingAllowFragments error:nil];
    NSString *result = responseInfo[@"result"];
    
    if (result) {
        
        NSData *AESCodeData = [[NSData  alloc] initWithBase64EncodedData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData *unCodeData = [YSXBase64String AES256ParmDecryptWithData:AESCodeData Key:YSXAESCodeKey];
        
        decodeResponse = [[NSJSONSerialization JSONObjectWithData:unCodeData options:NSJSONReadingAllowFragments error:nil] descriptionWithLocale:[NSLocale currentLocale]];
    }
    
    return decodeResponse;
}
#endif

@end
