> *Read this in another language: [English](README.md)*

本文指导你运行 iOS 示例项目。

## 前提条件

- 准备工作：请确保你已经完成[前提条件](https://docs.agora.io/cn/agora-class/agora_class_prep?platform=iOS)中的准备工作。
- 开发环境：
  - Xcode 12.0 及以上
  - Cocoapods
  - If you are developing using Swift, use Swift 5.0 or later.
- iOS 真机（iPhone 或 iPad）

## 运行示例项目
1. [快速接入](https://docs.agora.io/cn/agora-class/agora_class_quickstart_ios?platform=iOS)
2. 确保你已将[apaas-extapp-ios](https://github.com/AgoraIO-Community/apaas-extapp-ios)项目克隆至本地，并切换至最新发版分支。apaas-extapp-ios 仓库需要和 CloudClass-iOS 仓库位于同级目录下。
3. 在 CloudClass-iOS/App文件夹中执行`pod install`。
4. 配置相关参数
目前项目使用灵动课堂`LoginViewController`中默认的`AppId`和`AppCertificate`请求token，如下方代码所示
```
requestToken(region: region.rawValue,
             userUuid: userUuid,
             success: tokenSuccessBlock,
             failure: failureBlock)
```
若需要使用自己的`AppId`和`AppCertificate`，可将`requestToken`方法的执行注释掉，使用下面的`buildToken`方法
```
buildToken(appId: "Your App Id",
           appCertificate: "Your App Certificate",
           userUuid: userUuid,
           success: tokenSuccessBlock,
           failure: failureBlock)
```

## 联系我们

- 如需阅读完整的文档和 API 注释，你可以访问[灵动课堂文档中心](https://docs.agora.io/cn/agora-class/landing-page?platform=iOS)。
- 如果在集成中遇到问题，你可以到[声网开发者社区](https://dev.agora.io/cn/)提问。
- 如果有售前咨询问题，你可以拨打 400 632 6626，或加入官方Q群 12742516 提问。
- 如果需要售后技术支持，你可以在 [Agora 控制台](https://dashboard.agora.io/)提交工单。
- 如果发现了示例代码的 bug，欢迎提交 [issue](https://github.com/AgoraIO-Community/CloudClass-iOS/issues)。

## 代码许可

The MIT License (MIT).