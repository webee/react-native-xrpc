//
//  XRPC.m
//  RNXRPC
//
//  Created by webee on 16/10/20.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "RNXRPC.h"
#import <ReactiveObjC/RACSubject.h>
#import <React/RCTLog.h>

NSString* const XRPC_EVENT = @"__XRPC__";
NSInteger const XRPC_EVENT_CALL = 0;
NSInteger const XRPC_EVENT_REPLY = 1;
NSInteger const XRPC_EVENT_REPLY_ERROR = 2;
NSInteger const XRPC_EVENT_EVENT = 3;

@implementation RNXRPC {
    NSDictionary* _extraConstants;
}
static RACSubject *__eventSubject;
static NSMutableDictionary<NSString*, RNXRPCOnReplyBlock>* requests;
static NSLock* reqLock;

@synthesize bridge = _bridge;

+ (void)initialize {
    __eventSubject = [RACSubject subject];

    requests = [NSMutableDictionary new];
    reqLock = [[NSLock alloc] init];
}

- (id) init {
    return [self initWithExtraConstants:nil];
}

- (id) initWithExtraConstants:(NSDictionary*)constants {
    if (self = [super init]) {
        if (constants != nil) {
            _extraConstants = constants;
        } else {
            _extraConstants = @{};
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
              @"_EVENT_CALL": @(XRPC_EVENT_CALL),
              @"_EVENT_REPLY": @(XRPC_EVENT_REPLY),
              @"_EVENT_REPLY_ERROR": @(XRPC_EVENT_REPLY_ERROR),
              @"_EVENT_EVENT": @(XRPC_EVENT_EVENT),
              @"C": _extraConstants
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
    // TODO: 接受call
    RCTLog(@"call %@, %@, %@", proc, args, kwargs);
}

- (void) handleEvent:(NSArray*)xargs {
    NSString* event = xargs[0];
    NSArray* args = xargs[1];
    NSDictionary* kwargs = xargs[2];
    [__eventSubject sendNext:[[RNXRPCEvent alloc] initWithArgs:_bridge event:event args:args kwargs:kwargs]];
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

+ (nonnull RACSignal<RNXRPCEvent *> *)event {
    return (RACSignal<RNXRPCEvent *> *) __eventSubject;
}

+ (void) request:(NSString*)rid onReply:(RNXRPCOnReplyBlock)onReply {
    [reqLock lock];
    requests[rid] = onReply;
    [reqLock unlock];
}
@end
