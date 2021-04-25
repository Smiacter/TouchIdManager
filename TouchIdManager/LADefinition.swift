//
//  LADefinition.swift
//  TouchIdManager
//
//  Created by Smiacter on 2018/9/28.
//  Copyright © 2018 Smiacter. All rights reserved.
//

/// 屏幕宽高
public let ScreenWidth     = UIScreen.main.bounds.width
public let ScreenHeight    = UIScreen.main.bounds.height

/// 通过宽高（pt）判断是否是iPhoneX刘海屏系列 [老方法]
//public let isiPhoneX = xSerial1 || xSerial2 || xSerial3 || xSerial4
/// 网上看到一个更优雅的方式，也是通过pt宽高来实现的（后续继续发布新的iPhone系列也支持）
public let isiPhoneX = ScreenWidth >= 375 && ScreenHeight >= 812

public enum LAResult {
    // --- 自定义 ---
    
    /// 解锁成功
    case success
    /// 设备不支持 - 版本过低
    case versionNotSupport
    /// 设备不支持 - 硬件已损坏
    case deviceNotSupport
    
    // --- 通用 ---
    
    /// 验证失败 - 提示指纹不匹配 可再次点击（还没有达到最大错误次数）
    case authenticationFailed
    /// 用户取消【通常-可点击按钮再次触发指纹/面容解锁】
    case userCancel
    /// 用户选择使用密码 - 【通常-跳转到登录页使用密码进行解锁】
    case userFallback
    /// 系统取消 - 保持在TouchID解锁界面，点击按钮重新弹出TouchID进行解锁
    case systemCancel
    /// 用户没有设置密码，无法使用TouchID/FaceID
    case passcodeNotSet
    
    // --- iOS 11+ ---
    
    /// TouchID/FaceID的硬件不可用
    case biometryNotAvailable
    /// 用户没有设置TouchID/FaceID，无法使用
    case biometryNotEnrolled
    /// 面容识别错误达到一定次数，被锁定
    case biometryLockout
    
    // --- iOS 9+ ---
    
    /// TouchID错误达到了一定次数，被锁定
    case touchIDLockout
    /// 被应用取消，比如当身份验证正在进行时，调用了invalidate
    case appCancel
    /// 传入的LAContext已经无效，如应用被挂起已取消了授权
    case invalidContext
    
    // --- iOS 8+ ---
    
    /// TouchID的硬件不可用
    case touchIdNotAvailable
    /// 指纹识别未开启
    case touchIDNotEnrolled
}

///// iPhoneX; iPhoneXS; iPhone11 Pro; iPhone12 mini;
//private let xSerial1 = (ScreenWidth == 375 && ScreenHeight == 812) ? true : false
///// iPhoneXs Max; iPhoneXr; iPhone11;  iPhone11 Pro Max;
//private let xSerial2 = (ScreenWidth == 414 && ScreenHeight == 896) ? true : false
///// iPhone12; iPhone12 pro;
//private let xSerial3 = (ScreenWidth == 390 && ScreenHeight == 844) ? true : false
///// iPhone12 pro max
//private let xSerial4 = (ScreenWidth == 428 && ScreenHeight == 926) ? true : false
