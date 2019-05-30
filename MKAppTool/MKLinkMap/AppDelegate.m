/**
 *
 * Created by https://github.com/mythkiven/ on 19/05/23.
 * Copyright © 2019年 mythkiven. All rights reserved.
 *
 */

#import "AppDelegate.h"
#import "MKLinkMapVC.h"
#import "MKDSYMVC.h"
@interface AppDelegate ()
@property (strong) MKLinkMapVC *mkLinkMapVC;
@property (strong) MKDSYMVC *MKDSYMVC;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.mkLinkMapVC = [[MKLinkMapVC alloc] initWithWindowNibName:@"MKLinkMapVC"];
    [self.mkLinkMapVC showWindow:self]; 
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
