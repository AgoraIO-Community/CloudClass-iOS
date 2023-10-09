## 1
找到阿卡索工程中用来放灵动课堂的Libs文件夹，然后将里面的文件都删除

## 2
将该目录下除README以外的文件都拷到工程中用来放灵动课堂的Libs文件夹下

## 3
在阿卡索工程中的AgoraClassroomSDK.podspec最底部添加以下代码

```
spec.resources = [
    "Libs/*.bundle"
  ]
```

## 4
在阿卡索工程中的AgoraClassroomSDK.podspec中，将 AgoraRtcEngine 的依赖修改为下面的代码

```
spec.dependency = "AgoraRtcEngine_iOS/RtcBasic", "3.7.2"
```

## 5
找到阿卡索工程中的podfile所在的路径，然后执行pod install，即可完成升级