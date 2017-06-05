//
//  RedPacketIncomeViewPlugin.m
//  ChatKit-OC
//
//  Created by Mr.Yan on 2017/6/5.
//  Copyright © 2017年 ElonChan. All rights reserved.
//

#import "RedPacketIncomeViewPlugin.h"
#import "RedpacketViewControl.h"

@implementation RedPacketIncomeViewPlugin
@synthesize inputViewRef = _inputViewRef;

+ (void)load {
    [self registerSubclass];
}

+ (LCCKInputViewPluginType)classPluginType {
    return 4;
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
    return @"零钱";
}

/*!
 * 插件对应的 view，会被加载到 inputView 上
 */
- (UIView *)pluginContentView {
    return nil;
}

- (void)pluginDidClicked {
    [RedpacketViewControl presentChangePocketViewControllerFromeController:self.conversationViewController];
}

#pragma mark -
#pragma mark - Private Methods

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"RedpacketCellResource" bundleForClass:[self class]];
    return image;
}

@end
