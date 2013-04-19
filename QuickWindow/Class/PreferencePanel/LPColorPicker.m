//
//  LPColorPicker.m
//  QuickWindow
//
//  Created by Penny on 31/01/13.
//  Copyright (c) 2013 Penny. All rights reserved.
//

#import "LPColorPicker.h"
#import "Utities.h"

@interface LPColorPicker ()
@property(assign) BOOL mouseDown;
@property(nonatomic, retain) NSColor *selectedColor;
@end

@implementation LPColorPicker

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame: frameRect]) {
    }
    return self;
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(colorChanged:) name: NSColorPanelColorDidChangeNotification object: Nil];
    NSDictionary *colorDict = [[NSUserDefaults standardUserDefaults] objectForKey: @"IndicationWindowColor"];
    if (colorDict) {
        self.selectedColor = [NSColor colorWithDeviceRed: [[colorDict objectForKey: @"r"] floatValue] green: [[colorDict objectForKey: @"g"]floatValue]
                                                    blue: [[colorDict objectForKey: @"b"] floatValue] alpha: 1];
        if (self.selectedColor == Nil) {
            self.selectedColor = [NSColor blackColor];
        }
    }

}


- (void)mouseDown:(NSEvent *)theEvent
{
    _mouseDown = YES;
    [self setNeedsDisplay: YES]; 
}

- (void)mouseUp:(NSEvent *)theEvent
{
    _mouseDown = NO;
    [self setNeedsDisplay: YES];

    NSPoint point = [self convertPoint: [theEvent locationInWindow] fromView: nil];
    if (NSPointInRect(point, self.bounds)) {
        [[NSApplication sharedApplication] orderFrontColorPanel: self];
    }
}

- (void)colorChanged:(NSNotification*)n
{
    NSColorPanel *colorPanel = [n object];
    self.selectedColor = [colorPanel color];
    [[NSUserDefaults standardUserDefaults] setObject: @{@"r" : @(self.selectedColor.redComponent), @"g" : @(self.selectedColor.greenComponent), @"b" : @(self.selectedColor.blueComponent)} forKey: @"IndicationWindowColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setNeedsDisplay: YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [NSGraphicsContext currentContext].graphicsPort;
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, [NSColor colorWithCalibratedRed: 130.0/255 green: 130.0/255 blue: 130.0/255 alpha: 1].CGColorRef);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddRect(ctx, self.bounds);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [NSColor colorWithCalibratedRed: 230.0/255 green: 230.0/255 blue: 230.0/255 alpha: 1].CGColorRef);
    CGContextAddRect(ctx, NSInsetRect(self.bounds, 1, 1));
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    

    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, self.selectedColor.CGColorRef);
    CGContextAddRect(ctx, NSInsetRect(self.bounds, 4, 4));
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    if (_mouseDown) {
        CGContextSaveGState(ctx);
        CGContextSetAlpha(ctx, .1);
        CGContextSetFillColorWithColor(ctx, [NSColor blackColor].CGColorRef);
        CGContextAddRect(ctx, self.bounds);
        CGContextFillPath(ctx);
        CGContextRestoreGState(ctx);
    }
    
    
}
@end
