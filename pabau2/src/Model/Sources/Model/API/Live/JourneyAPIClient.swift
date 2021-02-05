import ComposableArchitecture
//MARK: - JourneyAPI
extension APIClient {
	
	public func getEmployees(locationId: Location.ID) -> Effect<EmployeesList, RequestError> {
		let requestBuilder: RequestBuilder<EmployeesList>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getEmployees,
								   queryParams: commonAnd(other: [:]),
								   isBody: false)
			.effect()
			.eraseToEffect()
	}
	
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError> {
		fatalError()
	}
	
	public func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<CalendarResponse, RequestError> {
		let requestBuilder: RequestBuilder<CalendarResponse>.Type = requestBuilderFactory.getBuilder()
		let dateFormatter = DateFormatter.yearMonthDay
		let params = [
			"start_date": dateFormatter.string(from: startDate),
			"end_date": dateFormatter.string(from: endDate),
			"location_id": locationIds.map(String.init).joined(separator: ","),
			"user_ids": employeesIds.map(String.init).joined(separator: ","),
			"room_id": roomIds.map(String.init).joined(separator: ",")
		]
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getAppointments,
								   queryParams: commonAnd(other: params),
								   isBody: false)
			.effect()
			//			.validate()
			//			.mapError { LoginError.requestError($0) }
			.eraseToEffect()
	}
}
