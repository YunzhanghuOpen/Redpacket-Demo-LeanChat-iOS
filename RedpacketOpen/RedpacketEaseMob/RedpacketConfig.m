//
//  RedpacketConfig.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
#import <UIKit/UIKit.h>
#import "LCCKExampleConstants.h"
#import "RedpacketConfig.h"
#import "RPRedpacketUnionHandle.h"
#import "AppDelegate+RedPacket.h"
#import "AVIMTypedMessageRedPacketTaken.h"
//	*此为演示地址* App需要修改为自己AppServer上的地址, 数据格式参考此地址给出的格式。
static NSString *requestUrl = @"https://rpv2.yunzhanghu.com/api/sign?duid=";//服务端的同学需要参考（https://docs.yunzhanghu.com/intro/server.html）

@interface RedpacketConfig ()

@end

@implementation RedpacketConfig

+ (instancetype)sharedConfig {
    static RedpacketConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[RedpacketConfig alloc] init];
        [RPRedpacketBridge sharedBridge].delegate = config;
        [RPRedpacketBridge sharedBridge].isDebug = YES;//开发者调试的的时候，设置为YES，看得见日志。
    });
    return config;
}

- (RPUserInfo *)redpacketUserInfo {
    NSUserDefaults *defaultsGet = [NSUserDefaults standardUserDefaults];
    NSString *clientId = [defaultsGet stringForKey:LCCK_KEY_USERID];
    NSString *avatarURL;
    NSString * userName;
    for (NSDictionary *user in LCCKContactProfiles) {
        if ([clientId isEqualToString:user[LCCKProfileKeyPeerId]]) {
            avatarURL = user[LCCKProfileKeyAvatarURL];
            userName = user[LCCKProfileKeyName];
        }
    }
    RPUserInfo *user = [[RPUserInfo alloc] init];
    user.userID = clientId;
    user.userName = userName.length?userName:clientId;
    user.avatar = avatarURL;
    return user;
}

- (void)lcck_setting {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LCCKFilterMessagesBlock filterMessagesBlock = [LCCKConversationService sharedInstance].filterMessagesBlock;
        [[LCChatKit sharedInstance] setFilterMessagesBlock:^(AVIMConversation *conversation, NSArray<AVIMTypedMessage *> *messages, LCCKFilterMessagesCompletionHandler completionHandler) {
            NSMutableArray * messageArray = [messages mutableCopy];
            [messages enumerateObjectsUsingBlock:^(AVIMTypedMessage *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj isKindOfClass:[AVIMTypedMessageRedPacketTaken class]]) {
                    AnalysisRedpacketModel * rpModel = [AnalysisRedpacketModel analysisRedpacketWithDict:obj.attributes andIsSender:YES];
                    if (![rpModel.sender.userID isEqualToString:self.redpacketUserInfo.userID] &&
                        ![rpModel.receiver.userID isEqualToString:self.redpacketUserInfo.userID] )
                    {
                        [messageArray removeObject:obj];
                    }
                }
            }];
            
            if (filterMessagesBlock) {
                filterMessagesBlock(conversation,messageArray,completionHandler);
            } else {
                completionHandler([messageArray copy], nil);
            }
        }];
    });
}

//红包token任何注册问题都会走此接口
- (void)redpacketFetchRegisitParam:(RPFetchRegisitParamBlock)fetchBlock withError:(NSError *)error {
    NSString *userId = self.redpacketUserInfo.userID;
    if(userId) {
        // 获取应用自己的签名字段。实际应用中需要开发者自行提供相应在的签名计算服务
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",requestUrl, userId];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [[[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSError * jsonError;
                NSDictionary * jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                if (!jsonError && [jsonObject isKindOfClass:[NSDictionary class]]) {
                    NSString *partner = [jsonObject valueForKey:@"partner"];
                    NSString *appUserId = [jsonObject valueForKey:@"user_id"];
                    NSString *timeStamp = [jsonObject valueForKey:@"timestamp"];
                    NSString *sign = [jsonObject valueForKey:@"sign"];
                    RPRedpacketRegisitModel *model = [RPRedpacketRegisitModel signModelWithAppUserId:appUserId
                                                                                          signString:sign
                                                                                             partner:partner
                                                                                        andTimeStamp:timeStamp];
                    fetchBlock(model);
                }
            }
        }] resume];
    }
}



@end
