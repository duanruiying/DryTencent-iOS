# DryTencent-iOS
iOS: 简化腾讯集成(授权、获取用户信息、QQ好友分享)

## 官网
* [腾讯开放平台](http://wiki.open.qq.com)
* [SDK下载 V3.3.3](http://wiki.connect.qq.com/)

## Prerequisites
* iOS 10.0+
* ObjC、Swift

## Installation
* pod 'DryTencent-iOS'

## SDK工程配置(在SDK的info.plist文件中配置)
```
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

## App工程配置
* 为URL Types 添加回调scheme(identifier:"tencent"、URL Schemes:"tencent+AppID")
* info.plist文件属性LSApplicationQueriesSchemes中增加:
```
mqq
mqqapi
mqqwpa
mqqOpensdkSSoLogin
mqqopensdkapiV2
mqqopensdkapiV3
mqqopensdkapiV4
wtloginmqq2
mqzone
mqzoneopensdk
mqzoneopensdkapi
mqzoneopensdkapi19
mqzoneopensdkapiV2
mqqapiwallet
mqqopensdkfriend
mqqopensdkdataline
mqqgamebindinggroup
mqqopensdkgrouptribeshare
tencentapi.qq.reqContent
tencentapi.qzone.reqContent
```

## Features
### 注册SDK
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DryTencent registerWithAppID:@""];
    return YES;
}
```
### 配置回调接收
```
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [DryTencent handleOpenURL:url];
    return YES;
}
```
### 授权登录、获取用户信息、QQ好友分享
```
/// 授权(登录)
[DryTencent qqAuth:^(DryTencentCode code) {
    NSLog(@"登录错误码: %ld", (long)code);
} successHandler:^(NSString * _Nullable openID, NSString * _Nullable accessToken) {
    NSLog(@"OpenID: %@, accessToken: %@", openID, accessToken);

    /// 获取用户信息
    [DryTencent qqUserInfo:^(DryTencentCode code) {
        NSLog(@"获取用户信息错误码: %ld", (long)code);
    } respSuccess:^(NSString * _Nullable nickName, NSString * _Nullable headImgUrl) {
        NSLog(@"nickName: %@, headImgUrl: %@", nickName, headImgUrl);
    }];

    /// 分享
    DryTencentQqObj *obj = [[DryTencentQqObj alloc] init];
    obj.title = @"标题";
    obj.descrip = @"描述";
    obj.text = @"文本";
    [DryTencent qqShareWithType:kDryTencentQqTypeText message:obj completion:^(DryTencentCode code) {
        NSLog(@"分享状态码: %ld", (long)code);
    }];
}];
```
