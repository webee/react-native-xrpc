//
//  RN.h
//  XChatDemo
//
//  Created by webee on 16/10/23.
//  Copyright © 2016年 qqwj.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridge.h"
#import "RNXRPCClient.h"

@interface RN: NSObject

+ (void)setupWithEnv:(NSString *)env launchOptions:(NSDictionary *)launchOptions;
+ (void)setupWithEnv:(NSString*) env andExtraModules:(NSArray<id<RCTBridgeModule>>*)extraModules launchOptions:(NSDictionary *)launchOptions;
+ (RCTBridge*) bridge;
+ (RNXRPCClient*) xrpc;
+ (RNXRPCClient*) newXrpc:(NSDictionary*)context;
@end
