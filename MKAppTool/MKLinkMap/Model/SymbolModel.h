/**
 *
 * Created by https://github.com/mythkiven/ on 19/05/23.
 * Copyright © 2019年 mythkiven. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SymbolModel : NSObject

/** 文件路径
 */
@property (nonatomic, copy) NSString *file;
/** 文件大小
 */
@property (nonatomic, assign) NSUInteger size;
@end


NS_ASSUME_NONNULL_END
