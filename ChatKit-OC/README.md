# leanchat iOS红包SDK集成
## 集成概述
* 红包SDK分为两个版本，即**钱包版红包SDK**与**支付宝版红包SDK**。
* 使用钱包版红包SDK的用户，可以使用银行卡支付或支付宝支付等第三方支付来发红包；收到的红包金额会进入到钱包余额，并支持提现到绑定的银行卡。
* 使用支付宝版红包SDK的用户，发红包仅支持支付宝支付；收到的红包金额即时入账至绑定的支付宝账号。
* 请选择希望接入的版本并下载对应的SDK进行集成，钱包版红包SDK与支付宝版红包SDK集成方式相同。
* 需要注意的是如果已经集成了钱包版红包SDK，暂不支持切换到支付宝版红包SDK（两个版本不支持互通）。
* [集成演示Demo](https://github.com/YunzhanghuOpen/Redpacket-Demo-LeanChat-iOS)，开发者可以通过此Demo了解iOS红包SDK的集成，集成方式仅供参考。

## 集成红包

### 红包开源模块介绍

* `AppDelegate+RedPacket` 
* 为**支付宝版SDK**处理支付宝授权和支付宝支付回调

* `RedpacketMessageCell` 
* 红包SDK内的红包卡片样式

*  `RedpacketCellResource.bundle` 
*  红包开源部分的资源文件

* `RedPacketInputViewPlugin` 
* 包含发红包收红包功能
* 单聊红包包含**小额随机红包**和**普通红包**
* 群红包包含**定向红包**，**普通红包**和**拼手气红包**

* `RedpacketConfig` 红包SDK初始化文件       
*  实现红包SDK注册
*  实现当前用户获取

### SDK初始化配置
文件名称：AppDelegate+Redpacket.h
说明：配置SDK相关数据源， 设置支付宝回调。

### 收发红包
文件名称：RedPacketInputViewPlugin.h

#### 添加红包按钮和红包按钮回调事件


```
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

```

#### 发送红包消息

* 红包消息

```
- (void)sendRedpacketMessage:(RedpacketMessageModel *)redpacket {
AVIMTypedMessageRedPacket * message = [[AVIMTypedMessageRedPacket alloc]init];
message.rpModel = redpacket;
[self.conversationViewController sendCustomMessage:message];
}

* 接收处理被抢的消息'RedpacketMessageCell.m'
```
- (void)onRedpacketTakenMessage:(RedpacketMessageModel *)redpacket {
if (![self.delegate isKindOfClass:[LCCKConversationViewController class]]) return;

LCCKConversationViewController * conversationViewController = (LCCKConversationViewController*)self.delegate;
if ([redpacket.currentUser.userId isEqualToString:redpacket.redpacketSender.userId]) {//如果发送者是自己
[conversationViewController sendLocalFeedbackTextMessge:@"您抢了自己的红包"];
}
else {
switch (redpacket.redpacketType) {
case RedpacketTypeSingle:{
AVIMTypedMessageRedPacketTaken * message = [[AVIMTypedMessageRedPacketTaken alloc]initWithClientId:self.clientId ConversationType:LCCKConversationTypeSingle receiveMembers:@[redpacket.redpacketSender.userId]];
message.rpModel = redpacket;
[conversationViewController sendCustomMessage:message];
break;
}
case RedpacketTypeGroup:
case RedpacketTypeRand:
case RedpacketTypeAvg:
case RedpacketTypeRandpri:{
//TODO 需用户自定义
break;
}
case RedpacketTypeMember: {
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

```

#### 展示红包卡片样式

红包样式`RedpacketMessageCell`
红包被领取的样式`RedpacketTakenMessageTipCell`


#### 收拆红包 'RedpacketMessageCell.m'

```
- (void)redpacketClicked {
if ([self.rpMessage isKindOfClass:[AVIMTypedMessageRedPacket class]]) {
__weak typeof(self) weakSelf = self;
AVIMTypedMessageRedPacket * message = (AVIMTypedMessageRedPacket*)self.rpMessage;
[RedpacketViewControl redpacketTouchedWithMessageModel:message.rpModel fromViewController:(UIViewController*)self.delegate redpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
[weakSelf onRedpacketTakenMessage:messageModel];
} advertisementAction:nil];
}
}
```

### 显示零钱功能

文件位置：`#import "RedPacketChangeInputViewPlugin.h"`

说明： 显示红包零钱页面或红包记录页

```
- (void)pluginDidClicked {
[RedpacketViewControl presentChangePocketViewControllerFromeController:self.conversationViewController];
}

```


