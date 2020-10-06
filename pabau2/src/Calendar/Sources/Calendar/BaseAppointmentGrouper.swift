class BaseAppointmentGrouper {
	public typealias SectionSort = ((key: AnyHashable, value: [AppointmentEvent]),
									(key: AnyHashable, value: [AppointmentEvent])) -> Bool
	var events: [[AppointmentEvent]] = []
	public var groupingProperty: AnyHashableKeyPath<AppointmentEvent>
	var sorting: SectionSort?
	public init(groupingProperty: AnyHashableKeyPath<AppointmentEvent>) {
		self.groupingProperty = groupingProperty
	}

	func update(events: [AppointmentEvent]) {
		self.events = groupAndSortSections(
			grouping: groupingProperty,
			sorting: sorting)(events)
	}

	func groupAndSortSections(
		grouping: AnyHashableKeyPath<AppointmentEvent>,
		sorting: SectionSort?
	)
	-> ([AppointmentEvent]) -> [[AppointmentEvent]] {
		return { events in
			let grouped = Dictionary.init(grouping: events,
										  by: {
											return grouping.get($0) })
			let sorted: [Dictionary<AnyHashable, [AppointmentEvent]>.Element] = {
				if sorting != nil {
					return grouped.sorted(by: sorting!)
				} else {
					return grouped.sorted(by: {
						$0.value.count < $1.value.count
					})
				}
			}()
			return sorted.map(\.value)
		}
	}
	
	func update(event: inout AppointmentEvent, indexes: (page: Int, withinPage: Int)) {
		let value = getValueOfEventAt(indexes: indexes)
		groupingProperty.set(&event, value)
	}
	
	func getValueOfEventAt(indexes: (page: Int, withinPage: Int)) -> AnyHashable {
		let event = events[indexes.page][indexes.withinPage]
		return groupingProperty.get(event)
	}
}
