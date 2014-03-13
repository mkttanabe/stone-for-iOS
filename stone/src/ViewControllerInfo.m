//
// stone for iOS : ViewControllerInfo.m
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
#import "ViewControllerInfo.h"
#import "ViewControllerHelp.h"

char *stoneCvsId(); // stone.c.for_stone-for-iOS.c

@interface ViewControllerInfo ()

@end

@implementation ViewControllerInfo

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // app version
    [self.labelAppVersion setText:
     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    // stone.c revision
    NSString *text = [NSString stringWithCString:stoneCvsId() encoding:NSUTF8StringEncoding];
    NSArray *array = [text componentsSeparatedByString:@" "];
    [self.labelStoneVersion setText:array[3]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segeId =[segue identifier];
    
    // check segue identifier to decide the file
    if ([segeId isEqualToString:@"GPL"]) {
        ViewControllerHelp *vcHelp = [segue destinationViewController];
        [vcHelp setHelpFileName:TEXT(@"GPLFile")];
        vcHelp.title = @"";
    }
    else if ([segeId isEqualToString:@"OpenSSL_License"]) {
        ViewControllerHelp *vcHelp = [segue destinationViewController];
        [vcHelp setHelpFileName:TEXT(@"OpenSSLLicenseFile")];
        vcHelp.title = @"";
    }
}

@end
