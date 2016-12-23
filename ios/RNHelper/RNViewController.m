//
//  RNViewController.m
//  XChatDemo
//
//  Created by webee on 16/10/23.
//  Copyright © 2016年 qqwj.com. All rights reserved.
//

#import "RNViewController.h"
#import <React/RCTRootView.h>
#import "RN.h"
#import "RACDisposable.h"

@interface RNViewController ()

@property (strong, nonatomic) NSString* appInstID;

@end

static NSString* const APP_INST_ID_PROP = @"appInstID";
static NSString* const APP_EXIT_EVENT = @"native.app.exit";

@implementation RNViewController {
    RACDisposable* _subAppExit;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) dealloc {
    [_subAppExit dispose];
}

-(id) init {
    if (self = [super init]) {
        _appInstID = [[NSUUID UUID] UUIDString];
        __weak RNViewController* weakSelf = self;
        // subscribe exit app event.
        _subAppExit = [[[RN xrpc] sub:APP_EXIT_EVENT] subscribeNext:^(RNXRPCEvent *e) {
            id aid = e.args[0];
            if (aid == nil || aid == [NSNull null]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.navigationController) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    } else {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                });
            } else if ([weakSelf.appInstID isEqualToString:aid]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.navigationController) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    } else {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                });
            }
        }];
    }
    return self;
}

-(id) initWithModule:(NSString*)moduleName initialProperties:(NSDictionary*)initialProperties {
    if (self = [self init]) {
        NSMutableDictionary* props = [[NSMutableDictionary alloc] initWithDictionary:initialProperties];
        props[APP_INST_ID_PROP] = self.appInstID;
        RCTRootView *rootView = [[RCTRootView alloc] initWithBridge: [RN bridge]
                                                         moduleName: moduleName
                                                  initialProperties: props
                                 ];
        self.view = rootView;
    }
    return self;
}

@end
