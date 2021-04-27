//
//  LAManager.swift
//  TouchIdManager
//
//  Created by Smiacter on 2017/8/7.
//  Copyright © 2017年 Jinyi. All rights reserved.
//
//  同支付宝登录流程的 TouchID/FaceID解锁管理

import UIKit
import LocalAuthentication

public struct LAManager {
    public init() {}
    /// 代理-处理解锁结果
    public weak var resultDelegate: LAHandleable?
    
    /// 解锁失败后用户操作按钮的文字，默认为”输入密码“，对应事件可在resultDelegate中的userFallback枚举实现
    public var localizedFallbackTitle = "输入密码"
    /// 解锁提示文字（面容ID：失败一次会提示默认的”再试一次“，第二次失败后弹出Fallback时才使用localizedReason；TouchID：第一次弹框显示的提示就是localizedReason；所以在提示文字上稍微有点不同）
    public var localizedReason = isiPhoneX ? "面容ID解锁失败，请重试" : "通过Home键使用已有指纹解锁"
}

/// 逻辑介绍（同支付宝登录流程），鉴定方式LAPolicy选择
/// TouchID/FaceID的触发方式采用生物识别deviceOwnerAuthenticationWithBiometrics，FaceID五次失败后被锁定
/// 此时使用生物识别+密码认证deviceOwnerAuthentication进行系统密码框的弹起，方便解锁（在biometryLockout/touchIDLockout手动触发）
/// 如果不使用deviceOwnerAuthentication，需要去设置中介绍才能继续调用TouchID/FaceID识别，相对麻烦
///
extension LAManager {
    
    /// TouchID/FaceID是否可用（注意：只会返回可用不可用，不会返回不可用的原因。若要处理原因，请直接调用evokeLocalAuthentication，实现代理）
    /// 使用deviceOwnerAuthentication鉴定方式，iOS 8.0以上开始支持指纹，且需要相关硬件完好
    public func isAvaliable() -> Bool {
        if #available(iOS 8.0, *) {
            let context = LAContext()
            var error: NSError?
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        } else {
            return false
        }
    }
    
    /// 唤起TouchID/FaceID进行解锁【配合代理使用】
    /// 解锁结果通过实现TouchIdHandleable代理实现，结果枚举详见TouchIdResult
    /// 鉴定方式LAPolicy区别：
    ///     deviceOwnerAuthenticationWithBiometrics: 生物识别(iOS 8+), 错误最大次数（5次）后TouchID/FaceID会被锁住，期间会弹三次框，点取消后可重新进行解锁尝试，锁住后需要到设置里面去解锁才能重新认证
    ///     deviceOwnerAuthentication: 生物识别+密码认证(iOS 9+),
    ///         TouchID失败三次后会弹出系统密码验证，不输入密码点取消还有两次指纹识别，如果都失败TouchID被锁住，接下来都是通过系统密码进行验证；
    ///         FaceID失败五次后会被锁住，之后的每次调用都会弹出系统密码进行验证
    public func evokeLocalAuthentication() {
        guard #available(iOS 8.0, *) else {
            // 版本过低
            resultDelegate?.handleLAResult(result: .versionNotSupport)
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        // 此处使用canEvaluatePolicy进行判断，巧妙的在使用deviceOwnerAuthenticationWithBiometrics方式被锁定后捕获错误
        // 在LAErrorHandle中通过使用deviceOwnerAuthentication立马触发系统密码以达到解除锁定的目的
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            lAErrorHandle(errorCode: error?.code ?? 0, context: context)
            return
        }
        
        context.localizedFallbackTitle = localizedFallbackTitle
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: { (success, evaluateError) in
            DispatchQueue.main.async {
                if success {
                    self.resultDelegate?.handleLAResult(result: .success)
                } else {
                    if let error = evaluateError as NSError? {
                        self.lAErrorHandle(errorCode: error.code, context: context)
                    }
                }
            }
        })
    }
    
    /// LA相关错误处理【配合代理使用】
    /// 枚举定义同iOS Framework定义，详见枚举定义LAResult
    /// 通过实现LAHandleable代理handleLAResult回调方法，处理常见错误
    /// 参数：
    ///   - errorCode: 错误类型码
    ///   - context: LAContext
    private func lAErrorHandle(errorCode: Int, context: LAContext) {
        if errorCode == LAError.authenticationFailed.rawValue {
            resultDelegate?.handleLAResult(result: .authenticationFailed)
        } else if errorCode == LAError.userCancel.rawValue {
            resultDelegate?.handleLAResult(result: .userCancel)
        } else if errorCode == LAError.userFallback.rawValue {
            resultDelegate?.handleLAResult(result: .userFallback)
        } else if errorCode == LAError.systemCancel.rawValue {
            resultDelegate?.handleLAResult(result: .systemCancel)
        } else if errorCode == LAError.passcodeNotSet.rawValue {
            resultDelegate?.handleLAResult(result: .passcodeNotSet)
        } else { // 判断iOS系统版本，高版本包含低版本，保证低设备型号运行高iOS版本的正确错误捕获
            if #available(iOS 11.0, *) {
                
                // --- iOS 11+ ---
                
                if errorCode == LAError.biometryNotAvailable.rawValue {
                    resultDelegate?.handleLAResult(result: .biometryNotAvailable)
                } else if errorCode == LAError.biometryNotEnrolled.rawValue {
                    resultDelegate?.handleLAResult(result: .biometryNotEnrolled)
                } else if errorCode == LAError.biometryLockout.rawValue {
                    // 面容识别错误达到一定次数被锁定；换用deviceOwnerAuthentication「生物识别+密码认证」可立马触发系统密码框解锁【关键处理】
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason, reply: { (success, error) in

                    })
                }
                
                // --- iOS 9+ ---
                
                else if errorCode == LAError.touchIDLockout.rawValue {
                    // 指纹识别错误达到一定次数被锁定；换用deviceOwnerAuthentication「生物识别+密码认证」可立马触发系统密码框解锁【关键处理】
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason, reply: { (success, error) in
                        
                    })
                } else if errorCode == LAError.appCancel.rawValue {
                    resultDelegate?.handleLAResult(result: .appCancel)
                } else if errorCode == LAError.invalidContext.rawValue {
                    resultDelegate?.handleLAResult(result: .invalidContext)
                }
                
                // --- iOS 8+ ---
                
                else if errorCode == LAError.touchIDNotAvailable.rawValue {
                    resultDelegate?.handleLAResult(result: .touchIdNotAvailable)
                } else if errorCode == LAError.touchIDNotEnrolled.rawValue {
                    resultDelegate?.handleLAResult(result: .touchIDNotEnrolled)
                }
                
                // --- 硬件不支持指纹或面容解锁（或设备损坏）所有的错误类型都枚举完了且iOS版本检验也过，只能是硬件设备不支持了 ---
                else {
                    resultDelegate?.handleLAResult(result: .deviceNotSupport)
                }
            } else if #available(iOS 9.0, *) {
                
                // --- iOS 9+ ---
                
                if errorCode == LAError.touchIDLockout.rawValue {
                    // 指纹识别错误达到一定次数被锁定；换用deviceOwnerAuthentication「生物识别+密码认证」可立马触发系统密码框解锁【关键处理】
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason, reply: { (success, error) in
                        
                    })
                } else if errorCode == LAError.appCancel.rawValue {
                    resultDelegate?.handleLAResult(result: .appCancel)
                } else if errorCode == LAError.invalidContext.rawValue {
                    resultDelegate?.handleLAResult(result: .invalidContext)
                }
                
                // --- iOS 8+ ---
                
                else if errorCode == LAError.touchIDNotAvailable.rawValue {
                    resultDelegate?.handleLAResult(result: .touchIdNotAvailable)
                } else if errorCode == LAError.touchIDNotEnrolled.rawValue {
                    resultDelegate?.handleLAResult(result: .touchIDNotEnrolled)
                }
                
                // --- 不支持指纹或面容解锁（或设备损坏） ---
                else {
                    resultDelegate?.handleLAResult(result: .deviceNotSupport)
                }
            } else { // iOS 9以前的系统，此处省略了#available(iOS 8.0, *)判断，该判断前面已做
                
                // --- iOS 8+ ---
                
                if errorCode == LAError.touchIDNotAvailable.rawValue {
                    resultDelegate?.handleLAResult(result: .touchIdNotAvailable)
                } else if errorCode == LAError.touchIDNotEnrolled.rawValue {
                    resultDelegate?.handleLAResult(result: .touchIDNotEnrolled)
                }
                
                // --- 不支持指纹或面容解锁（或设备损坏） ---
                else {
                    resultDelegate?.handleLAResult(result: .deviceNotSupport)
                }
            }
        }
    }
    
    /// block/closure的方式进行认证，具体说明可参考evokeLocalAuthentication
    public func evokeLocalAuthenticationWith(closure: ((LAResult) -> ())?) {
        guard #available(iOS 8.0, *) else {
            // 版本过低
            closure?(.versionNotSupport)
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        // 此处使用canEvaluatePolicy进行判断，巧妙的在使用deviceOwnerAuthenticationWithBiometrics方式被锁定后捕获错误
        // 在LAErrorHandle中通过使用deviceOwnerAuthentication立马触发系统密码以达到解除锁定的目的
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            lAErrorHandleWith(closure: closure, errorCode: error?.code ?? 0, context: context)
            return
        }
        
        context.localizedFallbackTitle = localizedFallbackTitle
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: { (success, evaluateError) in
            DispatchQueue.main.async {
                if success {
                    closure?(.success)
                } else {
                    if let error = evaluateError as NSError? {
                        self.lAErrorHandleWith(closure: closure, errorCode: error.code, context: context)
                    }
                }
            }
        })
    }
    
    /// LA相关错误处理【配合closure使用】，具体说明参考lAErrorHandle，代码高度一致，只是换用closure进行回调
    private func lAErrorHandleWith(closure: ((LAResult) -> ())?, errorCode: Int, context: LAContext) {
        if errorCode == LAError.authenticationFailed.rawValue {
            closure?(.authenticationFailed)
        } else if errorCode == LAError.userCancel.rawValue {
            closure?(.userCancel)
        } else if errorCode == LAError.userFallback.rawValue {
            closure?(.userFallback)
        } else if errorCode == LAError.systemCancel.rawValue {
            closure?(.systemCancel)
        } else if errorCode == LAError.passcodeNotSet.rawValue {
            closure?(.passcodeNotSet)
        } else { // 判断iOS系统版本，高版本包含低版本，保证低设备型号运行高iOS版本的正确错误捕获
            if #available(iOS 11.0, *) {
                
                // --- iOS 11+ ---
                
                if errorCode == LAError.biometryNotAvailable.rawValue {
                    closure?(.biometryNotAvailable)
                } else if errorCode == LAError.biometryNotEnrolled.rawValue {
                    closure?(.biometryNotEnrolled)
                } else if errorCode == LAError.biometryLockout.rawValue {
                    // 面容识别错误达到一定次数被锁定；换用deviceOwnerAuthentication「生物识别+密码认证」可立马触发系统密码框解锁【关键处理】
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason, reply: { (success, error) in

                    })
                }
                
                // --- iOS 9+ ---
                
                else if errorCode == LAError.touchIDLockout.rawValue {
                    // 指纹识别错误达到一定次数被锁定；换用deviceOwnerAuthentication「生物识别+密码认证」可立马触发系统密码框解锁【关键处理】
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason, reply: { (success, error) in
                        
                    })
                } else if errorCode == LAError.appCancel.rawValue {
                    closure?(.appCancel)
                } else if errorCode == LAError.invalidContext.rawValue {
                    closure?(.invalidContext)
                }
                
                // --- iOS 8+ ---
                
                else if errorCode == LAError.touchIDNotAvailable.rawValue {
                    closure?(.touchIdNotAvailable)
                } else if errorCode == LAError.touchIDNotEnrolled.rawValue {
                    closure?(.touchIDNotEnrolled)
                }
                
                // --- 硬件不支持指纹或面容解锁（或设备损坏）所有的错误类型都枚举完了且iOS版本检验也过，只能是硬件设备不支持了 ---
                else {
                    closure?(.deviceNotSupport)
                }
            } else if #available(iOS 9.0, *) {
                
                // --- iOS 9+ ---
                
                if errorCode == LAError.touchIDLockout.rawValue {
                    // 指纹识别错误达到一定次数被锁定；换用deviceOwnerAuthentication「生物识别+密码认证」可立马触发系统密码框解锁【关键处理】
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason, reply: { (success, error) in
                        
                    })
                } else if errorCode == LAError.appCancel.rawValue {
                    closure?(.appCancel)
                } else if errorCode == LAError.invalidContext.rawValue {
                    closure?(.invalidContext)
                }
                
                // --- iOS 8+ ---
                
                else if errorCode == LAError.touchIDNotAvailable.rawValue {
                    closure?(.touchIdNotAvailable)
                } else if errorCode == LAError.touchIDNotEnrolled.rawValue {
                    closure?(.touchIDNotEnrolled)
                }
                
                // --- 不支持指纹或面容解锁（或设备损坏） ---
                else {
                    closure?(.deviceNotSupport)
                }
            } else { // iOS 9以前的系统，此处省略了#available(iOS 8.0, *)判断，该判断前面已做
                
                // --- iOS 8+ ---
                
                if errorCode == LAError.touchIDNotAvailable.rawValue {
                    closure?(.touchIdNotAvailable)
                } else if errorCode == LAError.touchIDNotEnrolled.rawValue {
                    closure?(.touchIDNotEnrolled)
                }
                
                // --- 不支持指纹或面容解锁（或设备损坏） ---
                else {
                    closure?(.deviceNotSupport)
                }
            }
        }
    }
}
