//
// stone for iOS : ViewControllerConfigNotify.h
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

#import <UIKit/UIKit.h>

@class Setting;

@interface ViewControllerConfigNotify : UIViewController
{
    Setting *setting;
}

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *labelOn;
@property (weak, nonatomic) IBOutlet UILabel *labelOff;
@property (weak, nonatomic) IBOutlet UISwitch *swNotify;

- (IBAction)swNotifyChanged:(id)sender;

@end
