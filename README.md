# Description
TouchId/FaceId manager use on iOS 8 or later

# Function
* singleton
* support face id 
* use notification to hanle error

# Usage
1. Drop TouchIdManager fold to your project

2. add notification to hanle error

3. use singleton to active touch id
''' c
TouchIDManager.shared.useTouchIdUnlock(unlockSuccess: {
            // 解锁成功处理
            self.dismiss(animated: true, completion: nil)
        }) { (errorType) in
        }
'''



