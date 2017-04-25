//
//  Dyno.swift
//  Dyno
//
//  Created by Plutonist on 2017/4/20.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation
import DynoCore
import Hydra

class Dyno {
    static var sharedInstance = Dyno()
    
    private var _runtime: DynoRuntime?
    
    static func runtime() -> Promise<DynoRuntime> {
        return async {
            if Dyno.sharedInstance._runtime == nil {
                Dyno.sharedInstance._runtime = DynoRuntime()
                try await(Dyno.sharedInstance._runtime!.setup())
            }
            return Dyno.sharedInstance._runtime!
        }
    }
}
