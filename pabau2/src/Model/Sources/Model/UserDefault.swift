import Foundation

@propertyWrapper
public struct UserDefault<T: Codable> {
	let key: String
	let defaultValue: T?
	let userDefaults: UserDefaults

	init(_ key: String, defaultValue: T?, userDefaults: UserDefaults = .standard) {
		self.key = key
		self.defaultValue = defaultValue
		self.userDefaults = userDefaults
	}

	public var wrappedValue: T? {
		get {
			if let savedValue = userDefaults.object(forKey: key) as? Data {
				let decoder = JSONDecoder()
				if let loadedValue = try? decoder.decode(T.self, from: savedValue) {
					return loadedValue
				}
			}
			return defaultValue
		}
		set {
			let encoder = JSONEncoder()
			if let encoded = try? encoder.encode(newValue) {
				userDefaults.set(encoded, forKey: key)
			}
		}
	}
}
