/**
 *
 * Created by https://github.com/mythkiven/ on 19/05/23.
 * Copyright © 2019年 mythkiven. All rights reserved.
 *
 */

#import "MKDSYMVC.h"
#import "AboutVC.h"
#import "ArchiveModel.h"
#import "UUIDModel.h"


@interface MKDSYMVC ()<NSTableViewDelegate, NSTableViewDataSource, NSDraggingDestination>


@property (weak) IBOutlet NSTableView *archiveFilesTableView;
@property (weak) IBOutlet NSBox *radioBox;

@property (copy) NSMutableArray<ArchiveModel *> *archiveFilesInfo;
@property (strong) ArchiveModel *selectedArchiveModel;
@property (strong) UUIDModel *selectedUUIDModel;

@property (weak) IBOutlet NSTextField *selectedUUIDLabel;
@property (weak) IBOutlet NSTextField *defaultSlideAddressLabel;
@property (weak) IBOutlet NSTextField *errorMemoryAddressLabel;
@property (unsafe_unretained) IBOutlet NSTextView *errorMessageView; 

@end

@implementation MKDSYMVC


- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window registerForDraggedTypes:@[NSColorPboardType, NSFilenamesPboardType]];
    [self.window makeKeyWindow];
    [self.window resignMainWindow];
    [self.window makeMainWindow];
    self.archiveFilesTableView.doubleAction = @selector(doubleActionMethod);
    NSArray *archiveFilePaths = [self allDSYMFilePath];
    [self handleArchiveFileWithPath:archiveFilePaths];
}




#pragma mark -  导出
- (IBAction)exportIPA:(id)sender {
    if(!_selectedArchiveModel){
        [self alert:@"还未选中 archive 文件"];
        return;
    }
    if(_selectedArchiveModel.archiveFileType == ArchiveFileTypeDSYM){
        [self alert:@"archive 文件才可导出 ipa 文件"];
        return;
    }
    NSString *ipaFileName = [_selectedArchiveModel.archiveFileName stringByReplacingOccurrencesOfString:@"xcarchive" withString:@"ipa"];
    NSSavePanel *saveDlg = [[NSSavePanel alloc]init];
    saveDlg.title = ipaFileName;
    saveDlg.message = @"Save My File";
    saveDlg.allowedFileTypes = @[@"ipa"];
    saveDlg.nameFieldStringValue = ipaFileName;
    [saveDlg beginWithCompletionHandler: ^(NSInteger result){
        if(result == NSFileHandlingPanelOKButton){
            NSURL  *url =[saveDlg URL];
            NSLog(@"filePath url%@",url);
            NSString *exportCmd = [NSString stringWithFormat:@"/usr/bin/xcodebuild -exportArchive -exportFormat ipa -archivePath \"%@\" -exportPath \"%@\"", _selectedArchiveModel.archiveFilePath, url.relativePath];
            [self runCommand:exportCmd];
        }
    }];
}

- (IBAction)aboutMe:(id)sender {
    __block AboutVC *about = [[AboutVC alloc] initWithWindowNibName:@"AboutVC"];
    [self.window beginSheet:about.window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSModalResponseOK:
                NSLog(@"Done button tapped in Custom Sheet");
                break;
            case NSModalResponseCancel:
                NSLog(@"Cancel button tapped in Custom Sheet");
                break;
                
            default:
                break;
        }
        about = nil;
    }];
}

#pragma mark - tableView
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_archiveFilesInfo count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ArchiveModel *ArchiveModel= _archiveFilesInfo[row];
    if(ArchiveModel.archiveFileType == ArchiveFileTypeXCARCHIVE){
        return ArchiveModel.archiveFileName;
    }else if(ArchiveModel.archiveFileType == ArchiveFileTypeDSYM){
        return ArchiveModel.dSYMFileName;
    }
    return ArchiveModel.archiveFileName;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ArchiveModel *ArchiveModel= _archiveFilesInfo[row];
    NSString *identifier = tableColumn.identifier;
    NSView *view = [tableView makeViewWithIdentifier:identifier owner:self];
    NSArray *subviews = view.subviews;
    if (subviews.count > 0) {
        if ([identifier isEqualToString:@"name"]) {
            NSTextField *textField = subviews[0];
            if(ArchiveModel.archiveFileType == ArchiveFileTypeXCARCHIVE){
                textField.stringValue = ArchiveModel.archiveFileName;
            }else if(ArchiveModel.archiveFileType == ArchiveFileTypeDSYM){
                textField.stringValue = ArchiveModel.dSYMFileName;
            }
        }
    }
    return view;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [notification.object selectedRow];
    _selectedArchiveModel= _archiveFilesInfo[row];
    [self resetPreInformation];

    CGFloat radioButtonWidth = CGRectGetWidth(self.radioBox.contentView.frame);
    CGFloat radioButtonHeight = 18;
    [_selectedArchiveModel.uuidInfos enumerateObjectsUsingBlock:^(UUIDModel *uuidInfo, NSUInteger idx, BOOL *stop) {
        CGFloat space = (CGRectGetHeight(self.radioBox.contentView.frame) - _selectedArchiveModel.uuidInfos.count * radioButtonHeight) / (_selectedArchiveModel.uuidInfos.count + 1);
        CGFloat y = space * (idx + 1) + idx * radioButtonHeight;
        NSButton *radioButton = [[NSButton alloc] initWithFrame:NSMakeRect(10,y,radioButtonWidth,radioButtonHeight)];
        [radioButton setButtonType:NSRadioButton];
        [radioButton setTitle:uuidInfo.arch];
        radioButton.tag = idx + 1;
        [radioButton setAction:@selector(radioButtonAction:)];
        [self.radioBox.contentView addSubview:radioButton];
    }];
}
- (void)resetPreInformation {
    [self.radioBox.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _selectedUUIDModel = nil;
    self.selectedUUIDLabel.stringValue = @"";
    self.defaultSlideAddressLabel.stringValue = @"";
    self.errorMemoryAddressLabel.stringValue = @"";
    [self.errorMessageView setString:@""];
}
- (void)radioButtonAction:(id)sender {
    NSButton *radioButton = sender;
    NSInteger tag = radioButton.tag;
    _selectedUUIDModel = _selectedArchiveModel.uuidInfos[tag - 1];
    _selectedUUIDLabel.stringValue = _selectedUUIDModel.uuid;
    _defaultSlideAddressLabel.stringValue = _selectedUUIDModel.defaultSlideAddress;
}



#pragma mark - 分析
- (IBAction)analyse:(id)sender {
    if(self.selectedArchiveModel == nil){
        [self alert:@"未选择分析的文件"];
        return;
    }
    if(self.selectedUUIDModel == nil){
        [self alert:@"未选择UUID"];
        return;
    }
    if([self.defaultSlideAddressLabel.stringValue isEqualToString:@""]){
        [self alert:@"未选择 slideAddress"];
        return;
    }
    if([self.errorMemoryAddressLabel.stringValue isEqualToString:@""]){
        [self alert:@"未选择错误的内存地址"];
        return;
    } 
    NSString *commandString = [NSString stringWithFormat:@"xcrun atos -arch %@ -o \"%@\" -l %@ %@", self.selectedUUIDModel.arch, self.selectedUUIDModel.executableFilePath, self.defaultSlideAddressLabel.stringValue, self.errorMemoryAddressLabel.stringValue];
    NSString *result = [self runCommand:commandString];
    [self.errorMessageView setString:result];
}
- (NSString *)runCommand:(NSString *)commandToRun {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    NSArray *arguments = @[@"-c", [NSString stringWithFormat:@"%@", commandToRun]];
    [task setArguments:arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}
//支持 xcarchive 文件和 dSYM 文件
- (void)handleArchiveFileWithPath:(NSArray *)filePaths {
    _archiveFilesInfo = [NSMutableArray arrayWithCapacity:1];
    for(NSString *filePath in filePaths){
        ArchiveModel *archiveModel = [[ArchiveModel alloc] init];
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".xcarchive"]){
            archiveModel.archiveFilePath = filePath;
            archiveModel.archiveFileName = fileName;
            archiveModel.archiveFileType = ArchiveFileTypeXCARCHIVE;
            [self formatArchiveModel:archiveModel];
        }else if([fileName hasSuffix:@".app.dSYM"]){
            archiveModel.dSYMFilePath = filePath;
            archiveModel.dSYMFileName = fileName;
            archiveModel.archiveFileType = ArchiveFileTypeDSYM;
            [self formatDSYM:archiveModel];
        }else{
            continue;
        }
        [_archiveFilesInfo addObject:archiveModel];
    }
    [self.archiveFilesTableView reloadData];
}
//从 archive 文件中获取 dsym 文件信息
- (void)formatArchiveModel:(ArchiveModel *)ArchiveModel {
    NSString *dSYMsDirectoryPath = [NSString stringWithFormat:@"%@/dSYMs", ArchiveModel.archiveFilePath];
    NSArray *keys = @[@"NSURLPathKey",@"NSURLFileResourceTypeKey",@"NSURLIsDirectoryKey",@"NSURLIsPackageKey"];
    NSArray *dSYMSubFiles= [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:dSYMsDirectoryPath] includingPropertiesForKeys:keys options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants) error:nil];
    for(NSURL *fileURLs in dSYMSubFiles){
        if ([[fileURLs.relativePath lastPathComponent] hasSuffix:@"app.dSYM"]){
            ArchiveModel.dSYMFilePath = fileURLs.relativePath;
            ArchiveModel.dSYMFileName = fileURLs.relativePath.lastPathComponent;
        }
    }
    [self formatDSYM:ArchiveModel];
}
//根据 dSYM 文件获取 UUIDS。
- (void)formatDSYM:(ArchiveModel *)ArchiveModel {
    NSString *pattern = @"(?<=\\()[^}]*(?=\\))";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSString *commandString = [NSString stringWithFormat:@"dwarfdump --uuid \"%@\"",ArchiveModel.dSYMFilePath];
    NSString *uuidsString = [self runCommand:commandString];
    NSArray *uuids = [uuidsString componentsSeparatedByString:@"\n"];
    NSMutableArray *uuidInfos = [NSMutableArray arrayWithCapacity:1];
    for(NSString *uuidString in uuids){
        NSArray* match = [reg matchesInString:uuidString options:NSMatchingReportCompletion range:NSMakeRange(0, [uuidString length])];
        if (match.count == 0) {
            continue;
        }
        for (NSTextCheckingResult *result in match) {
            NSRange range = [result range];
            UUIDModel *uuidInfo = [[UUIDModel alloc] init];
            uuidInfo.arch = [uuidString substringWithRange:range];
            uuidInfo.uuid = [uuidString substringWithRange:NSMakeRange(6, range.location-6-2)];
            uuidInfo.executableFilePath = [uuidString substringWithRange:NSMakeRange(range.location+range.length+2, [uuidString length]-(range.location+range.length+2))];
            [uuidInfos addObject:uuidInfo];
        }
        ArchiveModel.uuidInfos = uuidInfos;
    }
}
//dSYM 文件目录.
- (NSMutableArray *)allDSYMFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *archivesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Developer/Xcode/Archives/"];
    NSURL *bundleURL = [NSURL fileURLWithPath:archivesPath];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:bundleURL
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             return YES;
                                         }];
    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        if ([filename hasSuffix:@".xcarchive"] && [isDirectory boolValue]){
            [mutableFileURLs addObject:fileURL.relativePath];
            [enumerator skipDescendants];
        }
    }
    return mutableFileURLs;
}
#pragma mark - drag

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}
- (void)draggingExited:(id<NSDraggingInfo>)sender {

}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSURLPboardType] ) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        NSLog(@"%@",fileURL);
    }
    if([[pboard types] containsObject:NSFilenamesPboardType]){
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSMutableArray *archiveFilePaths = [NSMutableArray arrayWithCapacity:1];
        for(NSString *filePath in files){
            if([filePath.pathExtension isEqualToString:@"xcarchive"]){
                NSLog(@"%@", filePath);
                [archiveFilePaths addObject:filePath];
            }
            if([filePath.pathExtension isEqualToString:@"dSYM"]){
                [archiveFilePaths addObject:filePath];
            }
        }
        if(archiveFilePaths.count == 0){
            NSLog(@"没有包含任何 xcarchive 文件");
            return NO;
        }
        [self resetPreInformation];
        [self handleArchiveFileWithPath:archiveFilePaths];
    }
    return YES;
}

#pragma mark -
- (void)doubleActionMethod {
    NSLog(@"double action");
}
- (void)alert:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = text;
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].windows[1] completionHandler:^(NSModalResponse returnCode) {
        }];
    });
}
@end
