> *其他语言版本：[简体中文](README.zh.md)*

This page introduces how to run the iOS sample project.
## Prerequisites 

- Make sure you have made the preparations mentioned in the  [prerequisites](https://docs.agora.io/en/agora-class/agora_class_prep?platform=iOS).
- Prepare the development environment:
  - Xcode 10.0 or later
  - CocoaPods

- Real iOS devices, such as iPhone or iPad.

## Run the sample project
1. [quick start](https://docs.agora.io/en/agora-class/agora_class_quickstart_ios?platform=iOS)
2. Configure parameters
Configure the following parameters in the 'keycenter. m' file:
- The Agora App ID that you get.
- The Agora RTM Token that you get.

```
+ (NSString *)appId {
    return <#Your Agora App Id#>;
}

+ (NSString *)rtmToken {
    return <#Your Agora RTM Token#>;
}
```

## Connect us

- You can read the full set of documentations and API reference at [Agora Developer Portal](https://docs.agora.io/en/).
- You can ask for technical support by submitting tickets in [Agora Console](https://dashboard.agora.io/). 
- You can submit an [issue](https://github.com/AgoraIO-Usecase/eEducation/issues) if you find any bug in the sample project. 

## License

Distributed under the MIT License. See `LICENSE` for more information.
