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

@end

@implementation RNXRPCClient
- (instancetype) initWithReactBridge:(RCTBridge*)bridge {
    if (self = [super init]) {
        _bridge = bridge;
    }
    return self;
}

- (void) emit:(NSString*)event args:(NSArray*)args kwargs:(NSDictionary*)kwargs {
    NSArray* data = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:XRPC_EVENT_EVENT], event, args, kwargs];
    [self.bridge.eventDispatcher sendAppEventWithName:XRPC_EVENT body:data];
}

- (NSString*) sub:(NSString*)event onEvent:(RNXRPCOnEventBlock)onEvent {
    return [RNXRPC subscribe:event subscriber:onEvent];
}

- (void) unsub:(NSString*)event subID:(NSString*)subID {
    [RNXRPC unsubscribe:event subID:subID];
}

- (void) call:(NSString*)proc args:(NSArray*)args kwargs:(NSDictionary*)kwargs onReply:(RNXRPCOnReplyBlock)onReply {
    NSString* rid = [[NSUUID UUID] UUIDString];
    [RNXRPC request:rid onReply:onReply];
    NSArray* data = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:XRPC_EVENT_CALL], rid, proc, args, kwargs];
    [self.bridge.eventDispatcher sendAppEventWithName:XRPC_EVENT body:data];
}

- (void) register:(NSString*)proc procedure:(RNXRPCProcedureBlock)procedure {
}

@end
