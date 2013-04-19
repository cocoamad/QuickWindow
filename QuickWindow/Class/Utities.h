//
//  Utities.h
//  iTips
//
//  Created by Penny on 12-9-22.
//  Copyright (c) 2012年 Penny. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotification_ShowWindow @"kNotification_ShowWindow"
#define kNotification_HotKeyResponse @"kNotification_HotKeyResponse"

#define kLeftHotKey @"leftHotKey"
#define kRightHotKey @"rightHotKey"
#define kTileHotKey @"kTileHotKey"
#define kHideHotKey @"kHideHotKey"
#define kLeftTopHotKey @"kLeftTopHotKey"
#define kLeftBottomHotKey @"kLeftBottomHotKey"
#define kRightTopHotKey @"kRightTopHotKey"
#define kRightBottomHotKey @"kRightBottomHotKey"

NSImage *loadImageByName(NSString *imageName);
CGPathRef createRoundRectPathInRect(CGRect rect, CGFloat radius);
CGPathRef createRoundRectStrokePath(CGRect rect, CGFloat radius);
void ApplicationsInDirectory(NSString* searchPath, NSMutableArray* applications);
NSArray* AllApplications(NSArray* searchPaths);
NSImage *readFileIcon(NSString *appPath);
BOOL IsCommandKeyDownRightNow(void);
@interface NSImage (Convert2CGImageRef)
-(CGImageRef)CGImageRef;
@end

@interface NSColor (CGColor)
- (CGColorRef)CGColorRef;
@end