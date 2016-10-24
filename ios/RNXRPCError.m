//
//  RNXRPCError.m
//  RNXRPC
//
//  Created by webee on 16/10/23.
//
//

#import "RNXRPCError.h"

@implementation RNXRPCError

- (instancetype)initWithArgs:(NSString*)error args:(NSArray*)args kwargs:(NSDictionary*)kwargs {
    if (self = [super init]) {
        _error = error;
        _args = args;
        _kwargs = kwargs;
    }
    return self;
}

@end
