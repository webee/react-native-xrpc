//
// Created by webee on 16/12/22.
//

#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>


@interface RNXRPCEventEmitter : RCTEventEmitter
- (void)sendEvent:(id)event;
@end