//
//  RedpacketConfig.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPRedpacketBridge.h"

@interface RedpacketConfig : NSObject <RPRedpacketBridgeDelegate>

+ (instancetype)sharedConfig;
/**
 *  获取当前红包用户
 */
- (RPUserInfo *)redpacketUserInfo;
/**
 *  设置消息体拦截
 */
- (void)lcck_setting;

@end
