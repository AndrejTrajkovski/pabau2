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
	
	public func getAppointments(dates: [Date], locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<CalendarResponse, RequestError> {
		let requestBuilder: RequestBuilder<CalendarResponse>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getAppointments,
								   queryParams: commonAnd(other: [:]),
								   isBody: false)
			.effect()
//			.validate()
//			.mapError { LoginError.requestError($0) }
			.eraseToEffect()
	}
}
