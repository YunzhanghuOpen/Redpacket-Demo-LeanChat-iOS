//
//  AVIMTypedMessageRedPacket.h
//  ChatKit-OC
//
//  Created by 都基鹏 on 16/8/16.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
#import "RPRedpacketModel.h"
#import "RPRedpacketUnionHandle.h"

@interface AVIMTypedMessageRedPacket : AVIMTypedMessage<AVIMTypedMessageSubclassing>

/**
 *  红包相关数据模型
 */
@property (nonatomic,strong) RPRedpacketModel * rpModel;

@property (nonatomic,strong) AnalysisRedpacketModel *annlysisModel;

@end
