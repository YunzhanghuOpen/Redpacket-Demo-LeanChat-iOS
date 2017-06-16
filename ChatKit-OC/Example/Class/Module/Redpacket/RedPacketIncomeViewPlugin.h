//
//  RedPacketIncomeViewPlugin.h
//  ChatKit-OC
//
//  Created by Mr.Yan on 2017/6/5.
//  Copyright © 2017年 ElonChan. All rights reserved.
//

#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@interface RedPacketIncomeViewPlugin : LCCKInputViewPlugin<LCCKInputViewPluginSubclassing>

@property (nonatomic, weak) LCCKChatBar *inputViewRef;

@end
