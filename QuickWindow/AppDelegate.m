//
//  AppDelegate.m
//  QuickWindow
//
//  Created by Penny on 13-1-19.
//  Copyright (c) 2013年 Penny. All rights reserved.
//

#import "AppDelegate.h"
#import "UIElementUtilities.h"
#import "StatusBarView.h"
#import "LPPrefsPanel.h"

typedef enum {
    kWindowSideTopLeft = 0,
    kWindowSideTopRight,
    kWindowSideBottomLeft,
    kWindowSideBottomRight,
    kWindowSideLeft,
    kWindowSideRight,
    kWiddowSideTile,
    kWindowSideCenter
} WindowSide;

@interface AppDelegate ()
@property (nonatomic, assign) StatusBarView *barView;
@property (nonatomic, assign) NSPoint lastMousePoint;
@property (nonatomic, assign) AXUIElementRef currentUIElement;
@property (nonatomic, assign) AXUIElementRef systemWideElement;
@property (nonatomic, assign) IBOutlet LPPrefsPanel *prefsPanel;
@property (nonatomic, assign) NSWindow *positionWindow;
@property (nonatomic, assign) WindowSide side;

@property (nonatomic, assign) NSInteger today;
@property (nonatomic, assign) NSInteger total;
@end

@implementation AppDelegate

- (void)dealloc
{
    if (_systemWideElement) CFRelease(_systemWideElement);
    if (_currentUIElement) CFRelease(_currentUIElement);
    [super dealloc];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _barView = [[StatusBarView alloc] initWithFrame: NSMakeRect(0, 0, 24, 18)];
    
    [self setupAccess];
    _systemWideElement = AXUIElementCreateSystemWide();
    
    _today = [[NSUserDefaults standardUserDefaults] integerForKey: @"today"];
    
    NSArray *array = [[[NSDate date] description] componentsSeparatedByString:@" "];
    NSString *date = [array objectAtIndex: 0];
    NSString *standDate = [[NSUserDefaults standardUserDefaults] objectForKey: @"date"];
    if (![standDate isEqualToString: date]) {
        [[NSUserDefaults standardUserDefaults] setObject: date forKey: @"date"];
        [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey: @"today"];
        _today = 0;
    }
    
    _total = [[NSUserDefaults standardUserDefaults] integerForKey: @"total"];
    
    [self performTimerBasedUpdate];
    [self addGlobalMonitorForEvents];
    [self registerNotification];
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(showPreference:)
                                                 name: kNotification_ShowWindow object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(hotKey:)
                                                 name: kNotification_HotKeyResponse object: nil];
}

- (void)addGlobalMonitorForEvents
{
    [NSEvent addGlobalMonitorForEventsMatchingMask: NSLeftMouseDraggedMask handler:^(NSEvent *event) {
        NSPoint point = [event locationInWindow];

        if (fabs(point.y - [NSScreen mainScreen].frame.size.height) < 22 && point.x < 2) {
            // top left
            if ([UIElementUtilities isWindowUIElement: _currentUIElement]) {
                NSRect frame = [NSScreen mainScreen].frame;
                NSRect rect = NSMakeRect(frame.origin.x, frame.size.height / 2 - 11, frame.size.width / 2, (frame.size.height - 22) / 2);
                _side = kWindowSideTopLeft;
                [self createSideWindow: rect];
            }
        } else if (point.y < 2 && point.x < 2){
            // bottom left
            if ([UIElementUtilities isWindowUIElement: _currentUIElement]) {
                NSRect frame = [NSScreen mainScreen].frame;
                NSRect rect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width / 2, (frame.size.height - 22) / 2);
                _side = kWindowSideBottomLeft;
                [self createSideWindow: rect];
            }
        } else if (fabs(point.x - [NSScreen mainScreen].frame.size.width) < 2 && fabs(point.y - [NSScreen mainScreen].frame.size.height) < 22){
            // top right
            if ([UIElementUtilities isWindowUIElement: _currentUIElement]) {
                NSRect frame = [NSScreen mainScreen].frame;
                NSRect rect = NSMakeRect(frame.size.width / 2, frame.size.height / 2, frame.size.width / 2, (frame.size.height - 22) / 2);
                _side = kWindowSideTopRight;
                [self createSideWindow: rect];
            }
        } else if (fabs(point.x - [NSScreen mainScreen].frame.size.width) < 2 && point.y < 2){
            // bottom right
            if ([UIElementUtilities isWindowUIElement: _currentUIElement]) {
                NSRect frame = [NSScreen mainScreen].frame;
                NSRect rect = NSMakeRect(frame.size.width / 2, frame.origin.y, frame.size.width / 2, (frame.size.height - 22) / 2);
                _side = kWindowSideBottomRight;
                [self createSideWindow: rect];
            }
        } else if (fabs(point.y -[NSScreen mainScreen].frame.size.height) < 22) {
            if ([UIElementUtilities isWindowUIElement: _currentUIElement]) {
                _side = kWiddowSideTile;
                [self createSideWindow: [NSScreen mainScreen].frame];
            }
        } else if (point.x < 2) {
            if ([UIElementUtilities isWindowUIElement: _currentUIElement]) {
                NSRect frame = [NSScreen mainScreen].frame;
                _side = kWindowSideLeft;
                [self createSideWindow: NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width / 2, frame.size.height)];
            }
            
        } else if (fabs(point.x - [NSScreen mainScreen].frame.size.width) < 2) {
            if ([UIElementUtilities isWindowUIElement: _currentUIElement]) {
                NSRect frame = [NSScreen mainScreen].frame;
                _side = kWindowSideRight;
                [self createSideWindow: NSMakeRect(frame.size.width / 2, frame.origin.y, frame.size.width / 2, frame.size.height)];
            }
        } else {
            [self destorySideWindow];
        }
        
    }];
    /*
     
     typedef enum {
     kWindowSideTopLeft = 0,
     kWindowSideTopRight,
     kWindowSideBottomLeft,
     kWindowSideBottomRight,
     kWindowSideLeft,
     kWindowSideRight,
     kWiddowSideTile
     } WindowSide;
     */
    [NSEvent addGlobalMonitorForEventsMatchingMask: NSLeftMouseUpMask handler:^(NSEvent *event) {
        if (_positionWindow) {
            NSRect mainFrame = [NSScreen mainScreen].frame;
            NSRect newWindowFrame = NSZeroRect;
            switch (_side) {
                case kWindowSideTopLeft:
                    newWindowFrame = NSMakeRect(0, 22, mainFrame.size.width / 2, (mainFrame.size.height - 22) / 2);
                    break;
                case kWindowSideTopRight:
                    newWindowFrame = NSMakeRect(mainFrame.size.width / 2, 22, mainFrame.size.width / 2, (mainFrame.size.height - 22) / 2);
                    break;
                case kWindowSideBottomLeft:
                    newWindowFrame = NSMakeRect(0, mainFrame.size.height / 2 + 11, mainFrame.size.width / 2, (mainFrame.size.height - 22) / 2);
                    break;
                case kWindowSideBottomRight:
                    newWindowFrame = NSMakeRect(mainFrame.size.width / 2, mainFrame.size.height / 2 + 11, mainFrame.size.width / 2, (mainFrame.size.height - 22) / 2);
                    break;
                case kWindowSideLeft:
                    newWindowFrame = NSMakeRect(0, 22, mainFrame.size.width / 2, mainFrame.size.height - 22);
                    break;
                case kWindowSideRight:
                    newWindowFrame = NSMakeRect(mainFrame.size.width / 2, 22, mainFrame.size.width / 2, mainFrame.size.height - 22);
                    break;
                case kWiddowSideTile:
                    newWindowFrame = NSMakeRect(0, 22, mainFrame.size.width, mainFrame.size.height - 22);
                    break;
                default:
                    break;
            }
            [self destorySideWindow];
            [self setAtributte: newWindowFrame];
            
        }
    }];
}

- (void)createSideWindow:(NSRect)rect
{
    if(_positionWindow) {
        [_positionWindow setFrame: rect display: NO];
        NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey: @"IndicationWindowColor"];
        [_positionWindow setBackgroundColor: [NSColor colorWithDeviceRed: [[colorDict objectForKey: @"r"] floatValue]
                                                                   green: [[colorDict objectForKey: @"g"] floatValue]
                                                                    blue: [[colorDict objectForKey: @"b"] floatValue] alpha: 1]];
        NSTextField *field = [_positionWindow.contentView viewWithTag: 10001];
        [field setFrame: NSMakeRect(0, (rect.size.height - 100) * .5, rect.size.width, 100)];
    }
    else {
        _positionWindow = [[NSWindow alloc] initWithContentRect: rect styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered defer: YES];
        NSTextField *field = [[[NSTextField alloc] initWithFrame: NSMakeRect(0, (rect.size.height - 100) * .5, rect.size.width, 100)] autorelease];
        [field setTag:10001];
        [field setBordered: NO];
        [field setStringValue: @"Window Scissors"];
        [field setFont: [NSFont systemFontOfSize: 80]];
        [field setTextColor: [NSColor whiteColor]];
        [field setBezeled:NO];
        [field setAlignment: NSCenterTextAlignment];
        [field setDrawsBackground:NO];
        [field setEditable:NO];
        [field setSelectable:NO];
        
        NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey: @"IndicationWindowColor"];
        [_positionWindow setBackgroundColor: [NSColor colorWithDeviceRed: [[colorDict objectForKey: @"r"] floatValue]
                                                                   green: [[colorDict objectForKey: @"g"]floatValue]
                                                                    blue: [[colorDict objectForKey: @"b"] floatValue] alpha: 1]];
        
        
        [_positionWindow.contentView addSubview: field];

        [_positionWindow setOpaque: NO];
        [_positionWindow setBackgroundColor: [NSColor blackColor]];
        _positionWindow.alphaValue = .6;
        [_positionWindow setLevel: kCGFloatingWindowLevel];
        [_positionWindow makeKeyAndOrderFront: nil];
    }
}

- (void)destorySideWindow
{
    if (_positionWindow) {
        [_positionWindow orderOut: self];
        [_positionWindow release];
        _positionWindow = nil;
    }
}

- (void)setupAccess
{
    if (!AXAPIEnabled())
    {
        
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:@"Window Scissors requires that the Accessibility API be enabled."];
        [alert setInformativeText:@"Would you like to launch System Preferences so that you can turn on \"Enable access for assistive devices\"?"];
        [alert addButtonWithTitle:@"Open System Preferences"];
        [alert addButtonWithTitle:@"Quit Window Scissors"];
        
        NSInteger alertResult = [alert runModal];
        
        switch (alertResult) {
            case NSAlertFirstButtonReturn: {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSSystemDomainMask, YES);
                if ([paths count] == 1) {
                    NSURL *prefPaneURL = [NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"UniversalAccessPref.prefPane"]];
                    [[NSWorkspace sharedWorkspace] openURL:prefPaneURL];
                }
            }
                break;
                
            case NSAlertSecondButtonReturn: // just continue
            default:
                break;
            case NSAlertThirdButtonReturn:
                [NSApp terminate: self];
                return;
                break;
        }
    }
}

- (void)showPreference:(NSNotification*)n
{
    NSInteger index = [[n object] intValue];
    [_prefsPanel selectedTabIndex: index];
    [_prefsPanel orderFrontPrefsPanel: self];
}

- (void)hotKey:(NSNotification*)n
{
    NSString *name = [n object];
    NSRect newFrame = NSZeroRect;
    if ([name isEqualToString: kLeftHotKey]) {
        NSRect screenFrame = [NSScreen mainScreen].frame;
        newFrame = NSMakeRect(-0, 0, screenFrame.size.width / 2, screenFrame.size.height);
        [self setAtributte: newFrame];
    } else if ([name isEqualToString: kRightHotKey]){
        NSRect screenFrame = [NSScreen mainScreen].frame;
        newFrame = NSMakeRect(screenFrame.size.width / 2, 0, screenFrame.size.width / 2, screenFrame.size.height);
        [self setAtributte: newFrame];
    } else if ([name isEqualToString: kTileHotKey]) {
        newFrame = [NSScreen mainScreen].frame;
        [self setAtributte: newFrame];
    } else if ([name isEqualToString: kLeftTopHotKey]) {
        newFrame = [NSScreen mainScreen].frame;
        newFrame = NSMakeRect(0, 22, newFrame.size.width / 2, (newFrame.size.height - 22) / 2);
        [self setAtributte: newFrame];
    } else if ([name isEqualToString: kLeftBottomHotKey]) {
        newFrame = [NSScreen mainScreen].frame;
        newFrame = NSMakeRect(newFrame.size.width / 2, 22, newFrame.size.width / 2, (newFrame.size.height - 22) / 2);
        [self setAtributte: newFrame];
    } else if ([name isEqualToString: kLeftBottomHotKey]) {
        newFrame = [NSScreen mainScreen].frame;
        newFrame = NSMakeRect(0, newFrame.size.height / 2 + 11, newFrame.size.width / 2, (newFrame.size.height - 22) / 2);
        [self setAtributte: newFrame];
    } else if ([name isEqualToString: kRightBottomHotKey]) {
        newFrame = [NSScreen mainScreen].frame;
        newFrame = NSMakeRect(newFrame.size.width / 2, newFrame.size.height / 2 + 11, newFrame.size.width / 2, (newFrame.size.height - 22) / 2);
        [self setAtributte: newFrame];
    }
    
}

- (void)setAtributte:(NSRect)rect
{
    
    NSLog(@"%@, %@", [UIElementUtilities roleOfUIElement: _currentUIElement],[UIElementUtilities titleOfUIElement: _currentUIElement]);
    [UIElementUtilities setStringValue: [NSString stringWithFormat:@"x=%f y=%f", rect.origin.x, rect.origin.y]
                          forAttribute: @"AXPosition" ofUIElement: [self AXWindow: _currentUIElement]];
    
    [UIElementUtilities setStringValue: [NSString stringWithFormat:@"w=%f h=%f", rect.size.width, rect.size.height]
                          forAttribute: @"AXSize" ofUIElement: [self AXWindow: _currentUIElement]];
    
    _total++;
    _today++;
    [[NSUserDefaults standardUserDefaults] setInteger: _total forKey: @"total"];
    [[NSUserDefaults standardUserDefaults] setInteger: _today forKey: @"today"];
}

- (void)setHideAttribute:(AXUIElementRef)element Hidden:(BOOL)hide
{    
    [UIElementUtilities setStringValue: @"1"
                          forAttribute: @"AXHidden" ofUIElement: element];
}

- (void)performTimerBasedUpdate
{
    [self updateCurrentUIElement];
    
    [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(performTimerBasedUpdate) userInfo:nil repeats:NO];
}

- (BOOL)isNotPositionWindow:(AXUIElementRef)element
{
    AXUIElementRef newElement = (AXUIElementRef)[UIElementUtilities valueOfAttribute: @"AXParent" ofUIElement: element];
    NSString *name = [UIElementUtilities valueOfAttribute:@"AXTitle" ofUIElement: newElement];
    if ([name isEqualToString: @"Window Scissors"]) {
        return NO;
    }
    return YES;
}

- (BOOL)isNotMenuBar:(AXUIElementRef)element
{
    NSString *name = [UIElementUtilities valueOfAttribute:@"AXRole" ofUIElement: element];
    if ([name isEqualToString: @"AXMenuBar"]) {
        return NO;
    }
    return YES;
}
// -------------------------------------------------------------------------------
//	updateCurrentUIElement:
// -------------------------------------------------------------------------------
- (void)updateCurrentUIElement
{       
        // The current mouse position with origin at top right.
        NSPoint cocoaPoint = [NSEvent mouseLocation];
        
        // Only ask for the UIElement under the mouse if has moved since the last check.
        if (!NSEqualPoints(cocoaPoint, _lastMousePoint)) {
            
            CGPoint pointAsCGPoint = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint: cocoaPoint];
            
            AXUIElementRef newElement = NULL;
            
            // Ask Accessibility API for UI Element under the mouse
            if (AXUIElementCopyElementAtPosition( _systemWideElement, pointAsCGPoint.x, pointAsCGPoint.y, &newElement ) == kAXErrorSuccess
                && newElement && ([self currentUIElement] == NULL || ! CFEqual( [self currentUIElement], newElement ))) {
                if ([UIElementUtilities isWindowUIElement: newElement] && [self isNotPositionWindow: newElement] && [self isNotMenuBar: newElement]) {
                    [self setCurrentUIElement: newElement];
                    _lastMousePoint = cocoaPoint;
                }
        }
    }
}

- (AXUIElementRef)AXWindow:(AXUIElementRef)element
{
    if ([UIElementUtilities isWindowUIElement: element])
        return element;
        
    id value = [UIElementUtilities valueOfAttribute: @"AXWindow" ofUIElement:element];
    if (value)
        return (AXUIElementRef)value;
    return NULL;
}

- (AXUIElementRef)AXParent:(AXUIElementRef)element
{
    if ([UIElementUtilities isApplicationUIElement: element])
        return element;
    
    id value = [UIElementUtilities valueOfAttribute: @"AXParent" ofUIElement:element];
    if (value)
        return (AXUIElementRef)value;
    return NULL;
}

#pragma mark - 
- (void)setCurrentUIElement:(AXUIElementRef)uiElement
{
    [(id)_currentUIElement autorelease];
    _currentUIElement = (AXUIElementRef)[(id)uiElement retain];
}
@end
