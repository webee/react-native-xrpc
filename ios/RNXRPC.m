//
//  XRPC.m
//  RNXRPC
//
//  Created by webee on 16/10/20.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "RNXRPC.h"
#import "RNXRPCEvent.h"
#import "RCTLog.h"

@interface RNXRPC()
@end

@implementation RNXRPC

NSString* const XRPC_EVENT = @"__XRPC__";
NSInteger const XRPC_EVENT_CALL = 0;
NSInteger const XRPC_EVENT_REPLY = 1;
NSInteger const XRPC_EVENT_REPLY_ERROR = 2;
NSInteger const XRPC_EVENT_EVENT = 3;

static NSDictionary* extraConstants;

static NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, RNXRPCOnEventBlock>*>* subscribers;
static NSLock* subLock;
static NSMutableDictionary<NSString*, RNXRPCOnReplyBlock>* requests;
static NSLock* reqLock;

@synthesize bridge = _bridge;

+ (void)initialize {
    extraConstants = @[];
    subscribers = [NSMutableDictionary new];
    subLock = [[NSLock alloc] init];
    
    requests = [NSMutableDictionary new];
    reqLock = [[NSLock alloc] init];
}

- (instancetype) init {
    return [self initWithExtraConstants:nil];
}

- (instancetype) initWithExtraConstants:(NSDictionary*)constants {
    if (self = [super init]) {
        if (constants != nil) {
            extraConstants = constants;
        }
    }
    return self;
}

RCT_EXPORT_MODULE(XRPC);

- (dispatch_queue_t)methodQueue {
    return dispatch_queue_create("com.webee.react.XRPCStorageQueue", DISPATCH_QUEUE_SERIAL);
}

- (NSDictionary *)constantsToExport {
    return @{ @"_XRPC_EVENT": XRPC_EVENT,
              @"_EVENT_CALL": [NSNumber numberWithInteger:XRPC_EVENT_CALL],
              @"_EVENT_REPLY": [NSNumber numberWithInteger:XRPC_EVENT_REPLY],
              @"_EVENT_REPLY_ERROR": [NSNumber numberWithInteger:XRPC_EVENT_REPLY_ERROR],
              @"_EVENT_EVENT": [NSNumber numberWithInteger:XRPC_EVENT_EVENT],
              @"C": extraConstants
              };
}

RCT_EXPORT_METHOD(emit:(NSInteger)event args:(NSArray *)args) {
    switch (event) {
        case XRPC_EVENT_REPLY:
            [self handleCallReply:args];
            break;
        case XRPC_EVENT_REPLY_ERROR:
            [self handleCallReplyError:args];
            break;
        case XRPC_EVENT_EVENT:
            [self handleEvent:args];
            break;
        default:
            break;
    }
}

RCT_EXPORT_METHOD(call:(NSString *)proc args:(NSArray *)args kwargs:(NSDictionary *)kwargs
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    RCTLog(@"call %@, %@, %@", proc, args, kwargs);
}

- (void) handleEvent:(NSArray*)xargs {
    NSString* event = xargs[0];
    NSArray* args = xargs[1];
    NSDictionary* kwargs = xargs[2];
    [subLock lock];
    NSMutableDictionary<NSString*, RNXRPCOnEventBlock>* subs = subscribers[event];
    [subLock unlock];
    if (subs == nil || [subs count] < 1) {
        return;
    }
    for (NSString* subID in subs) {
        RNXRPCOnEventBlock sub = subs[subID];
        if (sub != nil) {
            sub([[RNXRPCEvent alloc] initWithArgs:_bridge args:args kwargs:kwargs]);
        }
    }
}

+ (NSString*) subscribe:(NSString*)event subscriber:(RNXRPCOnEventBlock)subscriber {
    NSString* subID = [[NSUUID UUID] UUIDString];
    [subLock lock];
    NSMutableDictionary<NSString*, RNXRPCOnEventBlock>* subs = subscribers[event];
    if (subs == nil) {
        subs = [NSMutableDictionary new];
        subscribers[event] = subs;
    }
    subs[event] = subscriber;
    [subLock unlock];
    return subID;
}

+ (void) unsubscribe:(NSString*)event subID:(NSString*)subID {
    [subLock lock];
    NSMutableDictionary<NSString*, RNXRPCOnEventBlock>* subs = subscribers[event];
    if (subs != nil) {
        [subs removeObjectForKey:subID];
    }
    [subLock unlock];
}

- (void) handleCallReply:(NSArray*)xargs {
    NSString* rid = xargs[0];
    [reqLock lock];
    RNXRPCOnReplyBlock onReply = requests[rid];
    if (onReply == nil) {
        return;
    }
    [requests removeObjectForKey:rid];
    [reqLock unlock];
    NSArray* args = xargs[1];
    NSDictionary* kwargs = xargs[2];
    
    onReply([[RNXRPCReply alloc] initWithArgs:args kwargs:kwargs], nil);
}

- (void) handleCallReplyError:(NSArray*)xargs {
    NSString* rid = xargs[0];
    [reqLock lock];
    RNXRPCOnReplyBlock onReply = requests[rid];
    if (onReply == nil) {
        return;
    }
    [requests removeObjectForKey:rid];
    [reqLock unlock];
    NSString* err = xargs[1];
    NSArray* args = xargs[2];
    NSDictionary* kwargs = xargs[3];
    onReply(nil, [[RNXRPCError alloc] initWithArgs:err args:args kwargs:kwargs]);
}

+ (void) request:(NSString*)rid onReply:(RNXRPCOnReplyBlock)onReply {
    [reqLock lock];
    requests[rid] = onReply;
    [reqLock unlock];
}

@end
