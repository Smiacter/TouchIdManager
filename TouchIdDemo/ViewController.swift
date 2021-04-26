//
//  ViewController.swift
//  TouchIdDemo
//
//  Created by Smiacter on 2018/1/30.
//  Copyright © 2018年 Smiacter. All rights reserved.
//

import UIKit

/// 指纹解锁/面容开关Key
let KeyIdSwitch = "KeyIdSwitch"

/// 该界面模拟应用中设置界面开启指纹识别/面容解锁（开关）
/// 设置后下一启动判断开关若已打开，则会触发指纹识别/面容解锁（具体的解锁界面是设置成密码、手势，可根据项目需求自行定义）
/// 后台切到前台触发解锁界面的代码详见AppDelegate -> applicationWillEnterForeground
class ViewController: UIViewController {
    /// 指纹解锁或面容解锁类型文字
    @IBOutlet weak var typeLabel: UILabel!
    /// 指纹/面容解锁开关
    @IBOutlet weak var touchIdSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchIdSwitch.isOn = UserDefaults.standard.bool(forKey: KeyIdSwitch)
        touchIdSwitch.addTarget(self, action: #selector(switchAction(swich:)), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 指纹/面容解锁开关点击事件
    @objc func switchAction(swich: UISwitch) {
        UserDefaults.standard.set(swich.isOn, forKey: KeyIdSwitch)
        UserDefaults.standard.synchronize()
    }
    
}
