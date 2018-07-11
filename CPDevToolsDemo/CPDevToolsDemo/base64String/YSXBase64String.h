//
//  YSXBase64String.h
//  TestCpp
//
//  Created by apple on 15/1/28.
//
//

#import <Foundation/Foundation.h>

#define YSXAESCodeKey @"AKxNB89D3Fcgenkc"

@interface YSXBase64String : NSObject


/*!
 *  将字符串转编码为base64格式字符串
 *
 *  @param aStr 源字符串
 *
 *  @return base64格式的字符串
 */
+ (NSString *)base64String:(NSString *)aStr;

/*!
 *  将base64格式字符串解码
 *
 *  @param aStr base64格式的字符串
 *
 *  @return 解码后的字符串
 */
+ (NSString *)encodedBase64String:(NSString *)aStr;



/**
 *  AES加密
 *
 *  @param data 原数据
 *  @param key  加密key
 *
 *  @return 加密后得数据
 */
+ (NSData *)AES256ParmEncryptWithData:(NSData *)data Key:(NSString *)key;   //加密

/**
 *  AES解密
 *
 *  @param data 加密的数据
 *  @param key   解密key
 *
 *  @return 解密后得数据
 */
+ (NSData *)AES256ParmDecryptWithData:(NSData *)data Key:(NSString *)key;   //解密


@end
