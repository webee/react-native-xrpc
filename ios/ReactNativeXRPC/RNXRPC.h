//
//  XRPC.h
//  RNXRPC
//
//  Created by webee on 16/10/20.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <ReactiveObjC/RACSubject.h>
#import "RNXRPCEvent.h"
#import "RNXRPCReply.h"
#import "RNXRPCError.h"
#import "RNXRPCRequest.h"

extern NSString* _Nonnull const XRPC_EVENT;
extern NSInteger const XRPC_EVENT_CALL;
extern NSInteger const XRPC_EVENT_REPLY;
extern NSInteger const XRPC_EVENT_REPLY_ERROR;
extern NSInteger const XRPC_EVENT_EVENT;

typedef void (^RNXRPCOnReplyBlock)(RNXRPCReply* _Nonnull reply, RNXRPCError* _Nonnull error);
typedef void (^RNXRPCProcedureBlock)(RNXRPCRequest* _Nonnull request);

@interface RNXRPC: NSObject <RCTBridgeModule>
- (nonnull id) initWithExtraConstants:(nullable NSDictionary*)constants;

+ (nonnull RACSignal *)event;
+ (void) request:(nonnull NSString*)rid onReply:(nonnull RNXRPCOnReplyBlock)onReply;
@end
