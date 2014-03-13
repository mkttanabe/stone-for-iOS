//
// stone for iOS : StoneWrapper.m
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
#import "StoneWrapper.h"
#import "Uty.h"

@implementation StoneWrapper

// stone.c.for_stone-for-iOS.c
int main_stone(int argc, char *argv[], char *outbuf, int outbuflen);

#define SQ @"'"
#define DQ @"\""

- (NSArray*)createStoneParameterArray:(NSString*)cmdString
{
    // e.g.
    // -dd localhost:10080/http "$HOST:5902" 'CONNECT localhost:5901'
    // -> [-dd] [localhost:10080/http] [$HOST:5902] [CONNECT localhost:5901]
    
    NSRange rangeDQ, rangeSQ;
    NSArray *wk = [cmdString componentsSeparatedByString:@" "];
    NSMutableArray *parts = [wk mutableCopy];
    int num = (int)parts.count;
    int start = 0;
    BOOL inQuote = NO;
    BOOL isSQ = NO;
    for (int i = 0; i < num; i++) {
        rangeDQ = [parts[i] rangeOfString:DQ];
        rangeSQ = [parts[i] rangeOfString:SQ];
        if (inQuote) {
            parts[start] = [parts[start] stringByAppendingString:@" "];
            parts[start] = [parts[start] stringByAppendingString:parts[i]];
            parts[i] = @"";
            if ((isSQ && rangeSQ.location != NSNotFound) ||
                (!isSQ && rangeDQ.location != NSNotFound)) {
                parts[start] = [parts[start]
                                stringByReplacingOccurrencesOfString:(isSQ)? SQ : DQ
                                withString:@""];
                inQuote = NO;
            }
        } else {
            if (rangeSQ.location == NSNotFound &&
                rangeDQ.location == NSNotFound) {
                continue;
            }
            if (rangeSQ.location != NSNotFound) {
                if (rangeDQ.location == NSNotFound ||
                    rangeSQ.location < rangeDQ.location) {
                    isSQ = YES;
                } else {
                    isSQ = NO;
                }
                
            } else {
                isSQ = NO;
            }
            // If a element contains multiple SQ or multiple DQ,
            // the quotation marks might have been closed.
            NSString *remain;
            if (isSQ) {
                remain = [parts[i] substringFromIndex:rangeSQ.location+1];
            } else {
                remain = [parts[i] substringFromIndex:rangeDQ.location+1];
            }
            if ((isSQ && [remain rangeOfString:SQ].location != NSNotFound) ||
                (!isSQ && [remain rangeOfString:DQ].location != NSNotFound)) {
                parts[i] = [parts[i]
                            stringByReplacingOccurrencesOfString:(isSQ)? SQ : DQ
                            withString:@""];
                continue;
            }
            inQuote = YES;
            start = i;
        }
    }
    num = (int)parts.count;
    for (int i = 0; i < num;) {
        if ([parts[i] length] <= 0) {
            [parts removeObjectAtIndex:i];
            num--;
            continue;
        }
        i++;
    }
    return [parts copy];
}

- (NSString*)callStone:(NSString*)cmdString
{
    if (cmdString.length <= 0) {
        return nil;
    }
    char buf[1024];
    memset(buf, 0, sizeof(buf));
    
    // chdir to <Application_Home>/Documents
    Uty *uty = [[Uty alloc]init];
    chdir([[uty getAppDocumentsPath] UTF8String]);
    
    // build argc & argv
    NSArray *paramArray = [self createStoneParameterArray:cmdString];
    int ac = (int)paramArray.count + 1;
    char **av = (char**)malloc(sizeof(char*)*ac);
    av[0] = strdup("stone");
    for (int i = 0; i < paramArray.count; i++) {
        av[i+1] = strdup([paramArray[i] UTF8String]);
    }
    
    // call stone
    //main_stone(ac,av, buf, sizeof(buf));
    main_stone(ac,av, NULL, 0);
    
    for (int i = 0; i < paramArray.count+1; i++) {
        free(av[i]);
    }
    free(av);
    
    if (strlen(buf) <= 0) {
        return nil;
    }
    return [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
}

@end
