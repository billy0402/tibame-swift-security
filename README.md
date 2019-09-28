# tibame-swift-security

## environment
- [macOS 10.14.6](https://www.apple.com/tw/macos/mojave/)
- [Xcode 10.2.1](https://developer.apple.com/cn/support/xcode/)
- [Swift 4.2](https://swift.org)
- emulator iPhone XR(iOS 12.2)

### 網路安全練習主機與電文資訊
- [主機URL](http://class.softarts.cc/AppSecurity/encryptData.json)
```
Package 加密 Key: "zaq1xsw2cde3vfr4"
Password 加密 Key Prefix: "1qaz2wsx"
```

### Exception Domains 設定 Key 值
```
NSExceptionAllowsInsecureHTTPLoads
NSIncludesSubdomains
```

### [UDID登記表](https://docs.google.com/spreadsheets/d/1lWJeJszvQkPqZ3tLY9-ZEjtqrANw1lCOOZnjU5mfhlc/edit?usp=sharing|UDID登記表)

### Data+RNCrypt.swift (0811 1450)
```swift
//
//  Data+RNCryptor.swift
//  HelloMySecureApp
//
//  Created by Kent Liu on 2018/8/11.
//  Copyright © 2018年 SoftArts Inc. All rights reserved.
//

import Foundation
import RNCryptor

extension Data {

    func decrypt(key: String) -> Data? {

        // Convert base64 encoded data to original data
        guard let encryptedData = Data(base64Encoded: self) else {
            print("Fail to convert base64 to data.")
            return nil
        }

        guard let decryptedData = try? RNCryptor.decrypt(data: encryptedData, withPassword: key) else {
            assertionFailure("Fail to decrypt.")
            return nil
        }
        return decryptedData
    }

    func decryptToString(key: String) -> String? {
        guard let data = decrypt(key: key) else {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            print("Fail to convert data to string.")
            return nil
        }
        return string
    }

}
```

### DataProtection練習憑證
[僅支援有登記UDID的裝置](https://www.dropbox.com/s/q2lovjevtarpf3k/DataProtectionDemo%E6%86%91%E8%AD%89.zip?dl=0|憑證下載)
```
Bundle ID: com.kent.dataprotectiondemo
P12密碼: 1qaz2wsx
```

### 假 Pinning Hash
```
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
```

### main.swift 預設內容
```swift
import Foundation
import UIKit

autoreleasepool {

    UIApplicationMain(
        CommandLine.argc,
        UnsafeMutableRawPointer(CommandLine.unsafeArgv)
            .bindMemory(
                to: UnsafeMutablePointer<Int8>.self,
                capacity: Int(CommandLine.argc)
            ),
        nil,
        NSStringFromClass(AppDelegate.self) //Or your class name
    )

}
```

### Objective-C 混淆方式參考
- [Codeobscure](https://github.com/kaich/codeobscure)
- [ZMConfuse](https://github.com/kongcup/ZMConfuse)