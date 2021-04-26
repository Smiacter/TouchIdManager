# Description
TouchId/FaceId manager use on iOS 8 or later iOS 8以上的指纹/面容解锁简单封装

[![CocoaPods](https://img.shields.io/cocoapods/v/KJTouchIdManager.svg)](https://cocoapods.org/pods/KJTouchIdManager)
[![CocoaPods](https://img.shields.io/cocoapods/p/KJTouchIdManager.svg)](https://github.com/Smiacter/TouchIdManager)
[![CocoaPods](https://img.shields.io/cocoapods/l/KJTouchIdManager.svg)](https://github.com/Smiacter/TouchIdManager)

# Function               
* support iOS8+ 兼容iOS8以上系统
* support face id 支持面容解锁   
* support show system pwd to reactive touch id 支持锁定后弹出系统密码确认（认证流程同支付宝）

# 效果图

### FaceID

![image](https://github.com/Smiacter/TouchIdManager/blob/master/FaceID.gif)

### TouchID

![image](https://github.com/Smiacter/TouchIdManager/blob/master/TouchID.gif)

# Usage

### cocoapods

add KJTouchIdManager to your Podfile 在Podfile中加入（pod名称和实际代码类名称不符，是一开始没有想好如何命名，见谅[Lol]）

```
pod 'KJTouchIdManager'
```

run `pod install` 运行安装命令：

```
pod install
```

### 手动导入

Drop TouchIdManager fold to your project 将TouchIdManager文件夹拖到你的工程目录（文件夹名称和实际代码类名称不符，是一开始没有想好如何命名，见谅[Lol]）

### 使用

1. declare an instance 声明一个实例

```Swift
var laManager = LAManager()
```

2. do some config 进行配置，设置认证结果代理，弹框标题等

```Swift
// 设置代理，处理认证结果回调
laManager.resultDelegate = self
// 解锁失败后用户操作按钮的文字，默认为”输入密码“
laManager.localizedFallbackTitle = "使用密码登录应用"
// 解锁失败后的提示文字
laManager.localizedReason = "面容ID短时间内失败多次，您可以再次尝试或使用密码登录"
```

3. implement protocol LAHandleable, handle result 实现认证结果代理，处理成功或失败操作

```Swift
/// 遵循认证结果协议代理
/// 结果枚举详见LAResult
extension LockViewController: LAHandleable {
    
    func handleLAResult(result: LAResult) {
        switch result {
        case .success:
            dismiss(animated: true, completion: nil)
        case .userFallback:
            print("跳转到登录页，使用密码登录")
        case .biometryNotEnrolled
          	print("您没有设置面容ID")
        case ...
        default: ()
        }
    }
}
```

4. optional method 可选（判断TouchID/FaceID是否可用）

```
// 判断指纹/面容是否可用，如果不可用可直接跳过认证逻辑或者不显示相关认证按钮等信息
let isAvaliable = laManager.isAvaliable()
```

# Demo说明

Demo模拟了在设置中开启/关闭指纹识别/面容解锁。开启后如果要看效果，需要将应用退到Home界面在进入，代码是在AppDelegate中applicationWillEnterForeground触发的。在实际开发项目中，LockViewController可以根据自己的项目需求进行调整，做成密码输入、手势输入等。

# Change log

### 2021.04.25

1. 重新调整认证逻辑，整体流程同支付宝登录认证
2. 适配使用Swift5
3. **[Breaking change]**更改文件名、类名为LA开头，替换之前的TouchID开头，避免歧义
4. 使用实例的声明方式，替换之前的单例
5. **[Breaking change]**使用协议代理的方式处理认证结果，替换之前的通知模式；枚举代替数字，表达更清晰

# License

KJTouchIdManager is available under the MIT license. See the LICENSE file for more info.
