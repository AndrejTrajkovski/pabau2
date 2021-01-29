import ComposableArchitecture
//MARK: - JourneyAPI
extension APIClient {
	
	public func getEmployees(companyId: Company.ID) -> Effect<[Employee], RequestError> {
		fatalError()
	}
	
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError> {
		fatalError()
	}
	
	public func getAppointments(dates: [Date], locationIds: [Location.ID], employeesIds: [Employee.ID]) -> Effect<[CalendarEvent], RequestError> {
		let requestBuilder: RequestBuilder<[CalendarEvent]>.Type = requestBuilderFactory.getBuilder()
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
