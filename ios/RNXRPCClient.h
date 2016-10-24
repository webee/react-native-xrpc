//
//  RNXRPCClient.h
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//
#import "RCTBridge.h"
#import "RNXRPC.h"

@interface RNXRPCClient: NSObject

- (instancetype) initWithReactBridge:(RCTBridge*)bridge;

- (void) emit:(NSString*)event args:(NSArray*)args kwargs:(NSDictionary*)kwargs;

- (NSString*) sub:(NSString*)event onEvent:(RNXRPCOnEventBlock)onEvent;
- (void) unsub:(NSString*)event subID:(NSString*)subID;

- (void) call:(NSString*)proc args:(NSArray*)args kwargs:(NSDictionary*)kwargs onReply:(RNXRPCOnReplyBlock)onReply;

- (void) register:(NSString*)proc procedure:(RNXRPCProcedureBlock)procedure;
@end
