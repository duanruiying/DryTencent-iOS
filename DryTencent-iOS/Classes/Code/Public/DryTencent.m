//
//  DryTencent.m
//  DryTencent
//
//  Created by Ruiying Duan on 2019/5/26.
//

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

#import "DryTencent.h"

#pragma mark - DryTencent
@interface DryTencent () <TencentLoginDelegate, TencentSessionDelegate, QQApiInterfaceDelegate>

/// 授权登录对象
@property (nonatomic, readwrite, nullable, strong) TencentOAuth *oAuth;

/// 状态码回调(授权)
@property (nonatomic, readwrite, nullable, copy) BlockDryTencentCode authCodeBlock;
/// 授权回调
@property (nonatomic, readwrite, nullable, copy) BlockDryTencentAuth authBlock;

/// 状态码回调(解除授权)
@property (nonatomic, readwrite, nullable, copy) BlockDryTencentCode unauthCodeBlock;

/// 状态码回调(用户信息)
@property (nonatomic, readwrite, nullable, copy) BlockDryTencentCode userInfoCodeBlock;
/// 用户信息回调
@property (nonatomic, readwrite, nullable, copy) BlockDryTencentUserInfo userInfoBlock;

/// 状态码回调(分享)
@property (nonatomic, readwrite, nullable, copy) BlockDryTencentCode shareCodeBlock;

@end

@implementation DryTencent

/// 单例
+ (instancetype)sharedInstance {
    
    static DryTencent *theInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        theInstance = [[DryTencent alloc] init];
    });
    return theInstance;
}

/// 构造
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

/// 析构
- (void)dealloc {

}

/// 注册腾讯客户端
+ (void)registerWithAppID:(NSString *)appID {
    
    /// 检查参数
    if (!appID) {
        return;
    }
    
    /// 注册SDK，设置“第三方应用用于接收请求返回结果的委托对象”
    [DryTencent sharedInstance].oAuth = [[TencentOAuth alloc] initWithAppId:appID andDelegate:[DryTencent sharedInstance]];
}

/// 处理腾讯通过URL启动App时传递的数据
+ (BOOL)handleOpenURL:(NSURL *)url {
    
    /// 设置“第三方应用用于处理来至QQ请求及响应的委托对象”
    if (url && [DryTencent sharedInstance].oAuth) {
        [QQApiInterface handleOpenURL:url delegate:[DryTencent sharedInstance]];
    }
    
    /// 处理被其他应用呼起时的逻辑
    if (url && [TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return YES;
}

/// 获取QQ客户端的授权(登录)
+ (void)qqAuth:(BlockDryTencentCode)errHandler successHandler:(BlockDryTencentAuth)successHandler {
    
    /// 检查参数
    if (!errHandler || !successHandler) {
        return;
    }
    
    /// 是否注册SDK
    if (![DryTencent sharedInstance].oAuth) {
        errHandler(kDryTencentCodeUnregister);
        return;
    }
    
    /// 更新Block
    [DryTencent sharedInstance].authCodeBlock = errHandler;
    [DryTencent sharedInstance].authBlock = successHandler;
    
    /// 授权类型
    NSMutableArray *permissionArray = [[NSMutableArray alloc] init];
    [permissionArray addObject:kOPEN_PERMISSION_GET_INFO];
    [permissionArray addObject:kOPEN_PERMISSION_GET_SIMPLE_USER_INFO];
    [permissionArray addObject:kOPEN_PERMISSION_GET_USER_INFO];
    
    /// 请求授权
    [[DryTencent sharedInstance].oAuth setAuthShareType:AuthShareType_QQ];
    [[DryTencent sharedInstance].oAuth setAuthMode:kAuthModeClientSideToken];
    [[DryTencent sharedInstance].oAuth authorize:permissionArray];
}

/// 解除授权(退出登录，TecentOAuth失效，需要重新初始化 registerWithAppID)
+ (void)qqUnauth:(BlockDryTencentCode)completion {
    
    /// 检查参数
    if (!completion) {
        return;
    }
    
    /// 检查数据
    if (![DryTencent sharedInstance].oAuth) {
        completion(kDryTencentCodeSuccess);
        return;
    }
    
    /// 更新Block
    [DryTencent sharedInstance].unauthCodeBlock = completion;
    
    /// 解除授权
    [[DryTencent sharedInstance].oAuth logout:[DryTencent sharedInstance]];
}

/// QQ客户端的授权是否有效
+ (BOOL)isAuthValid {
    
    /// 检查数据
    if (![DryTencent sharedInstance].oAuth) {
        return NO;
    }
    
    return [DryTencent sharedInstance].oAuth.isSessionValid;
}

/// 获取QQ客户端的用户信息
+ (void)qqUserInfo:(BlockDryTencentCode)errHandler respSuccess:(BlockDryTencentUserInfo)successHandler {
    
    /// 检查参数
    if (!errHandler || !successHandler) {
        return;
    }
    
    /// 是否注册SDK
    if (![DryTencent sharedInstance].oAuth) {
        errHandler(kDryTencentCodeUnregister);
        return;
    }
    
    /// 检查(必要数据)
    if (![DryTencent sharedInstance].oAuth.openId || ![DryTencent sharedInstance].oAuth.accessToken) {
        errHandler(kDryTencentCodeParamsErr);
        return;
    }
    
    /// 更新Block
    [DryTencent sharedInstance].userInfoCodeBlock = errHandler;
    [DryTencent sharedInstance].userInfoBlock = successHandler;
    
    /// 获取用户信息
    [[DryTencent sharedInstance].oAuth getUserInfo];
}

/// QQ好友分享
+ (void)qqShareWithType:(DryTencentQqType)type
                message:(DryTencentQqObj *)message
             completion:(BlockDryTencentCode)completion {
    
    /// 检查参数
    if (!completion) {
        return;
    }
    
    /// 是否注册SDK
    if (![DryTencent sharedInstance].oAuth) {
        completion(kDryTencentCodeUnregister);
        return;
    }
    
    /// 检查参数
    if (!message) {
        completion(kDryTencentCodeParamsErr);
        return;
    }
    
    /// 创建分享对象
    SendMessageToQQReq *req;
    if (type == kDryTencentQqTypeText) {
        
        /// 文本
        if (!message.text) {
            completion(kDryTencentCodeParamsErr);
            return;
        }
        
        QQApiTextObject *obj = [[QQApiTextObject alloc] init];
        obj.title = message.title;
        obj.description = message.descrip;
        obj.text = message.text;
        req = [SendMessageToQQReq reqWithContent:obj];
        
    }else if (type == kDryTencentQqTypeImage) {
        
        /// 图片
        if (!message.imageData) {
            completion(kDryTencentCodeParamsErr);
            return;
        }
        
        QQApiImageObject *obj = [[QQApiImageObject alloc] init];
        obj.title = message.title;
        obj.description = message.descrip;
        obj.data = message.imageData;
        obj.previewImageData = message.imagePreview;
        req = [SendMessageToQQReq reqWithContent:obj];
        
    }else if (type == kDryTencentQqTypeAudio) {
        
        /// 音频
        if (!message.audioUrl) {
            completion(kDryTencentCodeParamsErr);
            return;
        }
        
        QQApiAudioObject *obj = [[QQApiAudioObject alloc] init];
        obj.title = message.title;
        obj.description = message.descrip;
        obj.flashURL = message.audioUrl;
        if (message.audioPreviewImageData) {
            obj.previewImageData = message.audioPreviewImageData;
        }else if (message.audioPreviewImageUrl) {
            obj.previewImageURL = message.audioPreviewImageUrl;
        }
        req = [SendMessageToQQReq reqWithContent:obj];
        
    }else if (type == kDryTencentQqTypeVideo) {
        
        /// 视频
        if (!message.videoUrl) {
            completion(kDryTencentCodeParamsErr);
            return;
        }
        
        QQApiVideoObject *obj = [[QQApiVideoObject alloc] init];
        obj.title = message.title;
        obj.description = message.descrip;
        obj.flashURL = message.videoUrl;
        if (message.audioPreviewImageData) {
            obj.previewImageData = message.videoPreviewImageData;
        }else if (message.audioPreviewImageUrl) {
            obj.previewImageURL = message.videoPreviewImageUrl;
        }
        req = [SendMessageToQQReq reqWithContent:obj];
        
    }else if (type == kDryTencentQqTypeNews) {
        
        /// 新闻
        if (!message.newsUrl) {
            completion(kDryTencentCodeParamsErr);
            return;
        }
        
        QQApiNewsObject *obj = [[QQApiNewsObject alloc] init];
        obj.title = message.title;
        obj.description = message.descrip;
        obj.url = message.newsUrl;
        if (message.audioPreviewImageData) {
            obj.previewImageData = message.newsPreviewImageData;
        }else if (message.audioPreviewImageUrl) {
            obj.previewImageURL = message.newsPreviewImageUrl;
        }
        req = [SendMessageToQQReq reqWithContent:obj];
        
    }else {
        
        /// 异常回调
        completion(kDryTencentCodeParamsErr);
        return;
    }
    
    /// 更新Block
    [DryTencent sharedInstance].shareCodeBlock = completion;
    
    /// 分享
    [QQApiInterface sendReq:req];
}

#pragma mark - TencentLoginDelegate(授权)
/// 授权: 登录成功
- (void)tencentDidLogin {
    
    /// 检查数据
    if (![DryTencent sharedInstance].authBlock || ![DryTencent sharedInstance].authCodeBlock) {
        
        /// 清理Block
        [DryTencent sharedInstance].authCodeBlock = nil;
        [DryTencent sharedInstance].authBlock = nil;
        
        return;
    }
    
    /// 是否注册SDK
    if (![DryTencent sharedInstance].oAuth) {
        
        /// 回调
        [DryTencent sharedInstance].authCodeBlock(kDryTencentCodeUnregister);
        
        /// 清理Block
        [DryTencent sharedInstance].authCodeBlock = nil;
        [DryTencent sharedInstance].authBlock = nil;
        
        return;
    }
    
    /// 回调
    NSString *openID = [DryTencent sharedInstance].oAuth.openId;
    NSString *accessToken = [DryTencent sharedInstance].oAuth.accessToken;
    [DryTencent sharedInstance].authBlock(openID, accessToken);
    
    /// 清理Block
    [DryTencent sharedInstance].authCodeBlock = nil;
    [DryTencent sharedInstance].authBlock = nil;
}

/// 授权: 登录失败
- (void)tencentDidNotLogin:(BOOL)cancelled {
    
    /// 检查数据
    if (![DryTencent sharedInstance].authBlock || ![DryTencent sharedInstance].authCodeBlock) {
        
        /// 清理Block
        [DryTencent sharedInstance].authCodeBlock = nil;
        [DryTencent sharedInstance].authBlock = nil;
        
        return;
    }
    
    /// 登录失败回调
    if (cancelled) {
        [DryTencent sharedInstance].authCodeBlock(kDryTencentCodeUserCancel);
    }else {
        [DryTencent sharedInstance].authCodeBlock(kDryTencentCodeUnknown);
    }
    
    /// 清理Block
    [DryTencent sharedInstance].authCodeBlock = nil;
    [DryTencent sharedInstance].authBlock = nil;
}

/// 授权: 网络有问题
- (void)tencentDidNotNetWork {
    
    /// 检查数据
    if (![DryTencent sharedInstance].authBlock || ![DryTencent sharedInstance].authCodeBlock) {
        
        /// 清理Block
        [DryTencent sharedInstance].authCodeBlock = nil;
        [DryTencent sharedInstance].authBlock = nil;
        
        return;
    }
    
    /// 登录失败回调
    [DryTencent sharedInstance].authCodeBlock(kDryTencentCodeNetwork);
    
    /// 清理Block
    [DryTencent sharedInstance].authCodeBlock = nil;
    [DryTencent sharedInstance].authBlock = nil;
}

#pragma mark - TencentSessionDelegate(获取用户信息)
/// 解除授权
- (void)tencentDidLogout {
    
    /// 检查数据
    if (![DryTencent sharedInstance].unauthCodeBlock) {
        return;
    }
    
    /// 回调
    [DryTencent sharedInstance].unauthCodeBlock(kDryTencentCodeSuccess);
    
    /// 清理Block
    [DryTencent sharedInstance].unauthCodeBlock = nil;
}

/// 获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response {
    
    /// 数据检查
    if (![DryTencent sharedInstance].userInfoBlock || ![DryTencent sharedInstance].userInfoCodeBlock) {
        
        /// 清理Block
        [DryTencent sharedInstance].userInfoCodeBlock = nil;
        [DryTencent sharedInstance].userInfoBlock = nil;
        
        return;
    }
    
    /// 判断是否获取信息成功
    if (response.retCode == URLREQUEST_SUCCEED && response.detailRetCode == kOpenSDKErrorSuccess) {
        
        /// 初始化用户信息
        NSString *nickname = nil;
        NSString *headImageUrl = nil;
        
        /// 解析用户信息
        id jsonObject = response.jsonResponse;
        if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
            
            /// 数据转换
            NSDictionary *dict = (NSDictionary *)jsonObject;
            
            /// 昵称
            if ([[dict allKeys] containsObject:@"nickname"]) {
                nickname = [NSString stringWithFormat:@"%@", [dict valueForKey:@"nickname"]];
            }
            
            /// 头像下载地址
            if ([[dict allKeys] containsObject:@"figureurl_qq_2"]) {
                headImageUrl = [NSString stringWithFormat:@"%@", [dict valueForKey:@"figureurl_qq_2"]];
            }
            
            /// 回调
            [DryTencent sharedInstance].userInfoBlock(nickname, headImageUrl);
            
        }else {
            
            /// 异常回调
            [DryTencent sharedInstance].userInfoCodeBlock(kDryTencentCodeUnknown);
        }
        
    }else {
        
        /// 异常回调
        [DryTencent sharedInstance].userInfoCodeBlock(kDryTencentCodeUnknown);
    }
    
    /// 清理Block
    [DryTencent sharedInstance].userInfoCodeBlock = nil;
    [DryTencent sharedInstance].userInfoBlock = nil;
}

#pragma mark - QQApiInterfaceDelegate(分享)
/// 处理来至QQ的请求
- (void)onReq:(QQBaseReq *)req {
    
}

/// 处理QQ在线状态的回调
- (void)isOnlineResponse:(NSDictionary *)response {
    
}

/// 处理来至QQ的响应
- (void)onResp:(QQBaseResp *)resp {
    
    /// 检查数据
    if (![DryTencent sharedInstance].shareCodeBlock) {
        return;
    }
    
    /// 分享回调
    if (resp.type == ESENDMESSAGETOQQRESPTYPE) {
        
        /// 第三方应用，手Q应答处理分享消息的结果
        SendMessageToQQResp *sendResp = (SendMessageToQQResp* )resp;
        if ([sendResp.result isEqualToString:@"0"]) {
            [DryTencent sharedInstance].shareCodeBlock(kDryTencentCodeSuccess);
        }else {
            [DryTencent sharedInstance].shareCodeBlock(kDryTencentCodeUnknown);
        }
        
        /// 清理Block
        [DryTencent sharedInstance].shareCodeBlock = nil;
    }
}

@end
