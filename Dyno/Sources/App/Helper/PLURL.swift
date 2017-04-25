//
//  PLURL.swift
//  Dyno
//
//  Created by Plutonist on 2017/4/23.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation
import Regex

struct PLURL: Hashable {
    var raw: String
    var urlString: String
    var url: URL
    
    var fun: String = ""
    var params: String = ""
    
    init(_ raw: String) {
        self.raw = raw
        
        if Regex("^(\\w+)\\((.+)\\)#(.*)$").matches(raw) {
            let result = Regex("^(\\w+)\\((.+)\\)#(.*)$").match(raw)!.captures
            fun = result[0]!
            params = result[1]!
            urlString = result[2]!
        } else {
            urlString = raw
        }
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        url = URL(string: urlString)!
    }
    
    func produce(fun: String, params: String) -> PLURL {
        return PLURL("\(fun)(\(params))#\(self.urlString)")
    }
    
    var hashValue: Int {
        return raw.hashValue ^ 2333
    }
    
    static func ==(lhs: PLURL, rhs: PLURL) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
