//
//  RNXRPCRequest.m
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//

#import "RNXRPCRequest.h"

@implementation RNXRPCRequest

- (instancetype)initWithArgs:(RCTBridge*)bridge args:(NSArray*)args kwargs:(NSDictionary*)kwargs
            resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    if (self = [super init]) {
        _bridge = bridge;
        _args = args;
        _kwargs = kwargs;
        _resolve = resolve;
        _reject = reject;
    }
    return self;
}

@end
