// Models.swift

import Foundation

extension Formatter {
	static let iso8601: DateFormatter = {
		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
		return formatter
	}()
}

func newJSONDecoder() -> JSONDecoder {
	let decoder = JSONDecoder()
	if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
		decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
	}
	return decoder
}

func newJSONEncoder() -> JSONEncoder {
	let encoder = JSONEncoder()
	encoder.outputFormatting = [.prettyPrinted]
	if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
		encoder.dateEncodingStrategy = .formatted(Formatter.iso8601)
	}
	return encoder
}

public enum ErrorResponse : Error {
	case error(Int, Data?, Error)
}

open class Response<T> {
	public let statusCode: Int
	public let header: [String: String]
	public let body: T?
	
	public init(statusCode: Int, header: [String: String], body: T?) {
		self.statusCode = statusCode
		self.header = header
		self.body = body
	}
	
	public convenience init(response: HTTPURLResponse, body: T?) {
		let rawHeader = response.allHeaderFields
		var header = [String:String]()
		for case let (key, value) as (String, String) in rawHeader {
			header[key] = value
		}
		self.init(statusCode: response.statusCode, header: header, body: body)
	}
}
