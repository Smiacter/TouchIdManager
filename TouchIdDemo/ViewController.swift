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
