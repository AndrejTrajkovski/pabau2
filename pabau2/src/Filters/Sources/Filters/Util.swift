import ComposableArchitecture

func groupDict<T, Key: Hashable>(elements: [T],
								 keyPath: KeyPath<T, [Key]>) -> [Key: IdentifiedArrayOf<T>] {
	
	let keys = Set(elements.flatMap { $0[keyPath: keyPath] })
	var result: [Key: IdentifiedArrayOf<T>] = [:]
	
	keys.forEach { key in
		elements.forEach { element in
			if element[keyPath: keyPath].contains(key) {
				if result[key] != nil {
					result[key]!.append(element)
				} else {
					result[key] = IdentifiedArray()
				}
			}
		}
	}
	return result
}
