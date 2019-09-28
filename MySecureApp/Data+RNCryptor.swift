//
//  Data+RNCryptor.swift
//  MySecureApp
//
//  Created by User on 2018/8/11.
//  Copyright © 2018年 User. All rights reserved.
//

import Foundation
import RNCryptor

extension Data {
    
    func decryptBase64(key: String) -> Data? { //解密
        //convert base64 encode data to original data
        //Data -> String -> Data
//        guard let string = String(data: self, encoding: .utf8) else {
//                print("Fail to convert data to String.")
//                return nil
//        }
//        guard let encryptedData = Data(base64Encoded: string) else {
//            print("Fail to convert base64 to data.")
//            return nil
//        }
        guard let encryptedData = Data(base64Encoded: self) else {
            print("Fail to convert base64 to data.")
            return nil
        }
        
        guard let decryptedData = try? RNCryptor.decrypt(data: encryptedData, withPassword: key) else {
            assertionFailure("Fail to decrypt.")
            return nil
        }
        
        print("decryptData: \(decryptedData)")
        return decryptedData
    }
    
    func decryptToString(key: String) -> String? {
        guard let decryptData = decryptBase64(key: key) else {
            return nil
        }
//        guard let string = String(data: decryptData, encoding: .utf8) else {
//            print("Fail to convert data to String.")
//            return nil
//        }
//        return string
        return String(data: decryptData, encoding: .utf8)
    }
    
    // Encrypt/Decrypt Data from file.
    func decrypt(key: String) -> Data? {
        guard let decryptedData = try? RNCryptor.decrypt(data: self, withPassword: key) else {
            assertionFailure("Fail to decrypt.")
            return nil
        }
        
        return decryptedData
    }
    
    func encrypt(key: String) -> Data {
        let encryptData = RNCryptor.encrypt(data: self, withPassword: key)
        
        return encryptData
    }

    func encrypt(to url: URL, key: String) throws {
        let encryptedData = encrypt(key: key)
        try encryptedData.write(to: url)
    }
    
    static func decrypt(from url: URL, key: String) -> Data? {
        guard let data = try? Data(contentsOf: url) else {
            print("Fail to load file: \(url).")
            return nil
        }
        
        return data.decrypt(key: key)
    }
    
}
