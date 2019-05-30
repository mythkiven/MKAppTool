/**
 *
 * Created by https://github.com/mythkiven/ on 19/05/23.
 * Copyright © 2019年 mythkiven. All rights reserved.
 *
 */

#import "AboutVC.h"

@interface AboutVC ()
@property (weak) IBOutlet NSTextField *blog;
@property (weak) IBOutlet NSTextField *gitHub;
@end

@implementation AboutVC

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.blog setAllowsEditingTextAttributes:YES];
    [self.blog setSelectable:YES];
    [self.gitHub setAllowsEditingTextAttributes:YES];
    [self.gitHub setSelectable:YES];
    NSMutableAttributedString* string1 = [[NSMutableAttributedString alloc] init];
    [string1 appendAttributedString: [self linkFromString:@"http://3code.info/" withURL:[NSURL URLWithString:@"http://3code.info/"]]];
    [self.blog setAttributedStringValue: string1];
    NSMutableAttributedString* string2 = [[NSMutableAttributedString alloc] init];
    [string2 appendAttributedString: [self linkFromString:@"MKAppTool" withURL:[NSURL URLWithString:@"https://github.com/mythkiven/mkBox"]]];
    [self.gitHub setAttributedStringValue: string2];
}
- (IBAction)close:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (id)linkFromString:(NSString*)inString withURL:(NSURL*)aURL {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
    [attrString endEditing];
    return attrString;
}

@end
