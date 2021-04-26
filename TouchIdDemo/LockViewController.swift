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
    var laManager = LAManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 添加一个按钮，当指纹/面容解锁不匹配时(指纹验证3次不匹配后)，点击再次弹出解锁
        let button = UIButton(frame: CGRect(x: (ScreenWidth-100) / 2, y: (ScreenHeight-50) / 2 , width: 100, height: 50))
        view.addSubview(button)
        button.backgroundColor = .systemRed
        button.setTitle("\(!isiPhoneX ? "指纹解锁" : "面容解锁")", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(showTouchIdAction), for: .touchUpInside)
        
        // 模拟安全应用登录后从后台到前台，弹出密码框的操作
        guard UserDefaults.standard.bool(forKey: KeyIdSwitch) else {
            return
        }
        // TouchID/FaceID相关设置
        laManager.resultDelegate = self
        laManager.localizedFallbackTitle = "使用密码登录应用"
        laManager.localizedReason = "\(isiPhoneX ? "面容ID短时间内失败多次，您可以再次尝试或使用密码登录" : "使用指纹解锁，若多次失败可点击使用密码登录")"
        // 唤起TouchID/FaceID进行解锁
        laManager.evokeLocalAuthentication()
    }

    @objc func showTouchIdAction() {
        laManager.evokeLocalAuthentication()
    }
}

extension LockViewController: LAHandleable {
    
    func handleLAResult(result: LAResult) {
        print(result)
        switch result {
        case .success:
            dismiss(animated: true, completion: nil)
        case .userFallback:
            alert(message: "跳转到登录页，使用密码登录")
        default:
            alert(message: "\(result)")
        }
    }
    
    func alert(message: String) {
        let alertVC = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { (alert) in
            
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}
