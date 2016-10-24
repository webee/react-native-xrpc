//
//  RNXRPCEvent.h
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//

#import <Foundation/Foundation.h>
#import "RCTBridge.h"

@interface RNXRPCEvent: NSObject

@property (nonatomic, strong, readonly) RCTBridge* bridge;
@property (nonatomic, strong, readonly) NSArray* args;
@property (nonatomic, strong, readonly) NSDictionary* kwargs;

- (instancetype)initWithArgs:(RCTBridge*)bridge args:(NSArray*)args kwargs:(NSDictionary*)kwargs;
@end
