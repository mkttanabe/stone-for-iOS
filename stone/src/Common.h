//
// stone for iOS : Common.h
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

#ifndef Common_h
#define Common_h

//#define DEVELOP

#define APP_NAME            @"stone for iOS"
#define EXT_STONEDATA       @"stone"
#define EXT_STONEDATA_LEN   5

#define TEXT(STR) NSLocalizedString(STR, @"")

#ifdef DEVELOP
#define _Log(...) NSLog(__VA_ARGS__)
#define LOG_TO_STDERR
#else
#define _Log(...) ;
#endif

#endif
