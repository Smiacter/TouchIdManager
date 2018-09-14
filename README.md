# Description
TouchId/FaceId manager use on iOS 8 or later iOS 8以上的指纹/面容解锁简单封装

[![CocoaPods](https://img.shields.io/cocoapods/v/KJTouchIdManager.svg)](https://cocoapods.org/pods/KJTouchIdManager)
[![CocoaPods](https://img.shields.io/cocoapods/p/KJTouchIdManager.svg)](https://github.com/Smiacter/TouchIdManager)
[![CocoaPods](https://img.shields.io/cocoapods/l/KJTouchIdManager.svg)](https://github.com/Smiacter/TouchIdManager)

# Function               
* support iOS8+ 兼容iOS8以上系统
* support face id 支持面容解锁   
* support show system pwd to reactive touch id 支持锁定后弹出系统密码确认

# Usage
1. Drop TouchIdManager fold to your project 将TouchIdManager文件夹拖到你的工程目录

2. add notification to hanle error 添加错误处理通知，在当前VC处理解锁失败

```Swift
NotificationCenter.default.addObserver(self, selector: #selector(touchIdErrorHandle(noti:)), name: NSNotification.Name(rawValue: KeyNotificationTouchIdFail), object: nil)
```

3. use singleton to active touch id 唤起解锁

```Swift
TouchIDManager.shared.useTouchIdUnlock(unlockSuccess: {
            // success handle
            self.dismiss(animated: true, completion: nil)
        }) { (errorType) in
        }
```

4. handle error 处理解锁失败

```Swift
func touchIdErrorHandle(noti: Notification) {
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
```
# License
KJTouchIdManager is available under the MIT license. See the LICENSE file for more info.
