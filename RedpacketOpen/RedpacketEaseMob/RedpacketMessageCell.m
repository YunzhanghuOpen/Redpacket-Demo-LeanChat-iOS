//
//  RedpacketMessageCell.m
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
#import "RedpacketMessageCell.h"
#import "AVIMTypedMessageRedPacket.h"
#import "RedpacketViewControl.h"
#import "AVIMTypedMessageRedPacketTaken.h"
#import "RPRedpacketModel.h"
#import "LCCKContactManager.h"
#import "RedpacketConfig.h"
#import "RPRedpacketUnionHandle.h"
static const CGFloat Redpacket_SubMessage_Font_Size = 12.0f;

@interface RedpacketMessageCell()

/**
 *  红包消息体
 */
@property (nonatomic,strong)AVIMTypedMessageRedPacket * rpMessage;


@end

@implementation RedpacketMessageCell

+ (void)load {
    [self registerCustomMessageCell];
}

+ (AVIMMessageMediaType)classMediaType {
    return 3;
}
- (void)setup {
    [self initialize];
    [super setup];
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nickNameLabel];
    [self.contentView addSubview:self.messageContentView];
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.messageContentBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView);
        make.height.equalTo(@(94));
        make.width.equalTo(@(200));
    }];
}

- (void)initialize {
    
    self.messageContentBackgroundImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:self.messageContentBackgroundImageView];
    // 设置红包图标
    UIImage *icon = [self imageNamed:@"redPacket_redPacktIcon" ofBundle:@"RedpacketCellResource.bundle"];
    self.iconView = [[UIImageView alloc] initWithImage:icon];
    [self.messageContentBackgroundImageView addSubview:self.iconView];
    
    // 设置红包文字
    self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.greetingLabel.font = [UIFont systemFontOfSize:14];
    self.greetingLabel.textColor = [UIColor whiteColor];
    self.greetingLabel.numberOfLines = 1;
    [self.greetingLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.greetingLabel setTextAlignment:NSTextAlignmentLeft];
    [self.messageContentBackgroundImageView addSubview:self.greetingLabel];
    
    // 设置次级文字
    self.subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subLabel.text = NSLocalizedString(@"查看红包", @"查看红包");
    self.subLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
    self.subLabel.numberOfLines = 1;
    self.subLabel.textColor = [UIColor whiteColor];
    self.subLabel.numberOfLines = 1;
    [self.subLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.subLabel setTextAlignment:NSTextAlignmentLeft];
    [self.messageContentBackgroundImageView addSubview:self.subLabel];
    
    // 设置次级文字
    self.orgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.orgLabel.text = NSLocalizedString(@"查看红包", @"查看红包");
    self.orgLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
    self.orgLabel.numberOfLines = 1;
    self.orgLabel.textColor = [UIColor lightGrayColor];
    self.orgLabel.numberOfLines = 1;
    [self.orgLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.orgLabel setTextAlignment:NSTextAlignmentLeft];
    [self.messageContentBackgroundImageView addSubview:self.orgLabel];

    // 设置红包厂商图标
    icon = [self imageNamed:@"redPacket_yunAccount_icon" ofBundle:@"RedpacketCellResource.bundle"];
    self.orgIconView = [[UIImageView alloc] initWithImage:icon];
    [self.messageContentBackgroundImageView addSubview:self.orgIconView];
    
    CGRect rt = self.orgIconView.frame;
    rt.origin = CGPointMake(165, 75);
    rt.size = CGSizeMake(21, 14);
    self.orgIconView.frame = rt;
    self.orgLabel.frame = CGRectMake(13, 76, 150, 12);
    self.iconView.frame = CGRectMake(13, 19, 26, 34);
    self.greetingLabel.frame = CGRectMake(48, 19, 137, 15);
    CGRect frame = self.greetingLabel.frame;
    frame.origin.y = 41;
    self.subLabel.frame = frame;
    
    UITapGestureRecognizer *tapGestureRecognizer =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redpacketClicked)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)redpacketClicked {
    if ([self.rpMessage isKindOfClass:[AVIMTypedMessageRedPacket class]]) {
        __weak typeof(self) weakSelf = self;
        AVIMTypedMessageRedPacket * message = (AVIMTypedMessageRedPacket*)self.rpMessage;
        [RedpacketViewControl redpacketTouchedWithMessageModel:message.rpModel
                                            fromViewController:(UIViewController*)self.delegate
                                            redpacketGrabBlock:^(RPRedpacketModel *messageModel) {
                                                [weakSelf onRedpacketTakenMessage:messageModel];
                                            } advertisementAction:^(id args) {
                                                [weakSelf advertisementAction:args];
                                            }];
    }
}

- (void)advertisementAction:(id)args
{
    UIViewController *viewContro = (UIViewController*)self.delegate;
#ifdef AliAuthPay
    /** 营销红包事件处理*/
    RPAdvertInfo *adInfo  =args;
    switch (adInfo.AdvertisementActionType) {
        case RedpacketAdvertisementReceive:
            /** 用户点击了领取红包按钮*/
            break;
            
        case RedpacketAdvertisementAction: {
            /** 用户点击了去看看按钮，进入到商户定义的网页 */
            UIWebView *webView = [[UIWebView alloc] initWithFrame:viewContro.view.bounds];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:adInfo.shareURLString]];
            [webView loadRequest:request];
            
            UIViewController *webVc = [[UIViewController alloc] init];
            [webVc.view addSubview:webView];
            [(UINavigationController *)viewContro.presentedViewController pushViewController:webVc animated:YES];
            
        }
            break;
            
        case RedpacketAdvertisementShare: {
            /** 点击了分享按钮，开发者可以根据需求自定义，动作。*/
            [[[UIAlertView alloc]initWithTitle:nil
                                       message:@"点击「分享」按钮，红包SDK将该红包素材内配置的分享链接传递给商户APP，由商户APP自行定义分享渠道完成分享动作。"
                                      delegate:nil
                             cancelButtonTitle:@"我知道了"
                             otherButtonTitles:nil] show];
        }
            break;
            
        default:
            break;
    }
#else
    NSDictionary *dict =args;
    NSInteger actionType = [args[@"actionType"] integerValue];
    switch (actionType) {
        case 0:
            // 点击了领取红包
            break;
        case 1: {
            // 点击了去看看按钮，此处为演示
            UIViewController     *VC = [[UIViewController alloc]init];
            UIWebView *webView = [[UIWebView alloc]initWithFrame:viewContro.view.bounds];
            [VC.view addSubview:webView];
            NSString *url = args[@"LandingPage"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [webView loadRequest:request];
            [(UINavigationController *)viewContro.presentedViewController pushViewController:VC animated:YES];
        }
            break;
        case 2: {
            // 点击了分享按钮，开发者可以根据需求自定义，动作。
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"点击「分享」按钮，红包SDK将该红包素材内配置的分享链接传递给商户APP，由商户APP自行定义分享渠道完成分享动作。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    
#endif
}

         
         
- (NSString*)clientId {
    NSString * clientID = @"";
    if ([self.delegate isKindOfClass:[LCCKConversationViewController class]]) {
        LCCKConversationViewController * conversationViewController = (LCCKConversationViewController*)self.delegate;
        clientID = conversationViewController.peerId?conversationViewController.peerId:@"";
        clientID = conversationViewController.conversationId?conversationViewController.conversationId:@"";
    }
    return clientID;
}

// 红包被抢消息处理
- (void)onRedpacketTakenMessage:(RPRedpacketModel *)redpacket {
    if (![self.delegate isKindOfClass:[LCCKConversationViewController class]]) return;
    
    LCCKConversationViewController * conversationViewController = (LCCKConversationViewController*)self.delegate;
    if ([[RedpacketConfig sharedConfig].redpacketUserInfo.userID isEqualToString:redpacket.sender.userID]) {//如果发送者是自己
        [conversationViewController sendLocalFeedbackTextMessge:@"您抢了自己的红包"];
    }
    else {
        switch (redpacket.redpacketType) {
            case RPRedpacketTypeSingle:{
                AVIMTypedMessageRedPacketTaken * message = [[AVIMTypedMessageRedPacketTaken alloc]initWithClientId:self.clientId ConversationType:LCCKConversationTypeSingle receiveMembers:@[redpacket.sender.userID]];
                NSDictionary *dic = [RPRedpacketUnionHandle dictWithRedpacketModel:redpacket isACKMessage:YES];
                message.rpModel = [AnalysisRedpacketModel analysisRedpacketWithDict:dic andIsSender:YES];
                [conversationViewController sendCustomMessage:message];
                break;
            }
            case RPRedpacketTypeGroupRand:
            case RPRedpacketTypeGroupAvg:
            case RPRedpacketTypeGoupMember:
            case RPRedpacketTypeSystem:{
                //TODO 需用户自定义
                break;
            }
            case RPRedpacketTypeAmount: {
                //TODO 需用户自定义
                break;
            }
            default:{
                //TODO 需用户自定义
                break;
            }
        }
    }
}

- (UIImage*)imageNamed:(NSString*)imageNamed ofBundle:(NSString*)bundleName {
    NSString *resPath = [NSString stringWithFormat:@"%@/%@",bundleName,imageNamed];
    UIImage *image = [UIImage imageNamed:resPath];
    return image;
}

- (void)configureCellWithData:(AVIMTypedMessageRedPacket *)message{
    [super configureCellWithData:message];
    if ([message isKindOfClass:[AVIMTypedMessageRedPacket class]]) {
        _rpMessage = message;
        AnalysisRedpacketModel *redpacketMessageModel = message.annlysisModel;
        NSString *messageString = redpacketMessageModel.greeting;
        self.greetingLabel.text = messageString;
        
        NSString *orgString = @"learnChat";
        self.orgLabel.text = orgString;
        
        switch (message.ioType) {
            case AVIMMessageIOTypeOut:{
                UIImage *image = [self imageNamed:@"redpacket_sender_bg" ofBundle:@"RedpacketCellResource.bundle"];
                self.messageContentBackgroundImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
            }
                break;
            case AVIMMessageIOTypeIn:{
                UIImage *image = [self imageNamed:@"redpacket_receiver_bg" ofBundle:@"RedpacketCellResource.bundle"];
                self.messageContentBackgroundImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
            }
                break;
            default:
                break;
        }
    }
}


@end
