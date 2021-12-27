//
//  AgoraEduContextProtocols.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/7.
//

import AgoraWidget
import UIKit

public typealias AgoraEduContextSuccess = () -> (Void)
public typealias AgoraEduContextSuccessWithString = (String) -> (Void)
public typealias AgoraEduContextFailure = (AgoraEduContextError) -> (Void)

// MARK: - Classroom
@objc public protocol AgoraEduRoomHandler: NSObjectProtocol {
    /// 加入房间成功 (v2.0.0)
    /// - parameter roomInfo: 房间信息
    @objc optional func onRoomJoinedSuccess(roomInfo: AgoraEduContextRoomInfo)
    
    /// 加入房间失败 (v2.0.0)
    /// - parameter roomInfo: 房间信息
    /// - parameter error: 错误原因
    @objc optional func onRoomJoinedFail(roomInfo: AgoraEduContextRoomInfo,
                                         error: AgoraEduContextError)
    
    /// 房间自定义属性更新 (v2.0.0)
    /// - parameter changedProperties: 本次更新的部分 properties
    /// - parameter cause: 更新的原因
    /// - parameter operatorUser: 该操作的执行者
    @objc optional func onRoomPropertiesUpdated(changedProperties: [String: Any],
                                                cause: [String: Any]?,
                                                operatorUser: AgoraEduContextUserInfo?)
    
    /// 房间自定义属性删除 (v2.0.0)
    /// - parameter keyPaths: 被删除的属性的key path数组
    /// - parameter cause: 原因
    /// - parameter operatorUser: 该操作的执行者
    @objc optional func onRoomPropertiesDeleted(keyPaths: [String],
                                                cause: [String: Any]?,
                                                operatorUser: AgoraEduContextUserInfo?)
    
    /// 课堂状态更新 (v2.0.0)
    /// - parameter state: 当前的课堂状态
    @objc optional func onClassStateUpdated(state: AgoraEduContextClassState)
    
    /// 房间关闭 (v2.0.0)
    @objc optional func onRoomClosed()
}

@objc public protocol AgoraEduRoomContext: NSObjectProtocol {
    /// 加入房间 (v2.0.0)
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    func joinRoom(success: (() -> Void)?,
                  failure: ((AgoraEduContextError) -> Void)?)
    
    /// 离开房间 (v2.0.0)
    func leaveRoom()
    
    /// 获取房间信息 (v2.0.0)
    /// - returns: 房间信息
    func getRoomInfo() -> AgoraEduContextRoomInfo
    
    /// 更新/增加自定义房间属性 (v2.0.0)
    /// 支持path修改和整体修改
    /// - parameter properties: {"key.subkey":"1"}  和 {"key":{"subkey":"1"}}
    /// - parameter cause: 修改的原因，可为空
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    func updateRoomProperties(_ properties: [String: Any],
                              cause: [String: Any]?,
                              success: (() -> Void)?,
                              failure: ((AgoraEduContextError) -> Void)?)
    
    /// 删除房间自定义属性 (v2.0.0)
    /// - parameter keyPaths: key 数组
    /// - parameter cause: 修改的原因，可为空
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    func deleteRoomProperties(_ keyPaths: [String],
                              cause: [String: Any]?,
                              success: (() -> Void)?,
                              failure: ((AgoraEduContextError) -> Void)?)
    
    /// 获取课堂信息 (v2.0.0)
    /// - returns: 课堂信息
    func getClassInfo() -> AgoraEduContextClassInfo
    
    /// 事件监听  (v2.0.0)
    func registerRoomEventHandler(_ handler: AgoraEduRoomHandler)
    
    func unregisterRoomEventHandler(_ handler: AgoraEduRoomHandler)
}

// MARK: - User
@objc public protocol AgoraEduUserHandler: NSObjectProtocol {
    /// 远端用户加入 (v2.0.0)
    /// - parameter user: 加入的远端用户
    @objc optional func onRemoteUserJoined(user: AgoraEduContextUserInfo)
    
    /// 远端用户离开 (v2.0.0)
    /// - parameter user: 离开的远端用户
    /// - parameter operatorUser: 操作者，可为空
    /// - parameter reason: 离开的原因（默认为normal）
    @objc optional func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                                         operatorUser: AgoraEduContextUserInfo?,
                                         reason: AgoraEduContextUserLeaveReason)
    
    /// 用户信息更新 (v2.0.0)
    /// - parameter user: 更新的用户
    /// - parameter operatorUser: 操作者，可为空
    @objc optional func onUserUpdated(user: AgoraEduContextUserInfo,
                                      operatorUser: AgoraEduContextUserInfo?)

    /// 开始连麦的用户 (v2.0.0)
    /// - parameter userList: 开始连麦的用户列表
    /// - parameter operatorUser: 操作者
    @objc optional func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                                              operatorUser: AgoraEduContextUserInfo?)
    
    /// 结束连麦的用户 (v2.0.0)
    /// - parameter userList: 结束连麦的用户列表
    /// - parameter operatorUser: 操作者
    @objc optional func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                                operatorUser: AgoraEduContextUserInfo?)
    
    /// 用户自定义属性更新 (v2.0.0)
    /// - parameter user: 更新的用户
    /// - parameter changedProperties: 更新的用户属性字典
    /// - parameter cause: 更新的原因，可为空
    /// - parameter operatorUser: 操作者，可为空
    @objc optional func onUserPropertiesUpdated(user: AgoraEduContextUserInfo,
                                                changedProperties: [String: Any],
                                                cause: [String: Any]?,
                                                operatorUser: AgoraEduContextUserInfo?)
    
    /// 用户自定义属性删除 (v2.0.0)
    /// - parameter user: 更新的用户
    /// - parameter deletedProperties: 删除的用户属性列表
    /// - parameter cause: 更新的原因，可为空
    /// - parameter operatorUser: 操作者，可为空
    @objc optional func onUserPropertiesDeleted(user: AgoraEduContextUserInfo,
                                                deletedProperties: [String],
                                                cause: [String: Any]?,
                                                operatorUser: AgoraEduContextUserInfo?)
    
    /// 用户收到奖励 (v2.0.0)
    /// - parameter user: 用户信息
    /// - parameter rewardCount: 奖励个数
    /// - parameter operatorUser: 操作者，可为空
    @objc optional func onUserRewarded(user: AgoraEduContextUserInfo,
                                       rewardCount: Int,
                                       operatorUser: AgoraEduContextUserInfo?)
    
    /// 自己被踢出 (v2.0.0)
    @objc optional func onLocalUserKickedOut()
    
    /// 是否可以挥手 (v2.0.0)
    /// - parameter enable: 是否可以挥手
    @objc optional func onUserHandsWaveEnable(enable: Bool)
    
    /// 用户挥手 (v2.0.0)
    /// - parameter user: 举手用户
    /// - parameter duration: 举手的时长，单位秒
    @objc optional func onUserHandsWave(user: AgoraEduContextUserInfo,
                                        duration: Int)
    
    /// 用户手放下，结束上台申请（v2.0.0)
    /// - parameter fromUser: 手放下的用户
    /// - note: 无论是用户自己取消举手，还是举手申请被接受，都要走这个回调
    @objc optional func onUserHandsDown(user: AgoraEduContextUserInfo)
}

@objc public protocol AgoraEduUserContext: NSObjectProtocol {
    /// 获取本地用户信息 (v2.0.0)
    /// - returns: 本地用户信息
    func getLocalUserInfo() -> AgoraEduContextUserInfo
    
    /// 获取所有在线用户信息 (v2.0.0)
    /// - returns: 用户列表数组
    func getCoHostList() -> [AgoraEduContextUserInfo]?
    
    /// 获取指定角色的用户信息数组 (v2.0.0)
    /// - parameter role: 角色
    /// - returns: 用户信息数组
    func getUserList(role: AgoraEduContextUserRole) -> [AgoraEduContextUserInfo]?
    
    /// 获取所有用户信息 (v2.0.0)
    /// - parameter role: 角色
    /// - returns: 用户信息数组
    func getAllUserList() -> [AgoraEduContextUserInfo]
    
    /// 更新用户自定义属性 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter properties: 更新属性。支持path修改和整体修改 {"key.subkey":"1"}  和 {"key":{"subkey":"1"}}
    /// - parameter cause: 修改原因。可为空, nullable
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func updateUserProperties(userUuid: String,
                              properties: [String: Any],
                              cause: [String: Any]?,
                              success: AgoraEduContextSuccess?,
                              failure: AgoraEduContextFailure?)
    
    /// 删除用户自定义属性 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter keyPaths: 要删除的属性
    /// - parameter cause: 删除原因。可为空, nullable
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func deleteUserProperties(userUuid: String,
                              keyPaths: [String],
                              cause: [String: Any]?,
                              success: AgoraEduContextSuccess?,
                              failure: AgoraEduContextFailure?)
    
    /// 获取用户自定义属性 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - returns: 用户自定义属性，可为空
    func getUserProperties(userUuid: String) -> [String: Any]?
    
    /// 获取用户的发奖数 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - returns: Int, 奖励数
    func getUserRewardCount(userUuid: String) -> Int
    
    /// 是否可以挥手 (v2.0.0)
    /// - parameter enable: 是否可以挥手
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: Bool, 是否可以挥手
    func getHandsWaveEnable() -> Bool
    
    /// 举手，申请上台 (v2.0.0)
    /// - parameter duration: 举手申请的时长，单位秒
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func handsWave(duration: Int,
                   success: AgoraEduContextSuccess?,
                   failure: AgoraEduContextFailure?)

    /// 手放下，取消申请上台 (v2.0.0)
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func handsDown(success: AgoraEduContextSuccess?,
                   failure: AgoraEduContextFailure?)
    
    /// 事件监听
    /// - parameter handler: 监听者
    /// - returns: void
    func registerUserEventHandler(_ handler: AgoraEduUserHandler)
    
    func unregisterUserEventHandler(_ handler: AgoraEduUserHandler)
}

// MARK: - Media
@objc public protocol AgoraEduMediaHandler: NSObjectProtocol {
    /// 音量变化 (v2.0.0)
    /// - parameter volume: 音量
    /// - parameter streamUuid: 流 Id
    /// - returns: Void
    @objc optional  func onVolumeUpdated(volume: Int,
                                         streamUuid: String)
    
    /// 设备状态更新 (v2.0.0)
    /// - parameter device: 设备信息
    /// - parameter state: 设备状态
    /// - returns: Void
    @objc optional func onLocalDeviceStateUpdated(device: AgoraEduContextDeviceInfo,
                                                  state: AgoraEduContextDeviceState)
    
    /// 混音状态变化 (v2.0.0)
    /// - parameter stateCode: 状态码
    /// - parameter errorCode: 错误码
    /// - returns: Void
    @objc optional func onAudioMixingStateChanged(stateCode: Int,
                                                  errorCode: Int)
}

@objc public protocol AgoraEduMediaContext: NSObjectProtocol {
    /// 获取设备列表 (v2.0.0)
    /// - parameter deviceType: 设备类型
    /// - returns: [AgoraEduContextDeviceInfo], 设备列表
    func getLocalDevices(deviceType: AgoraEduContextDeviceType) -> [AgoraEduContextDeviceInfo]
    
    /// 打开设备 (v2.0.0)
    /// - parameter device: 设备信息
    /// - returns: AgoraEduContextError, 返回错误
    func openLocalDevice(device: AgoraEduContextDeviceInfo) -> AgoraEduContextError?
    
    /// 关闭设备 (v2.0.0)
    /// - parameter device: 设备信息
    /// - returns: AgoraEduContextError, 返回错误
    func closeLocalDevice(device: AgoraEduContextDeviceInfo) -> AgoraEduContextError?
    
    /// 打开设备 (v2.0.0)
    /// - parameter device: 系统设备枚举
    /// - returns: AgoraEduContextError, 返回错误
    func openLocalDevice(systemDevice: AgoraEduContextSystemDevice) -> AgoraEduContextError?
    
    /// 关闭设备 (v2.0.0)
    /// - parameter device: 系统设备枚举
    /// - returns: AgoraEduContextError, 返回错误
    func closeLocalDevice(systemDevice: AgoraEduContextSystemDevice) -> AgoraEduContextError?
    
    /// 获取设备状态 (v2.0.0)
    /// - parameter device: 设备信息
    /// - parameter success: 参数正确，返回设备状态
    /// - parameter fail: 参数错误
    /// - returns: AgoraEduContextError, 返回错误
    func getLocalDeviceState(device: AgoraEduContextDeviceInfo,
                             success: (AgoraEduContextDeviceState) -> (),
                             failure: (AgoraEduContextError) -> ())
    
    /// 渲染视频流 (v2.0.0)
    /// - parameter view: 渲染视频的容器
    /// - parameter renderConfig: 渲染配置
    /// - parameter streamUuid: 流 Id
    /// - returns: AgoraEduContextError, 返回错误
    func startRenderVideo(view: UIView,
                          renderConfig: AgoraEduContextRenderConfig,
                          streamUuid: String) -> AgoraEduContextError?
    
    /// 停止渲染视频流 (v2.0.0)
    /// - parameter streamUuid: 流 Id
    /// - returns: AgoraEduContextError, 返回错误
    func stopRenderVideo(streamUuid: String) -> AgoraEduContextError?
    
    /// 开启混音 (v2.0.0)
    /// - parameter filePath: 需要混音的文件路径
    /// - parameter loopback: 是否只在本地客户端播放音乐文件
    /// - parameter replace: 是否将麦克风采集的音频替换为音乐文件
    /// - parameter cycle: 音乐文件的播放次数
    /// - Returns: AgoraEduContextError, 返回错误，为空代表成功
    func startAudioMixing(filePath: String,
                          loopback: Bool,
                          replace: Bool,
                          cycle: Int) -> AgoraEduContextError?
    
    /// 关闭混音 (v2.0.0)
    /// - Returns: AgoraEduContextError, 返回错误，为空代表成功
    func stopAudioMixing() -> AgoraEduContextError?
    
    /// 设置音频混合文件的播放起始位置 (v2.0.0)
    /// - Returns: AgoraEduContextError, 返回错误，为空代表成功
    func setAudioMixingPosition(position: Int) -> AgoraEduContextError?
    
    /// 注册事件监听
    /// - returns: Void
    func registerMediaEventHandler(_ handler: AgoraEduMediaHandler)
    
    func unregisterMediaEventHandler(_ handler: AgoraEduMediaHandler)
}

// MARK: - Stream
@objc public protocol AgoraEduStreamHandler: NSObjectProtocol {
    /// 远端流加入频道事件 (v2.0.0)
    /// - parameter stream: 流信息
    /// - parameter operatorUser: 操作人，可以为空
    /// - returns: void
    @objc optional func onStreamJoined(stream: AgoraEduContextStreamInfo,
                                       operatorUser: AgoraEduContextUserInfo?)
    
    /// 远端流离开频道事件 (v2.0.0)
    /// - parameter stream: 流信息
    /// - parameter operatorUser: 操作人，可以为空
    /// - returns: void
    @objc optional func onStreamLeft(stream: AgoraEduContextStreamInfo,
                                     operatorUser: AgoraEduContextUserInfo?)
    
    /// 远端流更新事件 (v2.0.0)
    /// - parameter stream: 流信息
    /// - parameter operatorUser: 操作人，可以为空
    /// - returns: void
    @objc optional func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                                        operatorUser: AgoraEduContextUserInfo?)
}

@objc public protocol AgoraEduStreamContext: NSObjectProtocol {
    /// 获取某个用户的一组流信息 (v2.0.0)
    /// - parameter userUuid: 用户Id
    /// - returns: [AgoraEduContextStream]， 流信息的数组，可以为空
    func getStreamList(userUuid: String) -> [AgoraEduContextStreamInfo]?
    
    /// 获取所有的流信息 (v2.0.0)
    /// - parameter userUuid: 用户Id
    /// - returns: [AgoraEduContextStream]， 流信息的数组，可以为空
    func getAllStreamList() -> [AgoraEduContextStreamInfo]?
    
    /// 设置本地流的视频配置(v1.2.0)
    /// - parameter streamUuid: 流id
    /// - parameter config: 视频配置
    /// - returns: AgoraEduContextError
    func setLocalVideoConfig(streamUuid: String,
                             config: AgoraEduContextVideoStreamConfig) -> AgoraEduContextError?
    
    /// 选择订阅高/低分辨率的视频流 (v2.0.0)
    /// - parameter streamUuid: 流Id
    /// - parameter level: 分辨率类型
    /// - returns: void
    func setRemoteVideoStreamSubscribeLevel(streamUuid: String,
                                            level: AgoraEduContextVideoStreamSubscribeLevel) -> AgoraEduContextError?
    
    /// 注册流事件回调 (v2.0.0)
    /// - parameter handler: 遵守 AgoraEduStreamHandler 的对象
    /// - returns: void
    func registerStreamEventHandler(_ handler: AgoraEduStreamHandler)
    
    /// 注销流事件回调 (v2.0.0)
    /// - parameter handler: 遵守 AgoraEduStreamHandler 的对象
    /// - returns: void
    func unregisterStreamEventHandler(_ handler: AgoraEduStreamHandler)
}

// MARK: - Monitor
@objc public protocol AgoraEduMonitorHandler: NSObjectProtocol {
    /// 本地网络质量更新(v2.0.0)
    /// - parameter quality: 网络质量
    /// - returns: void
    @objc optional func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality)
    
    /// 本地与服务器的连接状态
    /// - parameter state: 连接
    /// - returns: void
    @objc optional func onLocalConnectionUpdated(state: AgoraEduContextConnectionState)
}

@objc public protocol AgoraEduMonitorContext: NSObjectProtocol {
    /// 上传日志(v2.0.0)
    /// - parameter success: 上传成功，获取日志的id
    /// - parameter failure: 上传失败
    /// - returns: void
    func uploadLog(success: AgoraEduContextSuccessWithString?,
                   failure: AgoraEduContextFailure?)
    
    /// 注册SDK状态监控事件回调 (v2.0.0)
    /// - parameter handler: 遵守 AgoraEduMonitorHandler 的对象
    /// - returns: void
    func registerMonitorEventHandler(_ handler: AgoraEduMonitorHandler)
    
    func unregisterMonitorEventHandler(_ handler: AgoraEduMonitorHandler)
}
