struct FailableCodableDictionary<Key: Decodable & Hashable, Value : Decodable> : Decodable {

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
