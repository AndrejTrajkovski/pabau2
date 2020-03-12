// APIs.swift


import Foundation
import Combine

open class SwaggerClientAPI {
    public static var basePath = "https://virtserver.swaggerhub.com/Pa577/iOS/1.0.0"
    public static var credential: URLCredential?
    public static var customHeaders: [String:String] = [:]
    public static var requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}

open class RequestBuilder<T> {
    var credential: URLCredential?
    var headers: [String:String]
    public let parameters: [String:Any]?
    public let isBody: Bool
    public let method: String
    public let URLString: String

    required public init(method: String, URLString: String, parameters: [String:Any]?, isBody: Bool, headers: [String:String] = [:]) {
        self.method = method
        self.URLString = URLString
        self.parameters = parameters
        self.isBody = isBody
        self.headers = headers

        addHeaders(SwaggerClientAPI.customHeaders)
    }
    
    open func publisher() -> AnyPublisher<T, RequestBuilderError> {
        fatalError()
    }
    
    open func addHeaders(_ aHeaders:[String:String]) {
        for (header, value) in aHeaders {
            headers[header] = value
        }
    }

    open func execute(_ completion: @escaping (_ response: Response<T>?, _ error: Error?) -> Void) { }

    public func addHeader(name: String, value: String) -> Self {
        if !value.isEmpty {
            headers[name] = value
        }
        return self
    }

    open func addCredential() -> Self {
        self.credential = SwaggerClientAPI.credential
        return self
    }
}

public protocol RequestBuilderFactory {
    func getBuilder<T:Decodable>() -> RequestBuilder<T>.Type
}
