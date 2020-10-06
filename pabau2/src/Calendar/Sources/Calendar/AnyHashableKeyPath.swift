struct AnyHashableKeyPath<T> {
	let get: (T) -> AnyHashable
	let set: (inout T, AnyHashable) -> ()

	init<S: Hashable>(_ kpth: WritableKeyPath<T, S>) {
		set = {
			$0[keyPath: kpth] = $1.base as! S
		}
		
		get = {
			$0[keyPath: kpth]
		}
	}
}
