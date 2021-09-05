# ChatExtApp

## 简介
声网灵动课堂项目的IM聊天插件

## 使用
插件需要加载到声网灵动课堂项目中使用
灵动课堂项目github地址：https://github.com/AgoraIO-Community/CloudClass-iOS/tree/dev/apaas%2F1.1.1

两个项目放到相同目录下，修改灵动课堂项目的Podfile如下
```
pod 'ChatExtApp', :path => '../ChatExtApp'
```
然后重新**pod install**
加载插件，灵动课堂SDK启动后增加插件注册过程，代码如下：
```
AgoraClassroomSDK.launch(config, delegate: self)
let chat = AgoraExtAppConfiguration(appIdentifier: "io.agora.chat",
                                      extAppClass: ChatExtApp.self,
                                      frame: UIEdgeInsets(top: 30,
                                                          left: 10,
                                                          bottom: 10,
                                                          right: 10),
                                      language: "zh")
chat.image = AgoraKitImage("chat_enable");
chat.selectedImage = AgoraKitImage("chat_enable");
let apps = [chat]
AgoraClassroomSDK.registerExtApps(apps)
```
启动插件时，需要传入聊天室ID、用户头像、昵称
代码如下
```
dirty.properties = @{@"chatroomId":@"148364667715585",@"nickName":@"飞向蓝天",@"avatarUrl": @"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/IMDemo/avatar/Image1.png"};
[weakSelf launchExtApp:appIdentifier];
```

启动灵动课堂时，选择大班课，即可在左侧看到加载聊天功能的按钮
