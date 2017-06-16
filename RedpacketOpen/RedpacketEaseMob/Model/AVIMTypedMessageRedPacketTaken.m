//
//  RedpacketTakenMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-5-3.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "AVIMTypedMessageRedPacketTaken.h"

@implementation AVIMTypedMessageRedPacketTaken
@synthesize rpModel = _rpModel;

+ (void)load {
    [self registerSubclass];
}

+ (AVIMMessageMediaType)classMediaType {
    return 4;
}

- (instancetype)initWithClientId:(NSString *)clientId ConversationType:(LCCKConversationType)conversationType receiveMembers:(NSArray<NSString*>*)members {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setText:@"抢红包"];
    [self lcck_setObject:@"抢红包消息" forKey:LCCKCustomMessageTypeTitleKey];
    [self lcck_setObject:@"这是一条抢红包消息，当前版本过低无法显示，请尝试升级APP查看" forKey:LCCKCustomMessageDegradeKey];
    [self lcck_setObject:@"有人向您发送了一条抢红包，请打开APP查看" forKey:LCCKCustomMessageSummaryKey];
    
    if (members.count) {
        NSMutableString * memberString = [NSMutableString string];
        [members enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [memberString appendFormat:@"%@,",obj];
        }];
        [self lcck_setObject:@[[memberString substringToIndex:memberString.length -1]] forKey:LCCKCustomMessageOnlyVisiableForPartClientIds];
    }
    return self;
}

- (void)setRpModel:(AnalysisRedpacketModel *)rpModel {
    _rpModel = rpModel;
    NSString * nickName = rpModel.receiver.userName?:rpModel.receiver.userID;
    [self lcck_setObject:[NSString stringWithFormat:@"%@抢了你的红包",nickName] forKey:LCCKCustomMessageTypeTitleKey];
}

- (AnalysisRedpacketModel *)rpModel {
    if (!_rpModel) {
        NSError * error;
        NSDictionary * attributes = [NSJSONSerialization JSONObjectWithData:[self.payload dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        if (!error) {
            _rpModel = [AnalysisRedpacketModel analysisRedpacketWithDict:attributes andIsSender:YES];
        } else {
            _rpModel = nil;
        }
    }
    return _rpModel;
}

@end
