_English | [中文](README.zh.md)_

This page introduces how to run the iOS sample project.

## How to run the sample project

### Prerequisites 

- Make sure you have made the preparations mentioned in the  [prerequisites](https://docs.agora.io/en/agora-class/agora_class_prep?platform=iOS).
- Prepare the development environment:
  - Xcode 10.0 or later
  - CocoaPods

- Real iOS devices, such as iPhone or iPad.

### Run the sample project
1. [Quick Start](https://docs.agora.io/en/agora-class/agora_class_quickstart_ios?platform=iOS)
2. Configure parameters
Configure the following parameters in the 'keycenter. m' file:
- The Agora App ID that you get.
- The Agora App Certificate that you get.

```
+ (NSString *)appId {
    return <#Your Agora App Id#>;
}

+ (NSString *)appCertificate {
    return <#Your Agora Certificate#>;
}
```


   > See [Set up Authentication](https://docs.agora.io/en/Agora%20Platform/token) to learn how to get an App ID and access token. You can get a temporary access token to quickly try out this sample project.
   >
   > The Channel name you used to generate the token must be the same as the channel name you use to join a channel.

   > To ensure communication security, Agora uses access tokens (dynamic keys) to authenticate users joining a channel.
   >
   > Temporary access tokens are for demonstration and testing purposes only and remain valid for 24 hours. In a production environment, you need to deploy your own server for generating access tokens. See [Generate a Token](https://docs.agora.io/en/Interactive%20Broadcast/token_server) for details.

## Feedback

If you have any problems or suggestions regarding the sample projects, feel free to file an [issue](https://github.com/AgoraIO-Community/CloudClass-iOS/issues).

## Related resources

- Check our [FAQ](https://docs.agora.io/en/faq) to see if your issue has been recorded.
- Dive into [Agora SDK Samples](https://github.com/AgoraIO) to see more tutorials
- Take a look at [Agora Use Case](https://github.com/AgoraIO-usecase) for more complicated real use case
- Repositories managed by developer communities can be found at [Agora Community](https://github.com/AgoraIO-Community)
- If you encounter problems during integration, feel free to ask questions in [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)

## License

The sample projects are under the MIT license.
