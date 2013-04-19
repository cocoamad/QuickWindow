//
//  GeneralView.h
//  QuickWindow
//
//  Created by Penny on 13-1-19.
//  Copyright (c) 2013年 Penny. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRRecorderControl.h"
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"
#import "LPColorPicker.h"
@interface GeneralView : NSView
@property(nonatomic, assign) SRRecorderControl *leftSideHotKeyControl;
@property(nonatomic, assign) SRRecorderControl *rightSideHotKeyControl;
@property(nonatomic, assign) SRRecorderControl *tileSideHotKeyControl;
@property(nonatomic, assign) SRRecorderControl *leftTopHotKeyControl;
@property(nonatomic, assign) SRRecorderControl *leftBottomHotKeyControl;
@property(nonatomic, assign) SRRecorderControl *rightTopHotKeyControl;
@property(nonatomic, assign) SRRecorderControl *rightBottomHotKeyControl;

@property(nonatomic, assign) PTHotKey          *lefthotKey;
@property(nonatomic, assign) PTHotKey          *righthotKey;
@property(nonatomic, assign) PTHotKey          *tilehotKey;
@property(nonatomic, assign) PTHotKey          *leftTophotKey;
@property(nonatomic, assign) PTHotKey          *leftBottomhotKey;
@property(nonatomic, assign) PTHotKey          *rightTophotKey;
@property(nonatomic, assign) PTHotKey          *rightBottomhotKey;

@property(nonatomic, assign) IBOutlet LPColorPicker     *colorPicker;
@property(nonatomic, assign) IBOutlet NSSegmentedControl *loginControl;
-(IBAction)toggleLaunchAtLogin:(id)sender;
@end


