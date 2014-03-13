//
// stone for iOS : ViewController.m
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
#import "ViewControllerMain.h"
#import "StoneWrapper.h"
#import "Setting.h"
#import "Uty.h"

@interface ViewControllerMain ()

@end

@implementation ViewControllerMain

#define ALERT_QUERYEXIT      0
#define ALERT_QUERYCLEARLOG  1

-(void)viewWillAppear:(BOOL)animated
{
    // hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setFontSize:[setting getFontSizeValue]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self enableRunButton:YES];
    setting = [[Setting alloc] init];
    [setting setDefaultValues];
    uty = [[Uty alloc] init];
    
    // redirect stderr
    orgStdErr = dup(fileno(stderr));
    logPipe = [[NSPipe alloc] init];
    logPipeReadHandle = logPipe.fileHandleForReading;
    dup2(logPipe.fileHandleForWriting.fileDescriptor, fileno(stderr));
    // register the notification request
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logNotify:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:logPipeReadHandle] ;
    // start read & notify in background
    [logPipeReadHandle readInBackgroundAndNotify] ;
    
    // add "Done" button to the keyboard (for command field)
    [self.FldCommand setReturnKeyType:UIReturnKeyDone];
    // set textView delegate
    [self.FldCommand setDelegate:self];
    
    // delete [Application Directory]/Documents/Inbox/*
    [uty removeInboxFiles];
    
    // restore the last command
    if ([setting countCommandHistory] > 0) {
        NSArray *history = [setting getCommandHistory];
        [self.FldCommand setText:history[0]];
    }
    
    // show simple help
    if ([setting getStartupHelpStatus]) {
        [self.logView setText:TEXT(@"Usage")];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// [Run] button action
- (IBAction)buttonRunPushed:(UIButton *)sender
{
    __block NSString *stoneMsg;
    [self enableRunButton:NO];
    dispatch_queue_t globalQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQ = dispatch_get_main_queue();
    dispatch_async(globalQ, ^{
        NSString *cmd = [self.FldCommand text];
        if (cmd.length <= 0) {
            cmd = @"-h";
        }
        [setting setCommandHistory:cmd];
        StoneWrapper *stoneObj = [[StoneWrapper alloc] init];
        stoneMsg = [stoneObj callStone:cmd];

        dispatch_async(mainQ, ^{
            [self enableRunButton:YES];
            //if (stoneMsg != nil) {
            //    [uty showMessageDialog:stoneMsg title:APP_NAME tag:-1 delegate:nil];
            //}
        });
    });
}

// [Stop] button action
- (IBAction)bttonStopPushed:(UIButton *)sender
{
    [uty showQueryDialog:TEXT(@"QueryExit")
                   title:APP_NAME
             buttonText0:TEXT(@"Cancel")
             buttonText1:TEXT(@"OK")
                     tag:ALERT_QUERYEXIT
                delegate:self];
}

// [Clear] button action
- (IBAction)buttonClearPushed:(UIButton *)sender
{
    if (self.logView.text.length > 0) {
        [uty showQueryDialog:TEXT(@"QueryClearLog")
                       title:APP_NAME
                 buttonText0:TEXT(@"Cancel")
                 buttonText1:TEXT(@"OK")
                         tag:ALERT_QUERYCLEARLOG
                    delegate:self];
    }
}

// alertView delegate
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_QUERYEXIT) {
        if (buttonIndex == 1) { // YES
            [uty removeInboxFiles];
            exit(0);
        }
    } else if (alertView.tag == ALERT_QUERYCLEARLOG) {
        if (buttonIndex == 1) { // YES
            [self.logView setText:@""];
        }
    }
}

// textView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder]; // close IME
        return NO;
    }
    return YES;
}

- (void)logNotify:(NSNotification *)notification
{
    // get log message from the notification
    NSDictionary *info = [notification userInfo];
    NSData *data = [info objectForKey: NSFileHandleNotificationDataItem];
    NSString *logStr = [[NSString alloc] initWithData:data
                                             encoding: NSUTF8StringEncoding];
    // add log message to logView
    [self.logView setText:[NSString stringWithFormat:@"%@%@", self.logView.text, logStr]];
    
#ifdef LOG_TO_STDERR
        // output to the original stderr
        dup2(orgStdErr, fileno(stderr));
        //fprintf(stderr, "%s", [logStr UTF8String]);
        NSLog(@"%@", logStr);
        dup2([[logPipe fileHandleForWriting] fileDescriptor], fileno(stderr)) ;
#endif
    
    if (self.logView.text.length > 0) {
        // scroll to bottom
        NSRange bottom = NSMakeRange(self.logView.text.length -1, 1);
        [self.logView scrollRangeToVisible:bottom];
    }
    // restart read & notify in background
    [logPipeReadHandle readInBackgroundAndNotify];
}

- (void)setFontSize:(NSInteger)val
{
    NSString *cmdFontFamily = [[self.FldCommand font] familyName];
    NSString *logFontFamily = [[self.logView font] familyName];
    CGFloat cmdFontSize = DEFAULT_FONTSIZE_CMD;
    CGFloat logFontSize = DEFAULT_FONTSIZE_LOG;
    
    if (val >= FONTSIZE_LARGE) {
        cmdFontSize += GAP_FONTSIZE_LARGE;
        logFontSize += GAP_FONTSIZE_LARGE;
    } else if (val <= FONTSIZE_SMALL) {
        cmdFontSize -= GAP_FONTSIZE_SMALL;
        logFontSize -= GAP_FONTSIZE_SMALL;
    }
    UIFont *cmdFont = [UIFont fontWithName:cmdFontFamily size:cmdFontSize];
    UIFont *logFont = [UIFont fontWithName:logFontFamily size:logFontSize];
    [self.FldCommand setFont:cmdFont];
    [self.logView setFont:logFont];
}

-(void)setCommandString:(NSString*)cmdStr;
{
    [self.FldCommand setText:cmdStr];
}

- (void)enableRunButton:(BOOL)YESorNO
{
    [self.ButtonRun setEnabled:YESorNO];
    //[self.ButtonStop setEnabled:!YESorNO];
}

@end
