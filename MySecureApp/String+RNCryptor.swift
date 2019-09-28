//
//  String+RNCryptor.swift
//  MySecureApp
//
//  Created by User on 2018/8/11.
//  Copyright © 2018年 User. All rights reserved.
//

import Foundation
import RNCryptor

extension String {
    
    func decryptBase64(key: String) -> String? {
        guard let encryptedData = Data(base64Encoded: self) else {
            print("Fail to convert base64 to data.")
            return nil
        }
        
        guard let decryptedData = try? RNCryptor.decrypt(data: encryptedData, withPassword: key),
            let string = String(data: decryptedData, encoding: .utf8) else {
            assertionFailure("Fail to decrypt.")
            return nil
        }
        return string
    }
    
    func encryptToBase64(key: String) -> String? {
        guard let data = self.data(using: .utf8) else {
            assertionFailure("Fail to encrypt from String.")
            return nil
        }
        let encryptedData = RNCryptor.encrypt(data: data, withPassword: key)
        return encryptedData.base64EncodedString()
    }
    
}
