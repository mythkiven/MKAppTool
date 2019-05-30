/**
 *
 * Created by https://github.com/mythkiven/ on 19/05/23.
 * Copyright © 2019年 mythkiven. All rights reserved.
 *
 */


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ArchiveFileType){
    ArchiveFileTypeXCARCHIVE = 1,
    ArchiveFileTypeDSYM
};

@class UUIDModel;
@interface ArchiveModel : NSObject

/** dSYM 路径
 */
@property (copy) NSString *dSYMFilePath;
/** dSYM 文件名
 */
@property (copy) NSString *dSYMFileName;
/** archive 文件名
 */
@property (copy) NSString *archiveFileName;
/** archive 文件路径
 */
@property (copy) NSString *archiveFilePath; 
/** uuids
 */
@property (copy) NSArray<UUIDModel *> *uuidInfos;
/** 文件类型
 */
@property (assign) ArchiveFileType archiveFileType;

@end
