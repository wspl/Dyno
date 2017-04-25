//
// Created by Plutonist on 2017/4/18.
//

import Foundation
import Alamofire
import Hydra

typealias HTTPMethod = Alamofire.HTTPMethod

//extension String: ParameterEncoding {
//    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//        var request = try urlRequest.asURLRequest()
//        request.httpBody = data(using: .utf8, allowLossyConversion: false)
//        return request
//    }
//}

class PLRequest {
    private var method: HTTPMethod
    private var url: String
    private var headers = [String:String]()
    private var body = ""
    
    init(method: HTTPMethod, url: String) {
        self.url = url
        self.method = method
    }
    
    static func get(_ url: String) -> PLRequest {
        return PLRequest.init(method: .get, url: url)
    }
    
    static func post(_ url: String) -> PLRequest {
        return PLRequest.init(method: .post, url: url)
    }
    
    static func put(_ url: String) -> PLRequest {
        return PLRequest.init(method: .put, url: url)
    }
    
    static func delete(_ url: String) -> PLRequest {
        return PLRequest.init(method: .delete, url: url)
    }
    
    static func patch(_ url: String) -> PLRequest {
        return PLRequest.init(method: .patch, url: url)
    }
    
    func set(header key: String, value: String) -> PLRequest {
        headers[key] = value
        return self
    }
    
    func set(headers appendingHeaders: [String:String]) -> PLRequest {
        for (key, val) in appendingHeaders {
            headers[key] = val
        }
        return self
    }
    
    func body(_ body: String) -> PLRequest {
        self.body = body
        return self
    }
    
    func data(onCompleted: @escaping (_: DataResponse<Data>) -> ()) {
        Alamofire.request(self.url,
                          method: self.method,
                          parameters: [:],
                          encoding: self.body,
                          headers: self.headers
            ).responseData(
                queue: DispatchQueue.global(qos: .background),
                completionHandler: onCompleted
        )
    }
    
    func data() -> Promise<Data> {
        return Promise { resolve, reject in
            self.data { response in
                if response.error == nil {
                    resolve(response.data!)
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    func safeData() -> Promise<Data?> {
        return Promise { resolve, reject in
            self.data { response in
                if response.error == nil {
                    resolve(response.data)
                } else {
                    resolve(nil)
                }
            }
        }
    }
    
    func string() -> Promise<String> {
        return async {
            return String(data: try await(self.data()), encoding: .utf8) ?? ""
        }
    }
    
    func safeString() -> Promise<String?> {
        return async {
            return String(data: try await(self.data()), encoding: .utf8)
        }
    }
}
