//
// Created by webee on 16/12/22.
//

#import <React/RCTAssert.h>
#import "RNXRPCEventEmitter.h"
#import "RNXRPC.h"


@implementation RNXRPCEventEmitter

RCT_EXPORT_MODULE(XRPCEventEmitter);

- (void)sendEventWithName:(NSString *)eventName body:(id)body {
    RCTAssert(self.bridge != nil, @"bridge is not set. This is probably because you've "
              "explicitly synthesized the bridge in %@, even though it's inherited "
              "from RCTEventEmitter.", [self class]);
    
    [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                        method:@"emit"
                          args:body ? @[eventName, body] : @[eventName]
                    completion:NULL];
}

- (void)sendEvent:(id)event {
    [self sendEventWithName:XRPC_EVENT body:event];
}
/**
 * Override this method to return an array of supported event names. Attempting
 * to observe or send an event that isn't included in this list will result in
 * an error.
 */
- (NSArray<NSString *> *)supportedEvents {
    return @[XRPC_EVENT];
}

/**
 * These methods will be called when the first observer is added and when the
 * last observer is removed (or when dealloc is called), respectively. These
 * should be overridden in your subclass in order to start/stop sending events.
 */
- (void)startObserving {
}

- (void)stopObserving {
}
@end
