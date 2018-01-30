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

```Swift
TouchIDManager.shared.useTouchIdUnlock(unlockSuccess: {
            // success handle
            self.dismiss(animated: true, completion: nil)
        }) { (errorType) in
        }
'''
