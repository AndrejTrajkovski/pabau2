struct IntervalInfo {
	let test: String
	let type: IntervalType
	let intervalsCount: Int
	init(_ count: Int,
			 _ test: String,
			 _ type: IntervalType = .appointment("-1")
			 ) {
		intervalsCount = count
		self.type = type
		self.test = test
	}
}
