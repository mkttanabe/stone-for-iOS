//
// stone for iOS : Uty.h
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

@interface Uty : NSObject {
    BOOL doExitProcess;
}

- (float)getOsVersion;

- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                      tag:(int)tag
                 delegate:(id)delegate;

- (void)showMessageDialog:(NSString*)message
                    title:(NSString*)title
                   doExit:(BOOL)doExit;

- (void)showInputDialog:(NSString*)message
                  title:(NSString*)title
                    tag:(int)tag
               delegate:(id)delegate
                 secure:(BOOL)secure
            defaultText:(NSString*)defaultText;

- (void)showPasswordDialog:(NSString*)message
                     title:(NSString*)title
                       tag:(int)tag
                  delegate:(id)delegate
               defaultText:(NSString*)defaultText;

- (void)showQueryDialog:(NSString*)message
                  title:(NSString*)title
            buttonText0:(NSString*)buttonText0
            buttonText1:(NSString*)buttonText1
                    tag:(int)tag
               delegate:(id)delegate;

- (NSString*)getAppDocumentsPath;

- (NSString*)createAppDocumentsFilePath:(NSString*)fname;

- (NSArray*)getDirEntryList:(NSString*)dir;

- (void)removeInboxFiles;

@end
