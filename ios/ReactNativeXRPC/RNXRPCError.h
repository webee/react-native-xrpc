//
//  RNXRPCError.h
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//
#import <Foundation/Foundation.h>

@interface RNXRPCError: NSObject

@property (nonatomic, strong, readonly) NSString* error;
@property (nonatomic, strong, readonly) NSArray* args;
@property (nonatomic, strong, readonly) NSDictionary* kwargs;

- (instancetype)initWithArgs:(NSString*)error args:(NSArray*)args kwargs:(NSDictionary*)kwargs;

@end
