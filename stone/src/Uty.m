//
// stone for iOS : Uty.m
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
#import "Uty.h"

@implementation Uty

// iOS version
- (float)getOsVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

// message dialog
- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                      tag:(int)tag
                 delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
                                                   delegate:delegate
                                          cancelButtonTitle:TEXT(@"OK")
                                          otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
}

// message dialog
- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                   doExit:(BOOL)doExit {
    doExitProcess = doExit;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:TEXT(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (doExitProcess == YES) {
        exit(1);
    }
}

// password dialog
- (void)showPasswordDialog:(NSString*)message
                     title:(NSString*)title
                       tag:(int)tag
                  delegate:(id)delegate
               defaultText:(NSString*)defaultText {
    
    [self showInputDialog:message
                    title:title
                      tag:tag
                 delegate:delegate
                   secure:YES
              defaultText:defaultText];
}

// text input dialog
- (void)showInputDialog:(NSString*)message
                  title:(NSString*)title
                    tag:(int)tag
               delegate:(id)delegate
                 secure:(BOOL)secure
            defaultText:(NSString*)defaultText {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:TEXT(@"Cancel")
                                          otherButtonTitles:TEXT(@"OK"), nil];
    alert.tag = tag;
    [alert setAlertViewStyle:
     (secure) ? UIAlertViewStyleSecureTextInput : UIAlertViewStylePlainTextInput];
    UITextField *textField = [alert textFieldAtIndex:0];
    [textField setText:defaultText];
    [alert show];
}


// query dialog
- (void)showQueryDialog:(NSString*)message
                  title:(NSString*)title
            buttonText0:(NSString*)buttonText0
            buttonText1:(NSString*)buttonText1
                    tag:(int)tag
               delegate:(id)delegate {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:buttonText0
                                          otherButtonTitles:buttonText1, nil];
    alert.tag = tag;
    [alert show];
}

// realpath of [Application Directory]/Documents
- (NSString*)getAppDocumentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

// realpath of [Application Directory]/Documents/fname
- (NSString*)createAppDocumentsFilePath:(NSString*)fname
{
    NSString *outFileName = [self getAppDocumentsPath];
    outFileName = [outFileName stringByAppendingPathComponent:fname];
    return outFileName;
}

// get directory entries
- (NSArray*)getDirEntryList:(NSString*)dir
{
    NSError *err;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *list = [fm contentsOfDirectoryAtPath:dir error:&err];
    if (!err) {
        return list;
    }
    return nil;
}

// remove [Application Directory]/Documents/Inbox/*
- (void)removeInboxFiles
{
    NSString *dir = [self getAppDocumentsPath];
    dir = [dir stringByAppendingPathComponent:@"Inbox"];
    NSArray *list = [self getDirEntryList:dir];
    for (NSString *entry in list) {
        NSString *path = [dir stringByAppendingPathComponent:entry];
        //_Log(@"removeInboxFiles file=[%@]", entry);
        unlink([path UTF8String]);
    }
}

@end
