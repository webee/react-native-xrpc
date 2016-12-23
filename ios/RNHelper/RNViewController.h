//
//  RNViewController.h
//  XChatDemo
//
//  Created by webee on 16/10/23.
//  Copyright © 2016年 qqwj.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RNViewController : UIViewController

-(id) initWithModule:(NSString*)moduleName initialProperties:(NSDictionary*)initialProperties;
    
@end
