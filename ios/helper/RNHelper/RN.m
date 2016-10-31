//
//  RN.m
//  XChatDemo
//
//  Created by webee on 16/10/23.
//  Copyright © 2016年 qqwj.com. All rights reserved.
//
#import "RN.h"
#import "RNBridgeDelegate.h"

@implementation RN

static RCTBridge* bridge;
static RNXRPCClient* xrpc;


+ (void)setupWithEnv:(NSString*) env launchOptions:(NSDictionary *)launchOptions {
    [RN setupWithEnv:env andExtraModules:nil launchOptions:launchOptions];
}

+ (void)setupWithEnv:(NSString*) env andExtraModules:(NSArray<id<RCTBridgeModule>>*)extraModules launchOptions:(NSDictionary *)launchOptions {
    bridge = [[RCTBridge alloc]
              initWithDelegate:[[RNBridgeDelegate alloc] initWithEnv:env andExtraModules:extraModules]
              launchOptions: launchOptions];
    xrpc = [[RNXRPCClient alloc] initWithReactBridge:bridge];
}
    
+ (RCTBridge*) bridge {
    return bridge;
}

+ (RNXRPCClient*) xrpc{
    return xrpc;
}

+ (RNXRPCClient*) newXrpc:(NSDictionary*)context {
    return [[RNXRPCClient alloc] initWithReactBridge:bridge andDefaultContext:context];
}
@end
