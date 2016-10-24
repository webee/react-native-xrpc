//
//  RNXRPCRequest.h
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//
#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import "RCTBridge.h"

@interface RNXRPCRequest: NSObject

@property (nonatomic, strong, readonly) RCTBridge* bridge;
@property (nonatomic, strong, readonly) NSArray* args;
@property (nonatomic, strong, readonly) NSDictionary* kwargs;
@property (nonatomic, strong, readonly) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong, readonly) RCTPromiseRejectBlock reject;

- (instancetype)initWithArgs:(RCTBridge*)bridge args:(NSArray*)args kwargs:(NSDictionary*)kwargs
                    resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
@end
