//
//  GeneralView.m
//  QuickWindow
//
//  Created by Penny on 13-1-19.
//  Copyright (c) 2013年 Penny. All rights reserved.
//

#import "GeneralView.h"
#import "Utities.h"
#import <ServiceManagement/ServiceManagement.h>
//#define HideKey 0


@implementation GeneralView

- (void)awakeFromNib
{
    [self layoutHotKeyControl];
    
    BOOL startLoginIn = [[NSUserDefaults standardUserDefaults] boolForKey: @"startLoginIn"];
    if (startLoginIn) {
        [_loginControl  setSelectedSegment: 0];
    } else [_loginControl setSelectedSegment: 1];
}

- (void)layoutHotKeyControl
{
    _leftSideHotKeyControl = [[[SRRecorderControl alloc] initWithFrame: NSMakeRect(178, 311, 179, 23)] autorelease];
    _rightSideHotKeyControl = [[[SRRecorderControl alloc] initWithFrame: NSMakeRect(178, 279, 179, 23)] autorelease];
    _tileSideHotKeyControl = [[[SRRecorderControl alloc] initWithFrame: NSMakeRect(178, 245, 179, 23)] autorelease];
    _leftTopHotKeyControl = [[[SRRecorderControl alloc] initWithFrame: NSMakeRect(178, 213, 179, 23)] autorelease];
    _leftBottomHotKeyControl = [[[SRRecorderControl alloc] initWithFrame: NSMakeRect(178, 181, 179, 23)] autorelease];
    _rightTopHotKeyControl = [[[SRRecorderControl alloc] initWithFrame: NSMakeRect(178, 149, 179, 23)] autorelease];
    _rightBottomHotKeyControl = [[[SRRecorderControl alloc] initWithFrame: NSMakeRect(178, 117, 179, 23)] autorelease];
    /*
     cmd + <--:  flag 9437184 code 123
     cmd + -->:  flag 9437184 code 124
     cmd + top:  flag 9437184 code 126
     */
    
    [self settingHotKeyControl: kLeftHotKey KeyCombo: SRMakeKeyCombo(123, 9961472) PTHotKey: _lefthotKey RecorderControl: _leftSideHotKeyControl Tag: 1];
    [self settingHotKeyControl: kRightHotKey KeyCombo: SRMakeKeyCombo(124, 9961472) PTHotKey: _righthotKey RecorderControl: _rightSideHotKeyControl Tag: 2];
    [self settingHotKeyControl: kTileHotKey KeyCombo: SRMakeKeyCombo(126, 9961472) PTHotKey: _tilehotKey RecorderControl: _tileSideHotKeyControl Tag: 3];
    [self settingHotKeyControl: kLeftTopHotKey KeyCombo: SRMakeKeyCombo(0, 0) PTHotKey: _leftTophotKey RecorderControl: _leftTopHotKeyControl Tag: 4];
    [self settingHotKeyControl: kLeftBottomHotKey KeyCombo: SRMakeKeyCombo(0, 0) PTHotKey: _leftBottomhotKey RecorderControl: _leftBottomHotKeyControl Tag: 5];
    [self settingHotKeyControl: kRightTopHotKey KeyCombo: SRMakeKeyCombo(0, 0) PTHotKey: _rightTophotKey RecorderControl: _rightTopHotKeyControl Tag: 6];
    [self settingHotKeyControl: kRightBottomHotKey KeyCombo: SRMakeKeyCombo(0, 0) PTHotKey: _rightBottomhotKey RecorderControl: _rightBottomHotKeyControl Tag: 7];
}

- (void)settingHotKeyControl:(NSString *)identifiy KeyCombo:(KeyCombo)keyCombo
                    PTHotKey:(PTHotKey *)hotKey RecorderControl:(SRRecorderControl*)control
                         Tag:(NSInteger)tag
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey: identifiy] == nil) {
        [self saveHotkey: keyCombo Key: identifiy];
    } else {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey: identifiy];
        keyCombo.flags = [dict[@"flags"] intValue];
        keyCombo.code = [dict[@"code"] intValue];
    }
    [control setKeyCombo: keyCombo];
    [control setTag: tag];
    [control setDelegate: self];
    [self toggleHotKey: keyCombo PTHotKey: hotKey Target: self Action: @selector(hotKeyResponse:) Identifier: identifiy];
    [self addSubview: control];
}


- (void)saveHotkey:(KeyCombo)keyCombo Key:(NSString *)key
{
    NSInteger flags = keyCombo.flags;
    NSInteger code = keyCombo.code;
    NSDictionary *dict = @{@"flags" : @(flags), @"code" : @(code)};
    [[NSUserDefaults standardUserDefaults] setValue: dict forKey: key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark PTHotKey Action
- (void)toggleHotKey:(KeyCombo)keyCombo PTHotKey:(PTHotKey *)hotKey Target:(id)target Action:(SEL)sel Identifier:(NSString*)identifier
{
    if (hotKey != nil)
	{
		[[PTHotKeyCenter sharedCenter] unregisterHotKey: hotKey];
		[hotKey release];
		hotKey = nil;
	}
    if (keyCombo.code != 0 && keyCombo.flags != 0) {
        hotKey = [[PTHotKey alloc] initWithIdentifier: identifier
                                                 keyCombo: [PTKeyCombo keyComboWithKeyCode: (int)keyCombo.code
                                                                                 modifiers: (int)SRCocoaToCarbonFlags(keyCombo.flags)]];
        [hotKey setName: identifier];
        [hotKey setTarget: target];
        [hotKey setAction: sel];
        [[PTHotKeyCenter sharedCenter] registerHotKey: hotKey];
    }
}

- (void)hotKeyResponse:(PTHotKey*)hotKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotification_HotKeyResponse object: [hotKey name]];
}

-(IBAction)toggleLaunchAtLogin:(id)sender
{
    NSInteger clickedSegment = [(NSSegmentedControl*)sender selectedSegment];
    if (clickedSegment == 0) { // ON
        // Turn on launch at login
        if (!SMLoginItemSetEnabled ((CFStringRef)@"com.cocoamad.QuickWindowLoginHelper", YES)) {
            NSAlert *alert = [NSAlert alertWithMessageText: @"An error ocurred"
                                             defaultButton: @"OK"
                                           alternateButton: nil
                                               otherButton: nil
                                 informativeTextWithFormat: @"Couldn't add Helper App to launch at login item list."];
            [alert runModal];
        } else [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"startLoginIn"];
    }
    if (clickedSegment == 1) { // OFF
        // Turn off launch at login
        if (!SMLoginItemSetEnabled ((CFStringRef)@"com.cocoamad.QuickWindowLoginHelper", NO)) {
            NSAlert *alert = [NSAlert alertWithMessageText: @"An error ocurred"
                                             defaultButton: @"OK"
                                           alternateButton: nil
                                               otherButton: nil
                                 informativeTextWithFormat: @"Couldn't remove Helper App from launch at login item list."];
            [alert runModal];
        } else [[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"startLoginIn"];
    }
}
#pragma mark - HotKeyControl Delegate
- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
    KeyCombo newKeyCombo;
    PTHotKey *hotKey;
    newKeyCombo.flags = flags;
    newKeyCombo.code = keyCode;
    [aRecorder setKeyCombo: newKeyCombo];
    NSString *key = nil;
    switch (aRecorder.tag) {
        case 1:
            key = kLeftHotKey;
            hotKey = _lefthotKey;
            break;
        case 2:
            key = kRightHotKey;
            hotKey = _righthotKey;
            break;
        case 3:
            key = kTileHotKey;
            hotKey = _tilehotKey;
            break;
        case 4:
            key = kLeftTopHotKey;
            hotKey = _leftTophotKey;
            break;
        case 5:
            key = kLeftBottomHotKey;
            hotKey = _leftBottomhotKey;
            break;
        case 6:
            key = kRightTopHotKey;
            hotKey = _rightTophotKey;
            break;
        case 7:
            key = kRightBottomHotKey;
            hotKey = _rightBottomhotKey;
            break;
        default:
            break;
    }
    [self saveHotkey: newKeyCombo Key: key];
    [self toggleHotKey: newKeyCombo PTHotKey: hotKey Target: self Action: @selector(hotKeyResponse:) Identifier: key];
    
    NSLog(@"%ld, %ld", newKeyCombo.code, newKeyCombo.flags);
    return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{

}

@end
