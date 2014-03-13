//
// stone for iOS : AppDelegate.m
//
// Copyright (c) 2014 KLab Inc. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GNU Emacs; see the file COPYING.  If not, write to
// the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
//

#import "Common.h"
#import "AppDelegate.h"
#import "ViewControllerMain.h"
#import "ViewControllerImport.h"
#import "Setting.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    _Log(@"handleOpenURL");
    // show file save dialog (app process is in the background state)
    NSString *storyboardId = @"ViewControllerImport";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Import" bundle:nil];
    self.viewControllerImport = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    [self.viewControllerImport notifyURL:[url absoluteString]];
    
    self.viewControllerMain.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.viewControllerImport.view.backgroundColor = [UIColor clearColor];
    
    [self.viewControllerMain presentViewController: self.viewControllerImport
                                          animated: YES
                                        completion: nil];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _Log(@"didFinishLaunchingWithOptions");
    // app is launched from the icon on the homescreen
    // - show Main View
    if (launchOptions == nil) {
        NSString *storyboardId = @"ViewControllerMain";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.viewControllerMain = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
        UINavigationController *naviCon = [[UINavigationController alloc] initWithRootViewController:self.viewControllerMain];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = naviCon;//self.viewControllerMain;
        [self.window makeKeyAndVisible];
    }
    // started by file extension association
    // - show file save dialog
    else {
        NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        NSString *storyboardId = @"ViewControllerImport";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Import" bundle:nil];
        self.viewControllerImport = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
        [self.viewControllerImport notifyURL:[url absoluteString]];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = self.viewControllerImport;
        [self.window makeKeyAndVisible];
        return NO; // avoid to call handleOpenURL()
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    _Log(@"didReceiveLocalNotification");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    _Log(@"applicationWillResignActive");
}

- (void)localNotification
{
    Setting *setting = [[Setting alloc] init];
    if (![setting getTimeoutNotificatinStatus]) {
        return;
    }
    UILocalNotification *notify = [[UILocalNotification alloc] init];
    if (notify == nil) {
        return;
    }
    notify.fireDate = nil;
    notify.timeZone = [NSTimeZone defaultTimeZone];
    notify.alertBody = TEXT(@"TapToActivateStone");
    notify.alertAction = TEXT(@"Open");
    notify.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary* dic = [NSDictionary dictionaryWithObject:@"RECIEVE" forKey:@"STONE_NOTIFICATION"];
    notify.userInfo = dic;
    [[UIApplication sharedApplication] scheduleLocalNotification:notify];
}

- (void)applicationDidEnterBackground:(UIApplication *)app
{
    _Log(@"applicationDidEnterBackground");
    bgtask = [app beginBackgroundTaskWithExpirationHandler: ^{
        [self localNotification];
        _Log(@"** bgtask[%u] is expired **", bgtask);
        [app endBackgroundTask:bgtask];
        bgtask = UIBackgroundTaskInvalid;
    }];
   
    dispatch_queue_t globalQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQ, ^{
        time_t prevTime = 0;
        sigset_t sigset;
        int sts, signo;
        sigemptyset(&sigset);
        sts = sigaddset(&sigset, SIGWINCH);
        if (sts != 0) {
            //_Log(@"failed to sigaddset, ret=%d", sts);
            return;
        }
        sts = sigprocmask(SIG_BLOCK, &sigset, NULL);
        if (sts != 0) {
            //_Log(@"failed to sigprocmask, ret=%d", sts);
            return;
        }
        for (;;) {
            if (sigwait(&sigset, &signo) == 0) {
                //_Log(@"DETECTED");
                prevTime = time(NULL);
            }
        }
        [app endBackgroundTask:bgtask];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _Log(@"applicationWillEnterForeground");
    
    if (bgtask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:bgtask];
        bgtask = UIBackgroundTaskInvalid;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _Log(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    _Log(@"applicationWillTerminate");
}

@end
