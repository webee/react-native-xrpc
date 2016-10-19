#import "RNXRPC.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

@implementation RNXRPC

@synthesize bridge = _bridge;


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
    RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}

@end
  
