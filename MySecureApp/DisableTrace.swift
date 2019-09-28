//
//  DisableTrace.swift
//  MySecureApp
//
//  Created by User on 2018/8/12.
//  Copyright © 2018年 User. All rights reserved.
//

import Foundation

@inline(__always) func disableTrace() {
    #if !DEBUG
//    #if RELEASE
    let disableAttach: CInt = 31
    let handle = dlopen("/usr/lib/libc.dylib", RTLD_NOW)
    let sym = dlsym(handle, "ptrace")
    typealias PtraceType = @convention(c)(CInt, pid_t, CInt, CInt) -> CInt
    let ptrace = unsafeBitCast(sym, to: PtraceType.self)
    _ = ptrace(disableAttach, 0, 0, 0)
    dlclose(handle)
    #endif
}
