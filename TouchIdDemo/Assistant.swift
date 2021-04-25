//
//  Assistant.swift
//  TouchIdDemo
//
//  Created by Smiacter on 2018/1/30.
//  Copyright © 2018年 Smiacter. All rights reserved.
//

import UIKit

class Assistant {
    // singletone
    static let shared = Assistant()
    private init() {
        // some private initialize
    }
}

// MARK: --- ViewController
extension Assistant {
    // 获得当前ViewController
    func getCurrentViewController() -> UIViewController {
        
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        let currentVC = getFrom(rootVC: rootVC!)
        
        return currentVC
    }
    
    func getFrom(rootVC: UIViewController) -> UIViewController {
        var root = rootVC
        var controller = UIViewController()
        
        if (root.presentedViewController != nil) {
            root = root.presentedViewController!
        }
        
        if root.isKind(of: ViewController.self) {
            let tabVC = root as! ViewController
            controller = tabVC
        } else if root.isKind(of: UINavigationController.self) {
            let navVC = root as! UINavigationController
            controller = getFrom(rootVC: navVC.visibleViewController!)
        } else {
            controller = root
        }
        
        return controller
    }
    
    // 获取当前VC在Navigation中的索引
    func getCurrentVCIndex(navigationController: UINavigationController, viewController: UIViewController) -> Int {
        let controllers = navigationController.children
        for (index, vc) in controllers.enumerated() {
            if vc == viewController {
                return index
            }
        }
        
        return 0
    }
}
