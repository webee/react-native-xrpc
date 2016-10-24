//
//  RNBridgeDelegate.h
//  XChatDemo
//
//  Created by webee on 16/10/23.
//  Copyright © 2016年 qqwj.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeDelegate.h"

@interface RNBridgeDelegate: NSObject <RCTBridgeDelegate>
- (instancetype)initWithEnv:(NSString*)env;
- (instancetype)initWithEnv:(NSString*)env andExtraModules:(NSArray<id<RCTBridgeModule>>*)extranModules;
- (instancetype)initWithEnv:(NSString*)env andPort:(NSInteger)port andExtraModules:(NSArray<id<RCTBridgeModule>>*)extranModules;
@end
