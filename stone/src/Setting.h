//
// stone for iOS : Setting.h
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

#import <Foundation/Foundation.h>

@interface Setting : NSObject
{
    NSUserDefaults *userDefaults;
}

- (void)setDefaultValues;
- (BOOL)getTimeoutNotificatinStatus;
- (BOOL)setTimeoutNotificatinStatus:(BOOL)YesOrNo;
- (NSInteger)getFontSizeValue;
- (BOOL)setFontSizeValue:(NSInteger)val;
- (BOOL)getStartupHelpStatus;
- (BOOL)setStartupHelpStatus:(BOOL)YesOrNo;
- (int)countCommandHistory;
- (NSArray*)getCommandHistory;
- (BOOL)setCommandHistory:(NSString*)cmd;
- (BOOL)setCommandHistoryArray:(NSArray*)cmdArray;

#define DEFAULT_FONTSIZE_CMD 14
#define DEFAULT_FONTSIZE_LOG 13

#define FONTSIZE_SMALL  -1
#define FONTSIZE_NORMAL  0
#define FONTSIZE_LARGE   1

#define GAP_FONTSIZE_LARGE 4
#define GAP_FONTSIZE_SMALL 3

#define DEFAULT_CMD_0 @"-dd www.gcd.org:80 1234"
#define DEFAULT_CMD_1 @"-h"
#define DEFAULT_CMD_2 @"-h opt"
#define DEFAULT_CMD_3 @"-h ssl"

@end
