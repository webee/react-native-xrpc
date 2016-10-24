//
//  XRPC.h
//  RNXRPC
//
//  Created by webee on 16/10/20.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "RNXRPCEvent.h"
#import "RNXRPCReply.h"
#import "RNXRPCError.h"
#import "RNXRPCRequest.h"

typedef void (^RNXRPCOnReplyBlock)(RNXRPCReply* reply, RNXRPCError* error);
typedef void (^RNXRPCProcedureBlock)(RNXRPCRequest* request);
typedef void (^RNXRPCOnEventBlock)(RNXRPCEvent* event);

@interface RNXRPC: NSObject <RCTBridgeModule>

extern NSString* const XRPC_EVENT;
extern NSInteger const XRPC_EVENT_CALL;
extern NSInteger const XRPC_EVENT_REPLY;
extern NSInteger const XRPC_EVENT_REPLY_ERROR;
extern NSInteger const XRPC_EVENT_EVENT;

- (instancetype) initWithExtraConstants:(NSDictionary*)constants;

+ (NSString*) subscribe:(NSString*)event subscriber:(RNXRPCOnEventBlock)subscriber;
+ (void) unsubscribe:(NSString*)event subID:(NSString*)subID;
+ (void) request:(NSString*)rid onReply:(RNXRPCOnReplyBlock)onReply;
@end
