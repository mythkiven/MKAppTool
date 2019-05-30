/**
 *
 * Created by https://github.com/mythkiven/ on 19/05/23.
 * Copyright © 2019年 mythkiven. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface UUIDModel : NSObject

/** arch 类型
 */
@property (nonatomic, copy) NSString *arch; 
/**  默认的 Slide Address
 */
@property (nonatomic, readonly) NSString *defaultSlideAddress;
/** uuid 值
 */
@property (nonatomic, copy) NSString *uuid;
/** 可执行文件路径
 */
@property (nonatomic, copy) NSString *executableFilePath;

@end
