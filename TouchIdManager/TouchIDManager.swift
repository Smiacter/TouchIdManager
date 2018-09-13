//
//  TouchIDManager.swift
//  JYTraining
//
//  Created by Smiacter on 2017/8/7.
//  Copyright © 2017年 Jinyi. All rights reserved.
//
//  指纹解锁管理

import UIKit
import LocalAuthentication

/// 屏幕
public let ScreenWidth     = UIScreen.main.bounds.width
public let ScreenHeight    = UIScreen.main.bounds.height
/// 通过宽高判断是否是iPhoneX TODO: 型号多了通过iPhone型号判断
public let isiPhoneX = (ScreenWidth == 375 && ScreenHeight == 812) ? true : false
/// 指纹解锁/面容错误通知Key
public let KeyNotificationTouchIdFail = "KeyNotificationTouchIdFail"

public struct TouchIDManager {
    // singletone
    public static let shared = TouchIDManager()
    private init() {
        // some private initialize
    }
}

public extension TouchIDManager {
    enum TouchIDErrorType {
        case userCancel, authenticationFailed, touchIDLockout, userFallback, none, appCancel, systemCancel
    }
    
    func isTouchIdAvaliable() -> Bool {
        // TouchID API只有在8.0以上能够使用
        // 注：为了方便使用，目前只做了9.0以上的TouchID支持，如有需要在适配8.0，需要重写一套
        if #available(iOS 8.0, *) {
            let context = LAContext()
            var error: NSError?
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) //  deviceOwnerAuthentication
        } else {
            return false
        }
    }
    
    func useTouchIdUnlock(unlockSuccess: (() -> ())? = nil, unlockFail: ((TouchIDErrorType) -> ())? = nil) {
        
        let context = LAContext()
        var error: NSError?
        
        if #available(iOS 8.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                
                let localizedReasonString = isiPhoneX ? "使用Face ID进行解锁" : "通过Home键验证已有指纹解锁"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReasonString, reply: { (success, evaluateError) in
                    if success {
                        // User authenticated successfully, take appropriate action
                        if #available(iOS 11.0, *) {
                            if context.biometryType == LABiometryType.faceID {
                                
                            } else if context.biometryType == LABiometryType.touchID {
                                
                            } else { // none: The device does not support biometry
                                
                            }
                        } else {
                            
                        }
                        DispatchQueue.main.async {
                            if let success = unlockSuccess {
                                success()
                            }
                        }
                    } else {
                        // User did not authenticate successfully, look at error and take appropriate action
                        if let error = evaluateError as NSError? {
                            self.touchIdErrorHandle(errorCode: error.code, context: context)
                        }
                    }
                })
            } else {
                // Could not evaluate policy; look at authError and present an appropriate message to user
                // 不支持
                if let error = error as NSError? {
                    touchIdErrorHandle(errorCode: error.code, context: context)
                }
            }
        } else {
            // iOS 8 之前版本
        }
        
    }
    
    /// TouchID相关错误处理 errorCode: 错误类型码 context: 在指纹错误次数达到上限时弹出系统密码验证
    public func touchIdErrorHandle(errorCode: Int, context: LAContext) {
        if #available(iOS 9.0, *) {
            if errorCode == LAError.touchIDLockout.rawValue {
                // TouchID被锁定，因为输入的TouchID达到了一定的错误次数 - 提醒用户或者弹出系统密码输入
                let localizedReasonString = isiPhoneX ? "使用Face ID进行解锁" : "通过Home键验证已有指纹解锁"
                // 当被锁定后，需要使用deviceOwnerAuthentication发起系统密码验证，以重新启用TouchID
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReasonString, reply: { (success, error) in
                    if success {
                        // 看是直接进入界面还是让用户继续使用指纹解锁
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil, userInfo: ["type": 1])
                    } else {
                        // 系统密码验证也失败，给出提示并跳转到登录页重新登录
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil, userInfo: ["type": -1])
                    }
                })
            } else if errorCode == LAError.appCancel.rawValue {
                // 被应用取消，比如当身份验证正在进行时，调用了invalidate
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil, userInfo: ["type": -5])
            }
        }
        if errorCode == LAError.userFallback.rawValue {
            // 用户选择使用密码 - 使用密码进行解锁
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil, userInfo: ["type": 0])
        } else if errorCode == LAError.authenticationFailed.rawValue {
            // 验证失败 - 提示指纹不匹配 可再次点击
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil, userInfo: ["type": -2])
        } else if errorCode == LAError.userCancel.rawValue {
            // 用户取消 - 调到登录界面
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil, userInfo: ["type": -3])
        } else if errorCode == LAError.systemCancel.rawValue {
            // 系统取消 - 保持在TouchID解说界面，点击按钮重新弹出TouchID进行解锁
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil, userInfo: ["type": -4])
        }
        
    }
}

// MARK: --- 备用 仅iOS 9.0以上的指纹支持

//if #available(iOS 9.0, *) {
//    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
//        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "通过Home键验证已有手机指纹", reply: { (success, error) in
//            if success {
//                DispatchQueue.main.async {
//                    if let success = unlockSuccess {
//                        success()
//                    }
//                }
//            } else {
//                if let nError = error as NSError? {
//                    let errorType = self.touchIdErrorHandle(errorCode: nError.code, context: context)
//                    if let fail = unlockFail {
//                        fail(errorType)
//                    }
//                }
//            }
//        })
//    } else {
//    }
//} else {
//    // Fallback on earlier versions
//}

