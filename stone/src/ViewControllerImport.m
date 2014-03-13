//
// stone for iOS : ViewControllerImport.m
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
#import "ViewControllerImport.h"
#import "Uty.h"

#define ALERTVIEW_FILENAME        0
#define ALERTVIEW_QUERYOVERWRITE  1
#define ALERTVIEW_NOFILENAME      2
#define ALERTVIEW_SAVEERROR       3
#define ALERTVIEW_SAVEDONE        4

@interface ViewControllerImport ()

@end

@implementation ViewControllerImport

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (uty == nil) {
        uty = [[Uty alloc] init];
    }
    [self showFileNameDialog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)notifyURL:(NSString*)urlString
{
    dataURL = [[NSURL alloc] initWithString:urlString];
    // get file name from full path
    NSString *fname = [urlString lastPathComponent];
    // get extension from file name（the dot is not included）
    NSString *ext = [fname pathExtension];
    int extlen = (int)ext.length;
    if (extlen > 0) {
        int len = (int)fname.length;
        // omit ".stone"
        if ([ext caseInsensitiveCompare:EXT_STONEDATA] == NSOrderedSame) {
            fname = [fname substringToIndex:len-EXT_STONEDATA_LEN-1];
            len = (int)fname.length;
            // get the real extension"
            ext = [fname pathExtension];
            extlen = (int)ext.length;
        }
        if (extlen > 0) {
            char *str = strdup([ext UTF8String]);
            if (str) {
                // fix "stone.cnf-13" to "stone.cnf"
                char *p = strrchr(str, '-');
                if (p) {
                    int n = atoi(p+1);
                    if (n > 0) {
                        *p = '\0';
                        int gap = (int)(extlen - strlen(str));
                        fname = [fname substringToIndex:len - gap];
                    }
                }
                free(str);
            }
        }
    }
    outFileName = [[NSString alloc] initWithString:fname];
}

- (void)showFileNameDialog
{
    [uty showInputDialog:TEXT(@"SaveAsLocalFile")
                   title:APP_NAME
                     tag:ALERTVIEW_FILENAME
                delegate:self
                  secure:NO
             defaultText:outFileName];
}

// save a file
- (BOOL)saveIt:(NSURL*)srcURL dstFileName:(NSString*)dstFileName
{
    NSData *fileData = [NSData dataWithContentsOfURL:srcURL];
    BOOL sts = [fileData writeToFile:dstFileName atomically:YES];
    return sts;
}

// close this viewController
- (void)closeMe
{
    // delete [Application Directory]/Documents/Inbox/*
    [uty removeInboxFiles];
    // launched as a modal view?
    if ([self presentingViewController] != nil) {
        // return control to parent ViewController
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        exit(0);
    }
}

// alertView delagate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERTVIEW_FILENAME) {
        if (buttonIndex == 1) { // OK
            // get specified file name
            NSString *fname  = [[alertView textFieldAtIndex:0] text];
            // blank
            if ([fname length] <= 0) {
                [uty showMessageDialog:TEXT(@"SpecifyFileName")
                                 title:APP_NAME
                                   tag:ALERTVIEW_NOFILENAME
                              delegate:self];
                return;
            }
            outFileName = fname;
            NSString *saveFileName = [uty createAppDocumentsFilePath:outFileName];
            // duplication check
            FILE *fp = fopen([saveFileName UTF8String], "r");
            if (fp) {
                fclose(fp);
                [uty showQueryDialog:TEXT(@"QueryOverwriteFile")
                               title:APP_NAME
                         buttonText0:TEXT(@"NO")
                         buttonText1:TEXT(@"YES")
                                 tag:ALERTVIEW_QUERYOVERWRITE
                            delegate:self];
                return;
            }
            if (![self saveIt:dataURL dstFileName:saveFileName]) {
                [uty showMessageDialog:TEXT(@"SaveFileError")
                                 title:APP_NAME
                                   tag:ALERTVIEW_SAVEERROR
                              delegate:self];
                return;
            } else {
                [uty showMessageDialog:TEXT(@"SaveCompleted")
                                 title:APP_NAME
                                   tag:ALERTVIEW_SAVEDONE
                              delegate:self];
                return;
            }
        }
        [self closeMe];
    }
    // show alertView again if needed
    else if (alertView.tag == ALERTVIEW_NOFILENAME ||
             alertView.tag == ALERTVIEW_SAVEERROR) {
        [self showFileNameDialog];
    }
    // overwrite?
    else if (alertView.tag == ALERTVIEW_QUERYOVERWRITE) {
        if (buttonIndex == 1) { // YES
            if (![self saveIt:dataURL
                  dstFileName:[uty createAppDocumentsFilePath:outFileName]]) {
                [uty showMessageDialog:TEXT(@"SaveFileError")
                                 title:APP_NAME
                                   tag:ALERTVIEW_SAVEERROR
                              delegate:self];
                return;
            } else {
                [uty showMessageDialog:TEXT(@"SaveCompleted")
                                 title:APP_NAME
                                   tag:ALERTVIEW_SAVEDONE
                              delegate:self];
                return;
            }
        } else { // NO
            [self showFileNameDialog];
        }
    }
    // saved
    else if (alertView.tag == ALERTVIEW_SAVEDONE) {
        [self closeMe];
    }
}

@end
