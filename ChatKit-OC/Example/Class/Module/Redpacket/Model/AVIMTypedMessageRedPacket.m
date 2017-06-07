//
//  AVIMTypedMessageRedPacket.m
//  ChatKit-OC
//
//  Created by 都基鹏 on 16/8/16.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import "AVIMTypedMessageRedPacket.h"
#import "RPRedpacketUnionHandle.h"

@implementation AVIMTypedMessageRedPacket
@synthesize rpModel = _rpModel;

+ (void)load {
    [self registerSubclass];
}

+ (AVIMMessageMediaType)classMediaType {
    return 3;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setText:@"红包"];
    [self lcck_setObject:@"红包" forKey:LCCKCustomMessageTypeTitleKey];
    [self lcck_setObject:@"这是一条红包消息，当前版本过低无法显示，请尝试升级APP查看" forKey:LCCKCustomMessageDegradeKey];
    [self lcck_setObject:@"有人向您发送了一条红包消息，请打开APP查看" forKey:LCCKCustomMessageSummaryKey];
    return self;
}

- (void)setRpModel:(RPRedpacketModel *)rpModel {
    _rpModel = rpModel;
    NSDictionary *dict = [RPRedpacketUnionHandle dictWithRedpacketModel:rpModel isACKMessage:NO];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setObject:obj forKey:key];
    }];
    [self lcck_setObject:[NSString stringWithFormat:@"%@：[红包]%@",rpModel.sender.userName,rpModel.greeting] forKey:LCCKCustomMessageTypeTitleKey];
}

- (AnalysisRedpacketModel *)annlysisModel {
    if (!_annlysisModel) {
        NSError * error;
        NSDictionary * attributes = [NSJSONSerialization JSONObjectWithData:[self.payload dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        if (!error) {
            _annlysisModel = [AnalysisRedpacketModel analysisRedpacketWithDict:attributes andIsSender:YES];
        }else{
            _annlysisModel = nil;
        }
    }
    return _annlysisModel;
}

- (RPRedpacketModel *)rpModel
{
    NSError * error;
    NSDictionary * attributes = [NSJSONSerialization JSONObjectWithData:[self.payload dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (!error) {
        _rpModel = [RPRedpacketUnionHandle modelWithChannelRedpacketDic:attributes andSender:nil];
    }else{
        _rpModel = nil;
    }
    return _rpModel;
}

@end
