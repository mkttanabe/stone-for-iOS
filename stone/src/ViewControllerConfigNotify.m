//
// stone for iOS : ViewControllerConfigNotify.m
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

#import "ViewControllerConfigNotify.h"
#import "Setting.h"
#import "Uty.h"

@interface ViewControllerConfigNotify ()

@end

@implementation ViewControllerConfigNotify

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
    Uty *uty = [[Uty alloc] init];
    float iosVer = [uty getOsVersion];
    
    if (iosVer < 7.0) { // temporary
        self.view.backgroundColor = [UIColor whiteColor];
        self.textView.backgroundColor = [UIColor whiteColor];
        self.labelOn.alpha = 0; // hidden
        self.labelOff.alpha = 0;
        CGRect rect = self.swNotify.frame;
        rect.origin.y -= 40;
        rect.origin.x -= 10;
        self.swNotify.frame = rect;
    }
    setting = [[Setting alloc] init];
    self.swNotify.on = [setting getTimeoutNotificatinStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)swNotifyChanged:(id)sender {
    [setting setTimeoutNotificatinStatus:self.swNotify.on];
}

@end
