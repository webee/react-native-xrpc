//
//  RNXRPCClient.m
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//
#import <React/RCTEventDispatcher.h>
#import "RNXRPCClient.h"
#import "RNXRPCEventEmitter.h"

@implementation RNXRPCClient {
    RCTBridge* _bridge;
    NSDictionary* _defaultContext;
}

- (instancetype) initWithReactBridge:(RCTBridge*)bridge {
    return [self initWithReactBridge:bridge andDefaultContext:nil];
}

- (instancetype) initWithReactBridge:(RCTBridge*)bridge andDefaultContext:(NSDictionary*)context {
    if (self = [super init]) {
        _bridge = bridge;
        _defaultContext = context;
    }
    return self;
}

- (void) setDefaultContext:(NSDictionary*)context {
    _defaultContext = context;
}

- (NSDictionary *) getDefaultContext {
    return _defaultContext;
}

- (void) emit:(nonnull NSString*)event args:(nullable NSArray*)args kwargs:(nullable NSDictionary*)kwargs {
    [self emit:event context:_defaultContext args:args kwargs:kwargs];
}

- (void) emit:(nonnull NSString*)event
      context:(nullable NSDictionary*)context
         args:(nullable NSArray*)args
       kwargs:(nullable NSDictionary*)kwargs {
    context = context == nil ? @{} : context;
    args = args == nil ? @[] : args;
    kwargs = kwargs == nil ? @{} : kwargs;
    NSArray* data = @[@(XRPC_EVENT_EVENT), event, context, args, kwargs];
    [[_bridge moduleForClass:[RNXRPCEventEmitter class]] sendEvent:data];
}

- (nonnull RACSignal<RNXRPCEvent *> *) sub:(nonnull NSString*)event {
    return [[RNXRPC event] filter:^(RNXRPCEvent *e) {
        return [e.event isEqualToString:event];
    }];
}

- (void) call:(NSString*)proc args:(NSArray*)args kwargs:(NSDictionary*)kwargs onReply:(RNXRPCOnReplyBlock)onReply {
    [self call:proc context:_defaultContext args:args kwargs:kwargs onReply:onReply];
}

- (void) call:(NSString*)proc context:(NSDictionary*)context args:(NSArray*)args kwargs:(NSDictionary*)kwargs onReply:(RNXRPCOnReplyBlock)onReply {
    NSString* rid = [[NSUUID UUID] UUIDString];
    [RNXRPC request:rid onReply:onReply];
    context = context == nil ? @{} : context;
    args = args == nil ? @[] : args;
    kwargs = kwargs == nil ? @{} : kwargs;
    NSArray* data = @[@(XRPC_EVENT_CALL), rid, proc, context, args, kwargs];
    [[_bridge moduleForClass:[RNXRPCEventEmitter class]] sendEvent:data];
}

- (void) register:(NSString*)proc procedure:(RNXRPCProcedureBlock)procedure {
    // TODO:
}

@end
