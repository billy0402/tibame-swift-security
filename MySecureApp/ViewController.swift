//
//  ViewController.swift
//  MySecureApp
//
//  Created by User on 2018/8/11.
//  Copyright © 2018年 User. All rights reserved.
//

import UIKit
import TrustKit
import KeychainAccess
import LocalAuthentication

class ViewController: UIViewController, URLSessionDelegate {
    
    @IBOutlet weak var resultImageVIew: UIImageView!
    @IBOutlet weak var inputTextfield: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
//    let primaryKey = "123456"
    var primaryKey: String {
        return "12" + String(30 + 4) + String(7 * 8)
    }
    
//    let primaryKey: String = {
//        return "12" + String(30 + 4) + String(7 * 8)
//    }()
    
    @IBAction func apiTestButtonProssed(_ sender: Any) {
//        let uslString = "http://class.softarts.cc/AppSecurity/encryptData.json"
//        let packageKey = "zaq1xsw2cde3vfr4"
//        let passwordKeyPrefix = "1qaz2wsx"
        
        let uslString = "AwHmBGtJc0EBgOp172RuWI6m1+J7sNTE9p7DTEL+Ity4I01EhewCmM5pFkzREv+KYoiWJtuHEq+DiTyvJkogn6Ixa3yIsDLX8ScHYpHpZ2uzQRGNYGAeniEHPnCBbstVBP7kIY4/6K9KLGBI7gJy5/pKRPOffkizSnoJrKuGjuCIPw==".decryptBase64(key: primaryKey)!
        let packageKey = "AwG0hvDgtU0YK5Xd1yRwjK+HHP24HfqZxqOT+s3wWkR0S4IeQK7ZByfc9qZJ1j9QizbB5u5i9Uc5Vn1Ekkg0mj8QtBkbCOCOw0fQqYohGzaTDKlzbQ1CleKR/z8pKAeTsl4=".decryptBase64(key: primaryKey)!
        let passwordKeyPrefix = "AwEuQwHVOtdymcDUwlhUZ4q7tIZtPFByxejbrTmpZD0QIVRWiqFfvKPJlrCnJK70ewenmWRqaeo5qnYOQjubGT1E8wrXZQ2eqKqM6mVaWjCmgg==".decryptBase64(key: primaryKey)!
        
//        print("uslString ==> \(uslString.encryptToBase64(key: primaryKey)!)")
//        print("packageKey ==> \(packageKey.encryptToBase64(key: primaryKey)!)")
//        print("passwordKeyPrefix ==> \(passwordKeyPrefix.encryptToBase64(key: primaryKey)!)")
        
        guard let url = URL(string: uslString) else {
            assertionFailure("Invalid URLString")
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Download Fail: \(error)")
            }
            guard let data = data else {
                assertionFailure("Data is nil.")
                return
            }
            guard let encryptedContent = String(data: data, encoding: .utf8) else {
                assertionFailure("Fail to convert data to String.")
                return
            }
            print("encryptedContent: \(encryptedContent)")
            
            // Decrypt data
            guard let decryptedString = data.decryptToString(key: packageKey) else {
                return
            }
            print("decryptedString: \(decryptedString)")
            
            let decorder = JSONDecoder()
            guard let decryptedData = data.decryptBase64(key: packageKey),
                let package = try? decorder.decode(SampleModel.self, from: decryptedData) else {
                    assertionFailure("Fail to decode as package struct.")
                    return
            }            
            print("package: \(package)")
            
            let finalPasswordKey = passwordKeyPrefix + package.timestamp
            guard let finalPassword = package.pw.decryptBase64(key: finalPasswordKey) else {
                assertionFailure("Fail to decrypt pw.")
                return
            }
            print("finalPassword: \(finalPassword)")
        }
        task.resume()
    }
    
    @IBAction func sslPinningTestButtonProssed(_ sender: Any) {
        guard let url = URL(string: "https://www.google.com.tw") else {
            assertionFailure("Invalid URL.")
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed: \(error)")
                return
            }
            guard let data = data else {
                print("Data is nil.")
                return
            }
            print("Success, recieve \(data.count) bytes.")
        }
        dataTask.resume()
    }
    
    @IBAction func saveToKeychainButtonProssed(_ sender: Any) {
        let accessToken = "1qaz2wsx"
        let encryptedToken = accessToken.encryptToBase64(key: primaryKey)
        
        let keychain = Keychain(service: "accessServer")
        keychain["encryptedToken"] = encryptedToken
        keychain[data: "secrectData"] = Data([1, 2, 3])
    }
    
    @IBAction func loadFromKeychainButtonProssed(_ sender: Any) {
        let keychain = Keychain(service: "accessServer")
        guard let encryptedToken = keychain["encryptedToken"],
        let token = encryptedToken.decryptBase64(key: primaryKey) else {
            print("Failed to get encryptedToken from keychain.")
            return
        }
        print("EncryptedToken is \(encryptedToken).")
        print("AccessToken is \(token).")
        
        guard let data = keychain[data: "secrectData"] else {
            print("Failed to get data from keychain.")
            return
        }
        print("SecrectData is \(data).")
    }

    @IBAction func removeFromKeychainButtonProssed(_ sender: Any) {
        let keychain = Keychain(service: "accessServer")
        
        // Clear value only.
//        keychain["encryptedToken"] = nil
//        keychain[data: "secrectData"] = nil
        
        // Remove the whole key-value entry.
        do {
            try keychain.remove("encryptedToken")
            try keychain.remove("secrectData")
        } catch let error {
            print("error: \(error)")
        }
    }
    
    @IBAction func encryptFileBUttonProssed(_ sender: Any) {
        // Get URL of image file from bundle.
        guard let sourceURL = Bundle.main.url(forResource: "Windows_LockScreen.JPG", withExtension: nil) else {
            assertionFailure("Failed to get image file.")
            return
        }
        guard  let imageData = try? Data(contentsOf: sourceURL) else {
            assertionFailure("Failed to get imageData from file.")
            return
        }
        
        // Encrypt the file content.
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("Output.x")
        try? imageData.encrypt(to: outputURL, key: primaryKey)
        print("Output.x: \(outputURL)")
        
        // Save as a output file.
    }
    
    @IBAction func decryptFileBUttonProssed(_ sender: Any) {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("Output.x")
        NSLog("Start!")
        guard let data = Data.decrypt(from: outputURL, key: primaryKey) else {
            assertionFailure("Failed to decrypt file.")
            return
        }
        NSLog("Finish!")
        
        resultImageVIew.image = UIImage(data: data)
    }
    
    // select * from users where login = '$ username' and password = '$ password'
    // $ username = ' or 1 = 1 /*
    // select * from users where login = '' or 1 = 1 /*' and password = '$ password'
    
    @IBAction func submitButtonProssed(_ sender: Any) {
        //a~z, A~Z, 0~9, Length: 6~12
        guard let input = inputTextfield.text, !input.isEmpty else {
            // show alert to users
            return
        }
        let regex = "^[a-zA-Z0-9]{6,12}$"
        let result = input.range(of: regex, options: .regularExpression)
        let message = (result == nil ? "Invalid":"OK")
        print("[\(input) ==> \(message)]")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // SSL Labs: https://www.ssllabs.com/index.html
        let trustKitConfig: [String: Any] = [
//            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "google.com": [
//                    kTSKExpirationDate: "2017-12-01",
                    kTSKEnforcePinning: true,
                    kTSKIncludeSubdomains: true,
                    kTSKPublicKeyAlgorithms:[kTSKAlgorithmRsa2048],
                    kTSKPublicKeyHashes: [ //Subject Pin SHA256
//                        "6eIe4hLWdLB6xKi1taheaZdVs4nfzsfQ5Ui1wUe3G9w=",
//                        "f8NnEFZxQ4ExFOhSN7EiFWtiudZQVD2oY60uauV/n78="
                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                        "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
                    ],
                ],
//                "yahoo.com": [...]
            ]
         ] as [String : Any]
        
        // Can execute only once!
        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
        
        // Demo for Data Protection
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            assertionFailure("Failed to get Documents URL.")
            return
        }
        
        // Create a file to be protected.
        let content = ["username": "Banana"]
        let fileURL = documentsURL.appendingPathComponent("Protected.plist")
        (content as NSDictionary).write(to: fileURL, atomically: true)
        
        // Create a file that will not be protected.
        let fileURL2 = documentsURL.appendingPathComponent("Unprotected.plist")
        (content as NSDictionary).write(to: fileURL2, atomically: true)
        
        // Set the file as no protection.
        let attributes = [FileAttributeKey.protectionKey: FileProtectionType.none]
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: fileURL2.path)
        } catch {
            print("Set attributes failed: \(error)")
        }
        
        // LocalAuthentication Demo
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            print("Yes, user already setup the passcode.")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "...") { (success, error) in
                print("success: \(success)")
                print("error: \(error)")
            }
        } else {
            print("No, user don't setup the passcode.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let validator = TrustKit.sharedInstance().pinningValidator
        if validator.handle(challenge, completionHandler: completionHandler) == false {
            completionHandler(.performDefaultHandling, nil)
        }
    }

}
