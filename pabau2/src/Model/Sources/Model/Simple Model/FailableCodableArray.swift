struct FailableCodableArray<Element : Codable> : Codable {

	let elements: [Element]

	init(from decoder: Decoder) throws {

		var container = try decoder.unkeyedContainer()

		var elements = [Element]()
		if let count = container.count {
			elements.reserveCapacity(count)
		}

		while !container.isAtEnd {
			if let element = try container
				.decode(FailableDecodable<Element>.self).base {

				elements.append(element)
			}
		}

		self.elements = elements
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(elements)
	}
}

struct FailableCodableDictionary<Value : Decodable, Key: Decodable & Hashable> : Decodable {

	private struct AnyDecodableValue: Decodable {}
	
	struct DictionaryCodingKey: CodingKey {
		let stringValue: String
		let intValue: Int?
		
		init?(stringValue: String) {
			self.stringValue = stringValue
			self.intValue = Int(stringValue)
		}
		
		init?(intValue: Int) {
			self.stringValue = "\(intValue)"
			self.intValue = intValue
		}
	}
	
	let dictionary: [Key: Value]

	init(from decoder: Decoder) throws {
		var elements: [Key: Value] = [:]
		if Key.self == String.self {
			let container = try decoder.container(keyedBy: DictionaryCodingKey.self)
			
			for key in container.allKeys {
				do {
					if let value = try container.decode(FailableDecodable<Value>.self, forKey: key).base {
						elements[key.stringValue as! Key] = value
						
					}
				} catch {
					_ = try? container.decode(AnyDecodableValue.self, forKey: key)
				}
			}
		} else if Key.self == Int.self {
			let container = try decoder.container(keyedBy: DictionaryCodingKey.self)
			
			for key in container.allKeys {
				guard key.intValue != nil else {
					var codingPath = decoder.codingPath
					codingPath.append(key)
					throw DecodingError.typeMismatch(
						Int.self,
						DecodingError.Context(
							codingPath: codingPath,
							debugDescription: "Expected Int key but found String key instead."))
				}
				
				do {
					if let value = try container.decode(FailableDecodable<Value>.self, forKey: key).base {
						elements[key.intValue! as! Key] = value
					}
				} catch {
					_ = try? container.decode(AnyDecodableValue.self, forKey: key)
				}
			}
		} else {
			throw DecodingError.dataCorrupted(
				DecodingError.Context(
					codingPath: decoder.codingPath,
					debugDescription: "Unable to decode key type."))
		}
		self.dictionary = elements
	}
}




////from https://github.com/marksands/BetterCodable/blob/master/Sources/BetterCodable/LossyDictionary.swift
//
//@propertyWrapper
//public struct LossyDictionary<Key: Decodable & Hashable, Value: Decodable>: Decodable {

//
//	private struct AnyDecodableValue: Decodable {}
//	private struct LossyDecodableValue<Value: Decodable>: Decodable {
//		let value: Value
//
//		public init(from decoder: Decoder) throws {
//			let container = try decoder.singleValueContainer()
//			value = try container.decode(Value.self)
//		}
//	}
//
//	public var wrappedValue: [Key: Value]
//
//	public init(wrappedValue: [Key: Value]) {
//		self.wrappedValue = wrappedValue
//	}
//
//	public init(from decoder: Decoder) throws {
//		var elements: [Key: Value] = [:]
//		if Key.self == String.self {
//			let container = try decoder.container(keyedBy: DictionaryCodingKey.self)
//
//			for key in container.allKeys {
//				do {
//					let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
//					elements[key.stringValue as! Key] = value
//				} catch {
//					_ = try? container.decode(AnyDecodableValue.self, forKey: key)
//				}
//			}
//		} else if Key.self == Int.self {
//			let container = try decoder.container(keyedBy: DictionaryCodingKey.self)
//
//			for key in container.allKeys {
//				guard key.intValue != nil else {
//					var codingPath = decoder.codingPath
//					codingPath.append(key)
//					throw DecodingError.typeMismatch(
//						Int.self,
//						DecodingError.Context(
//							codingPath: codingPath,
//							debugDescription: "Expected Int key but found String key instead."))
//				}
//
//				do {
//					let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
//					elements[key.intValue! as! Key] = value
//				} catch {
//					_ = try? container.decode(AnyDecodableValue.self, forKey: key)
//				}
//			}
//		} else {
//			throw DecodingError.dataCorrupted(
//				DecodingError.Context(
//					codingPath: decoder.codingPath,
//					debugDescription: "Unable to decode key type."))
//		}
//
//		self.wrappedValue = elements
//	}
//}
//
//extension LossyDictionary: Equatable where Key: Equatable, Value: Equatable { }
