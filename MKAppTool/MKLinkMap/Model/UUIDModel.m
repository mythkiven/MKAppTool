/**
 *
 * Created by https://github.com/mythkiven/ on 19/05/23.
 * Copyright © 2019年 mythkiven. All rights reserved.
 *
 */

#import "UUIDModel.h"

@interface UUIDModel() 
/** 默认的 Slide Address
 */
@property (nonatomic, readwrite) NSString *defaultSlideAddress;

@end

@implementation UUIDModel

- (void)setArch:(NSString *)arch {
    _arch = arch;
    if([arch isEqualToString:@"arm64"]){
        _defaultSlideAddress = @"0x0000000100000000";
    }else if([arch isEqualToString:@"armv7"]){
        _defaultSlideAddress = @"0x00004000";
    }else{
        _defaultSlideAddress = @"";
    }
}

@end
