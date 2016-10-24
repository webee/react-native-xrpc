//
//  Reply.h
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//
#import <Foundation/Foundation.h>

@interface RNXRPCReply: NSObject

@property (nonatomic, strong, readonly) NSArray* args;
@property (nonatomic, strong, readonly) NSDictionary* kwargs;

- (instancetype)initWithArgs:(NSArray*)args kwargs:(NSDictionary*)kwargs;
@end
