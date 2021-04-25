//
//  LAHandleable.swift
//  TouchIdManager
//
//  Created by Smiacter on 2018/9/28.
//  Copyright © 2018 Smiacter. All rights reserved.
//

/// 处理回调结果的代理
public protocol LAHandleable: NSObject {
    
    func handleLAResult(result: LAResult)
}


