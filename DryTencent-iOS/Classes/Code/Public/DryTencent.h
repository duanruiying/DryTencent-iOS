//
//  DryTencent.h
//  DryTencent
//
//  Created by Ruiying Duan on 2019/5/26.
//

#import <Foundation/Foundation.h>

#import "DryTencentQqObj.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 状态码
typedef NS_ENUM(NSInteger, DryTencentCode) {
    /// 成功
    kDryTencentCodeSuccess,
    /// 未知错误
    kDryTencentCodeUnknown,
    /// SDK未注册
    kDryTencentCodeUnregister,
    /// 用户取消
    kDryTencentCodeUserCancel,
    /// 网络错误
    kDryTencentCodeNetwork,
    /// 参数异常
    kDryTencentCodeParamsErr,
};

#pragma mark - Blcok
/// 状态码
typedef void (^BlockDryTencentCode)     (DryTencentCode code);
/// OpenID、接口调用凭证
typedef void (^BlockDryTencentAuth)     (NSString *_Nullable openID, NSString *_Nullable accessToken);
/// 昵称、头像下载地址
typedef void (^BlockDryTencentUserInfo) (NSString *_Nullable nickName, NSString *_Nullable headImgUrl);

#pragma mark - DryTencent
@interface DryTencent : NSObject

/// @说明 注册SDK
/// @参数 appID:  腾讯开放平台下发的账号
/// @返回 void
+ (void)registerWithAppID:(NSString *)appID;

/// @说明 处理腾讯通过URL启动App时传递的数据
/// @注释 在application:openURL:options:中调用
/// @返回 BOOL
+ (BOOL)handleOpenURL:(NSURL *)url;

/// @说明 获取QQ客户端的授权(登录)
/// @参数 errHandler:     异常回调
/// @参数 successHandler: 成功回调
/// @返回 void
+ (void)qqAuth:(BlockDryTencentCode)errHandler successHandler:(BlockDryTencentAuth)successHandler;

/// @说明 解除QQ客户端的授权(需要重新初始化 registerWithAppID)
/// @参数 completion: 状态码回调
/// @返回 void
+ (void)qqUnauth:(BlockDryTencentCode)completion;

/// @说明 QQ客户端的授权是否有效(无效则请用户重新登录授权 qqAuth:successHandler:)
/// @注释 需要在“注册SDK”完成之后返回的结果有效
/// @返回 BOOL
+ (BOOL)isAuthValid;

/// @说明 获取QQ客户端的用户信息
/// @参数 errHandler:     异常回调
/// @参数 successHandler: 成功回调
/// @返回 void
+ (void)qqUserInfo:(BlockDryTencentCode)errHandler respSuccess:(BlockDryTencentUserInfo)successHandler;

/// @说明 QQ好友分享
/// @参数 type:       分享对象的类型
/// @参数 message:    分享对象
/// @参数 completion: 状态码回调
/// @返回 void
+ (void)qqShareWithType:(DryTencentQqType)type
                message:(DryTencentQqObj *)message
             completion:(BlockDryTencentCode)completion;

@end

NS_ASSUME_NONNULL_END
