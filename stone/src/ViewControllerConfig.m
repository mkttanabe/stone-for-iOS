//
// stone for iOS : ViewControllerConfig.m
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
#import "ViewControllerConfig.h"
#import "ViewControllerHelp.h"
#import "Setting.h"
#import "Uty.h"

@interface ViewControllerConfig ()

@end

@implementation ViewControllerConfig

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    // show navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    // timeout notification setting status
    if ([setting getTimeoutNotificatinStatus]) {
        [self.labelNotifyDetail setText:TEXT(@"ON")];
    } else {
        [self.labelNotifyDetail setText:TEXT(@"OFF")];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    setting = [[Setting alloc] init];
    NSInteger fontSizeVal = [setting getFontSizeValue];
    [self.segFontSize setSelectedSegmentIndex: fontSizeVal+1];
    self.swHelp.on = [setting getStartupHelpStatus];
    
    Uty *uty = [[Uty alloc] init];
    float iosVer = [uty getOsVersion];
    
    if (iosVer < 7.0) { // temporary
        CGRect segRect = self.segFontSize.frame;
        segRect.origin.y -= 8;
        self.segFontSize.frame = segRect;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // unselect
}

// prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segeId =[segue identifier];
    
    // check segue identifier to decide the file
    if ([segeId isEqualToString:@"APPHELP"]) {
        ViewControllerHelp *vcHelp = [segue destinationViewController];
        [vcHelp setHelpFileName:TEXT(@"DescriptionHtml")];
        vcHelp.title = @"";
    }
    else if ([segeId isEqualToString:@"STONEHELP"]) {
        ViewControllerHelp *vcHelp = [segue destinationViewController];
        [vcHelp setHelpFileName:TEXT(@"StoneReameHtml")];
        vcHelp.title = @"";
    }
}

- (IBAction)segFontSizeChanged:(id)sender
{
    NSInteger val = [self.segFontSize selectedSegmentIndex] - 1;
    [setting setFontSizeValue:val];
}

- (IBAction)swHelpChanged:(id)sender
{
    [setting setStartupHelpStatus:self.swHelp.on];
}

@end
