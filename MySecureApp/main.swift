//
//  main.swift
//  MySecureApp
//
//  Created by User on 2018/8/12.
//  Copyright © 2018年 User. All rights reserved.
//

import Foundation
import UIKit

_ = autoreleasepool {
    disableTrace()
    
    UIApplicationMain(
        CommandLine.argc,
        UnsafeMutableRawPointer(CommandLine.unsafeArgv)
            .bindMemory(
                to: UnsafeMutablePointer<Int8>.self,
                capacity: Int(CommandLine.argc)),
        nil,
        NSStringFromClass(AppDelegate.self) //Or your class name
    )
}
