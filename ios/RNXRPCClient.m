//
//  RNXRPCClient.m
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//
#import "RNXRPCClient.h"
#import "RCTEventDispatcher.h"
#import "RNXRPC.h"

@interface RNXRPCClient()

@property (nonatomic, strong) RCTBridge* bridge;
@property (nonatomic, strong) NSDictionary* defaultContext;

@end

@implementation RNXRPCClient
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

- (void) emit:(NSString*)event args:(NSArray*)args kwargs:(NSDictionary*)kwargs {
    [self emit:event context:_defaultContext args:args kwargs:kwargs];
}

- (void) emit:(NSString*)event context:(NSDictionary*)context args:(NSArray*)args kwargs:(NSDictionary*)kwargs {
    context = context == nil ? @{} : context;
    args = args == nil ? @[] : args;
    kwargs = kwargs == nil ? @{} : kwargs;
    NSArray* data = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:XRPC_EVENT_EVENT], event, context, args, kwargs];
    [self.bridge.eventDispatcher sendAppEventWithName:XRPC_EVENT body:data];
}

- (NSString*) sub:(NSString*)event onEvent:(RNXRPCOnEventBlock)onEvent {
    return [RNXRPC subscribe:event subscriber:onEvent];
}

- (void) unsub:(NSString*)event subID:(NSString*)subID {
    [RNXRPC unsubscribe:event subID:subID];
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
    NSArray* data = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:XRPC_EVENT_CALL], rid, proc, context, args, kwargs];
    [self.bridge.eventDispatcher sendAppEventWithName:XRPC_EVENT body:data];
}

- (void) register:(NSString*)proc procedure:(RNXRPCProcedureBlock)procedure {
    // TODO:
}

@end
