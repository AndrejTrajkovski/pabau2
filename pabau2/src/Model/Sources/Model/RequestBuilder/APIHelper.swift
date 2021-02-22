import Foundation

public struct APIHelper {
	public static func rejectNil(_ source: [String: Any?]) -> [String: Any]? {
		let destination = source.reduce(into: [String: Any]()) { (result, item) in
			if let value = item.value {
				result[item.key] = value
			}
		}

		if destination.isEmpty {
			return nil
		}
		return destination
	}

	public static func rejectNilHeaders(_ source: [String: Any?]) -> [String: String] {
		return source.reduce(into: [String: String]()) { (result, item) in
			if let collection = item.value as? Array<Any?> {
				result[item.key] = collection.filter({ $0 != nil }).map { "\($0!)" }.joined(separator: ",")
			} else if let value: Any = item.value {
				result[item.key] = "\(value)"
			}
		}
	}

	public static func convertBoolToString(_ source: [String: Any]?) -> [String: Any]? {
		guard let source = source else {
			return nil
		}

		return source.reduce(into: [String: Any](), { (result, item) in
			switch item.value {
			case let x as Bool:
				result[item.key] = x.description
			default:
				result[item.key] = item.value
			}
		})
	}

	public static func mapValuesToQueryItems(_ source: [String: Any?]) -> [URLQueryItem]? {
		let destination = source.filter({ $0.value != nil}).reduce(into: [URLQueryItem]()) { (result, item) in
			if let collection = item.value as? Array<Any?> {
				let value = collection.filter({ $0 != nil }).map({"\($0!)"}).joined(separator: ",")
				result.append(URLQueryItem(name: item.key, value: value))
			} else if let value = item.value {
				result.append(URLQueryItem(name: item.key, value: "\(value)"))
			}
		}

		if destination.isEmpty {
			return nil
		}
		return destination
	}
	
	public enum ArrayEncoding {
		/// An empty set of square brackets is appended to the key for every value. This is the default behavior.
		case brackets
		/// No brackets are appended. The key is encoded as is.
		case noBrackets

		func encode(key: String) -> String {
			switch self {
			case .brackets:
				return "\(key)[]"
			case .noBrackets:
				return key
			}
		}
	}
	
	/// Configures how `Bool` parameters are encoded.
	public enum BoolEncoding {
		/// Encode `true` as `1` and `false` as `0`. This is the default behavior.
		case numeric
		/// Encode `true` and `false` as string literals.
		case literal

		func encode(value: Bool) -> String {
			switch self {
			case .numeric:
				return value ? "1" : "0"
			case .literal:
				return value ? "true" : "false"
			}
		}
	}
	
	public static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
		var components: [(String, String)] = []
		switch value {
		case let dictionary as [String: Any]:
			for (nestedKey, value) in dictionary {
				components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
			}
		case let array as [Any]:
			for value in array {
				components += queryComponents(fromKey: ArrayEncoding.brackets.encode(key: key), value: value)
			}
		case let number as NSNumber:
			if number.isBool {
				components.append((Self.escape(key), escape(BoolEncoding.numeric.encode(value: number.boolValue))))
			} else {
				components.append((Self.escape(key), Self.escape("\(number)")))
			}
		case let bool as Bool:
			components.append((Self.escape(key), Self.escape(BoolEncoding.numeric.encode(value: bool))))
		default:
			components.append((Self.escape(key), Self.escape("\(value)")))
		}
		return components
	}
	
	public static func escape(_ string: String) -> String {
		string.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? string
	}
}

// MARK: -

extension NSNumber {
	fileprivate var isBool: Bool {
		// Use Obj-C type encoding to check whether the underlying type is a `Bool`, as it's guaranteed as part of
		// swift-corelibs-foundation, per [this discussion on the Swift forums](https://forums.swift.org/t/alamofire-on-linux-possible-but-not-release-ready/34553/22).
		String(cString: objCType) == "c"
	}
}

extension CharacterSet {
	/// Creates a CharacterSet from RFC 3986 allowed characters.
	///
	/// RFC 3986 states that the following characters are "reserved" characters.
	///
	/// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
	/// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
	///
	/// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
	/// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
	/// should be percent-escaped in the query string.
	public static let afURLQueryAllowed: CharacterSet = {
		let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
		let subDelimitersToEncode = "!$&'()*+,;="
		let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

		return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
	}()
}
