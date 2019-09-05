//
//  DryTencentQqObj.h
//  DryTencent
//
//  Created by Ruiying Duan on 2019/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 分享对象的类型
typedef NS_ENUM(NSInteger, DryTencentQqType) {
    /// 文本对象
    kDryTencentQqTypeText,
    /// 图片对象
    kDryTencentQqTypeImage,
    /// 音频URL对象
    kDryTencentQqTypeAudio,
    /// 视频URL对象
    kDryTencentQqTypeVideo,
    /// 新闻URL对象
    kDryTencentQqTypeNews,
};

#pragma mark - QQ好友分享对象
@interface DryTencentQqObj : NSObject

///==========> 通用属性
/// 标题(最长128个字符)
@property (nonatomic, readwrite, copy) NSString *title;
/// 描述内容(最长512个字符)
@property (nonatomic, readwrite, nullable, copy) NSString *descrip;

///==========> 文本对象
/// 文本内容(必填，最长1536个字符)
@property (nonatomic, readwrite, nullable, copy) NSString *text;

///==========> 图片对象
/// 具体数据内容(必填，最大5M字节)
@property (nonatomic, readwrite, nullable, strong) NSData *imageData;
/// 预览图像(最大1M字节)
@property (nonatomic, readwrite, nullable, strong) NSData *imagePreview;

///==========> 音频URL对象
/// 音频URL地址(必填，最长512个字符)
@property (nonatomic, readwrite, nullable, strong) NSURL *audioUrl;
/// 预览图像(最大1M字节)
@property (nonatomic, readwrite, nullable, strong) NSData *audioPreviewImageData;
/// 预览图像URL(最长512个字符)
@property (nonatomic, readwrite, nullable, strong) NSURL *audioPreviewImageUrl;

///==========> 视频URL对象
/// 视频URL地址(必填，最长512个字符)
@property (nonatomic, readwrite, nullable, strong) NSURL *videoUrl;
/// 预览图像(最大1M字节)
@property (nonatomic, readwrite, nullable, strong) NSData *videoPreviewImageData;
/// 预览图像URL(最长512个字符)
@property (nonatomic, readwrite, nullable, strong) NSURL *videoPreviewImageUrl;

///==========> 新闻URL对象
/// 新闻URL地址(必填，最长512个字符)
@property (nonatomic, readwrite, nullable, strong) NSURL *newsUrl;
/// 预览图像(最大1M字节)
@property (nonatomic, readwrite, nullable, strong) NSData *newsPreviewImageData;
/// 预览图像URL(最长512个字符)
@property (nonatomic, readwrite, nullable, strong) NSURL *newsPreviewImageUrl;

@end

NS_ASSUME_NONNULL_END
