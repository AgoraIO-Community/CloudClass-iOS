> *其他语言版本：[简体中文](README.zh.md)*

This page introduces how to run the iOS sample project.
## Prerequisites 

- Make sure you have made the preparations mentioned in the  [prerequisites](https://docs.agora.io/en/agora-class/agora_class_prep?platform=iOS).
- Prepare the development environment:
  - Xcode 12.0 or later
  - CocoaPods

- Real iOS devices, such as iPhone or iPad.

## Run the sample project
1. [quick start](https://docs.agora.io/en/agora-class/agora_class_quickstart_ios?platform=iOS)
2. Configure parameters
The current Flexible Classroom project uses the default `AppId` and `AppCertificate` in the `LoginViewController` to request tokens, as shown in the code below
```
requestToken(region: region.rawValue,
             userUuid: userUuid,
             success: tokenSuccessBlock,
             failure: failureBlock)
```
To use your own `AppId` and `AppCertificate`, comment out the execution of the `requestToken` method and use the `buildToken` method below
```
buildToken(appId: "Your App Id",
           appCertificate: "Your App Certificate",
           userUuid: userUuid,
           success: tokenSuccessBlock,
           failure: failureBlock)
```

## Connect us

- You can read the full set of documentations and API reference at [Flexible Classroom Documentation](https://docs.agora.io/en/agora-class/landing-page).
- You can ask for technical support by submitting tickets in [Agora Console](https://dashboard.agora.io/). 
- You can submit an [issue](https://github.com/AgoraIO-Community/CloudClass-iOS/issues) if you find any bug in the sample project. 

## License

Distributed under the MIT License. See `LICENSE` for more information.
