//
//  LCCKInputViewPluginTest.m
//  ChatKit-OC
//
//  Created by 都基鹏 on 16/8/16.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import "RedPacketInputViewPlugin.h"
#import "RedpacketViewControl.h"
#import "CYLTabBarController.h"
#import "RedpacketConfig.h"
#import "AVIMTypedMessageRedPacket.h"
#import "LCCKContactManager.h"

@implementation RedPacketInputViewPlugin
@synthesize inputViewRef = _inputViewRef;
@synthesize sendCustomMessageHandler = _sendCustomMessageHandler;

+ (void)load {
    [self registerSubclass];
}

+ (LCCKInputViewPluginType)classPluginType {
    return 3;
}

#pragma mark -
#pragma mark - LCCKInputViewPluginDelegate Method

/*!
 * 插件图标
 */
- (UIImage *)pluginIconImage {
    return [self imageInBundlePathForImageName:@"redpacket_redpacket"];
}

/*!
 * 插件名称
 */
- (NSString *)pluginTitle {
    return @"红包";
}

/*!
 * 插件对应的 view，会被加载到 inputView 上
 */
- (UIView *)pluginContentView {
    return nil;
}

- (void)pluginDidClicked {
     AVIMConversation *conversation = [self.conversationViewController getConversationIfExists];
     RPUserInfo * userInfo = [RPUserInfo new];
     RPRedpacketControllerType rptype;
     if (conversation.members.count > 2) {
        userInfo.userID = self.conversationViewController.conversationId;
        rptype = RPRedpacketControllerTypeGroup;
         [self clickRedpacketBtnWith:rptype membersCount:conversation.members.count redpacketUserInfo:userInfo];
     } else {
        rptype = RPRedpacketControllerTypeSingle;
        NSError * error;
        NSArray<id<LCCKUserDelegate>> *users = [[LCChatKit sharedInstance] getCachedProfilesIfExists:conversation.members shouldSameCount:YES error:&error];
        if (users.count && !error) {
            [users enumerateObjectsUsingBlock:^(id<LCCKUserDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![[RedpacketConfig sharedConfig].redpacketUserInfo.userID isEqualToString:[obj userId]]) {
                    userInfo.userID = [obj userId];
                    userInfo.userName = obj.name.length?obj.name:obj.userId;
                    userInfo.avatar = obj.avatarURL.absoluteString;
                    [self clickRedpacketBtnWith:rptype membersCount:0 redpacketUserInfo:userInfo];
                }
            }];
        }
    }
    
    }

- (void)clickRedpacketBtnWith:(RPRedpacketControllerType)redpacketControllerType membersCount:(NSUInteger)membersCount redpacketUserInfo:(RPUserInfo *)redpacketUserInfo
{
    [RedpacketViewControl presentRedpacketViewController:redpacketControllerType
                                         fromeController:self.conversationViewController
                                        groupMemberCount:membersCount
                                   withRedpacketReceiver:redpacketUserInfo
                                         andSuccessBlock:^(RPRedpacketModel *model) {
                                             [self sendRedpacketMessage:model];
                                         } withFetchGroupMemberListBlock:^(RedpacketMemberListFetchBlock fetchFinishBlock) {
                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                 AVIMConversation *conversation = [self.conversationViewController getConversationIfExists];
                                                 NSArray *allPersonIds;
                                                 NSMutableArray * usersArray = [NSMutableArray array];
                                                 if (conversation.lcck_type == LCCKConversationTypeGroup) {
                                                     allPersonIds = conversation.members;
                                                 } else {
                                                     allPersonIds = [[LCCKContactManager defaultManager] fetchContactPeerIds];
                                                 }
                                                 NSError * error;
                                                 NSArray<id<LCCKUserDelegate>> *users = [[LCChatKit sharedInstance] getCachedProfilesIfExists:allPersonIds shouldSameCount:YES error:&error];
                                                 if (users.count && !error) {
                                                     [users enumerateObjectsUsingBlock:^(id<LCCKUserDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                         RPUserInfo * userInfo = [RPUserInfo new];
                                                         userInfo.userID = obj.clientId;
                                                         userInfo.userName = obj.name?obj.name:obj.clientId;
                                                         userInfo.avatar = obj.avatarURL.absoluteString;
                                                         [usersArray addObject:userInfo];
                                                     }];
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         fetchFinishBlock(usersArray);
                                                     });
                                                 }
                                             });

                                         }];
 
}

// 发送红包消息
- (void)sendRedpacketMessage:(RPRedpacketModel *)redpacket {
    AVIMTypedMessageRedPacket * message = [[AVIMTypedMessageRedPacket alloc]init];
    message.rpModel = redpacket;
    [self.conversationViewController sendCustomMessage:message];
}

#pragma mark -
#pragma mark - Private Methods

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"RedpacketCellResource" bundleForClass:[self class]];
    return image;
}

@end
