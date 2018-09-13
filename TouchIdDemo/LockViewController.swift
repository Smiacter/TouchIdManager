//
//  LockViewController.swift
//  TouchIdDemo
//
//  Created by Smiacter on 2018/1/30.
//  Copyright © 2018年 Smiacter. All rights reserved.
//
//  启动时锁屏VC

import UIKit
import TouchIdManager

class LockViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        // 添加一个按钮，当指纹/面容解锁不匹配时(指纹验证3次不匹配后)，点击再次弹出解锁
        let button = UIButton(frame: CGRect(x: 13, y: ScreenHeight - 70, width: 100, height: 50))
        view.addSubview(button)
        button.setTitle("\(!isiPhoneX ? "指纹解锁" : "面容解锁")", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(showTouchIdAction), for: .touchUpInside)

        // 自动弹出指纹/面容解锁
        if TouchIDManager.shared.isTouchIdAvaliable(), UserDefaults.standard.bool(forKey: KeyIdSwitch) {
            NotificationCenter.default.addObserver(self, selector: #selector(touchIdErrorHandle(noti:)), name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil)
            touchIdUnlock()
        }
    }

    @objc func showTouchIdAction() {
        touchIdUnlock()
    }
}

extension LockViewController {
    /// 登录或者解除屏幕保护时，弹出指纹解锁
    func touchIdUnlock() {
        TouchIDManager.shared.useTouchIdUnlock(unlockSuccess: {
            // 解锁成功处理
            self.dismiss(animated: true, completion: nil)
        }) { (errorType) in
        }
    }
    
    /// TouchID错误处理
    @objc func touchIdErrorHandle(noti: Notification) {
        // type: 1-锁定后验证系统密码成功 0-点击使用密码登录 -1-锁定后验证系统密码失败 -2-验证失败，指纹不匹配
        //       -3-点击取消按钮 -4-被系统取消 -5-被应用取消
        if let userInfo = noti.userInfo, let type = userInfo["type"] as? Int {
            DispatchQueue.main.async {
                switch type {
                case 1:
                    self.touchIdUnlock()
                case 0:
                    break
                case -1:
                    break
                case -2:
                    let alertVC = UIAlertController(title: "提示", message: "指纹不匹配", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { (alert) in
                        
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                case -3:
                    break
                case -4:
                    break
                case -5:
                    break
                default:
                    break
                }
            }
        }
    }
}
