import Foundation
import Combine

public protocol BaseAPI {
	var basePath: String { get }
//	var credential: URLCredential? { get set }
//	var customHeaders: [String:String] { get set }
	var requestBuilderFactory: RequestBuilderFactory { get set }
}

struct LiveAPI: BaseAPI {
	var basePath: String = "crm.pabau.com"
	var requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}

//public struct SwaggerClientAPI: BaseAPI {
//	public let basePath = "https://virtserver.swaggerhub.com/Pa577/iOS/1.0.0"
//	public var requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
//}

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
    }
    
    open func publisher() -> AnyPublisher<T, RequestError> {
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
}

public protocol RequestBuilderFactory {
    func getBuilder<T:Decodable>() -> RequestBuilder<T>.Type
}
