//
//  RNXRPCEvent.h
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>

@interface RNXRPCEvent: NSObject

@property (nonatomic, weak, readonly) RCTBridge* bridge;
@property (nonatomic, strong, readonly) NSString* event;
@property (nonatomic, strong, readonly) NSArray* args;
@property (nonatomic, strong, readonly) NSDictionary* kwargs;

- (instancetype)initWithArgs:(RCTBridge*)bridge event:(NSString*)event args:(NSArray*)args kwargs:(NSDictionary*)kwargs;
@end
