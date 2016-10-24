//
//  RNBridgeDelegate.m
//  XChatDemo
//
//  Created by webee on 16/10/23.
//  Copyright © 2016年 qqwj.com. All rights reserved.
//

#import "RNBridgeDelegate.h"
#import "RCTBundleURLProvider.h"

@interface RNBridgeDelegate ()

@property (strong, nonatomic) NSString* env;
@property (nonatomic, assign) NSInteger port;
@property (strong, nonatomic) NSArray<id<RCTBridgeModule>>* extraModules;

@end

@implementation RNBridgeDelegate
- (instancetype)initWithEnv:(NSString *)env {
    return [self initWithEnv:env andExtraModules:nil];
}

- (instancetype)initWithEnv:(NSString*)env andExtraModules:(NSArray<id<RCTBridgeModule>>*)extranModules {
    return [self initWithEnv:env andPort:8081 andExtraModules:extranModules];
}

- (instancetype)initWithEnv:(NSString*)env andPort:(NSInteger)port andExtraModules:(NSArray<id<RCTBridgeModule>>*)extranModules {
    if (self = [super init]) {
        _env = env;
        _port = port;
        if (extranModules != nil) {
            _extraModules = extranModules;
        } else {
            _extraModules = @[];
        }
    }
    return self;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
    if ([_env  isEqual: @"dev"]) {
        NSString* serverURL = [[NSString alloc] initWithFormat:@"http://localhost:%d/index.ios.bundle?platform=ios", _port];
        return [NSURL URLWithString:serverURL];
    } else {
        return [[NSBundle mainBundle] URLForResource:@"./rnbundle/index.ios" withExtension:@"bundle"];
    }
}

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge {
    return _extraModules;
}
@end
