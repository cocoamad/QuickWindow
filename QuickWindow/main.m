//
//  main.m
//  QuickWindow
//
//  Created by Penny on 13-1-19.
//  Copyright (c) 2013年 Penny. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void registerUserDefault()
{
    [[NSUserDefaults standardUserDefaults] registerDefaults: @{@"today" : @0, @"total" : @0,
     @"IndicationWindowColor" : @{@"r" : @0., @"g" : @0., @"b" : @0.}, @"startLoginIn" : @NO}];
}

int main(int argc, char *argv[])
{
    registerUserDefault();
    return NSApplicationMain(argc, (const char **)argv);
}
