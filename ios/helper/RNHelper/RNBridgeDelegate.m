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
@property (strong, nonatomic) NSArray<id<RCTBridgeModule>>* extraModules;

@end

@implementation RNBridgeDelegate
- (instancetype)initWithEnv:(NSString *)env {
    return [self initWithEnv:env andExtraModules:nil];
}

- (instancetype)initWithEnv:(NSString*)env andExtraModules:(NSArray<id<RCTBridgeModule>>*)extranModules {
    if (self = [super init]) {
        _env = env;
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
        return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:@"rnbundle/index.ios"];
    } else {
        return [[NSBundle mainBundle] URLForResource:@"./rnbundle/index.ios" withExtension:@"jsbundle"];
    }
}

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge {
    return _extraModules;
}
@end
