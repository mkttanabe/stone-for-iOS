//
// stone for iOS : Setting.m
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

#import "Setting.h"

@implementation Setting

#define KEY_NOTIFY   @"timeoutNotification"
#define KEY_FONTSIZE @"fontSize"
#define KEY_HELP     @"startupHelp"
#define KEY_HISTORY  @"history"

- (id)init {
    if (self = [super init]) {
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)setDefaultValues
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *cmdSample = @[DEFAULT_CMD_0, DEFAULT_CMD_1, DEFAULT_CMD_2, DEFAULT_CMD_3];
    // default values
    [dic setObject:@"YES" forKey:KEY_NOTIFY];
    [dic setObject:@"0" forKey:KEY_FONTSIZE];
    [dic setObject:@"YES" forKey:KEY_HELP];
    [dic setObject:cmdSample forKey:KEY_HISTORY];
    [userDefaults registerDefaults:dic];
    [userDefaults synchronize];
}

- (BOOL)getTimeoutNotificatinStatus
{
    return [userDefaults boolForKey:KEY_NOTIFY];
}

- (BOOL)setTimeoutNotificatinStatus:(BOOL)YesOrNo
{
    [userDefaults setBool:YesOrNo forKey:KEY_NOTIFY];
    return [userDefaults synchronize];
}

- (NSInteger)getFontSizeValue
{
    return [userDefaults integerForKey:KEY_FONTSIZE];
}

- (BOOL)setFontSizeValue:(NSInteger)val
{
    NSInteger n = (val < FONTSIZE_SMALL) ? FONTSIZE_SMALL :
    (val > FONTSIZE_LARGE) ? FONTSIZE_LARGE : val;
    [userDefaults setInteger:n forKey:KEY_FONTSIZE];
    return [userDefaults synchronize];
}

- (BOOL)getStartupHelpStatus
{
    return [userDefaults boolForKey:KEY_HELP];
}

- (BOOL)setStartupHelpStatus:(BOOL)YesOrNo
{
    [userDefaults setBool:YesOrNo forKey:KEY_HELP];
    return [userDefaults synchronize];
}

- (int)countCommandHistory
{
    NSArray *history = [userDefaults arrayForKey:KEY_HISTORY];
    return (int)[history count];
}

- (NSArray*)getCommandHistory
{
    return [userDefaults arrayForKey:KEY_HISTORY];
}

// save string to the Command History
- (BOOL)setCommandHistory:(NSString*)cmd
{
    NSArray *history = [userDefaults arrayForKey:KEY_HISTORY];
    if (!history) {
        // save immediately if there are no records
        [userDefaults setObject:@[cmd] forKey:KEY_HISTORY];
    } else {
        NSMutableArray *wk = [history mutableCopy];
        NSUInteger idx = [wk indexOfObject:cmd];
        if (idx != NSNotFound) {
            if (idx == 0) {
                // the record already exists on top of the history list
                return YES;
            } else {
                // delete the record once
                [wk removeObjectAtIndex:idx];
            }
        }
        // save to the top of the list
        [wk insertObject:cmd atIndex:0];
        history = [wk copy];
        [userDefaults setObject:history forKey:KEY_HISTORY];
    }
    return [userDefaults synchronize];
}

- (BOOL)setCommandHistoryArray:(NSArray*)cmdArray
{
    /*if (cmdArray.count <= 0) {
     [userDefaults removeObjectForKey:KEY_HISTORY];
     } else {
     [userDefaults setObject:cmdArray forKey:KEY_HISTORY];
     }*/
    [userDefaults setObject:cmdArray forKey:KEY_HISTORY];
    return [userDefaults synchronize];
}

@end
