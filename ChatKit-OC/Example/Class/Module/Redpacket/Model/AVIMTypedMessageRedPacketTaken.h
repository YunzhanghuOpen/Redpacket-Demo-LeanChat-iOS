//
//  RedpacketTakenMessage.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-5-3.
//  Copyright © 2016年 云帐户. All rights reserved.
//
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#import "AnalysisRedpacketModel.h"

@interface AVIMTypedMessageRedPacketTaken : AVIMTypedMessage<AVIMTypedMessageSubclassing>

/**
 *  红包相关数据模型
 */
@property (nonatomic,strong) AnalysisRedpacketModel * rpModel;

/**
 *  初始胡抢红包消息
 *
 *  @param clientId         会话ID
 *  @param conversationType 会话类型
 *  @param members          接收人IDs
 */
- (instancetype)initWithClientId:(NSString *)clientId ConversationType:(LCCKConversationType)conversationType receiveMembers:(NSArray<NSString*>*)members;

@end
