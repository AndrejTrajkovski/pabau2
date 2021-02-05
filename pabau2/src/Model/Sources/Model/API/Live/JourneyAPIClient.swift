import ComposableArchitecture
//MARK: - JourneyAPI
extension APIClient {
	
	public func getEmployees() -> Effect<[Employee], RequestError> {
		struct GetEmployees: Codable {
			public let employees: [Employee]
			enum CodingKeys: String, CodingKey {
				case employees
			}
		}
		let requestBuilder: RequestBuilder<GetEmployees>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getEmployees,
								   queryParams: commonAnd(other: [:]),
								   isBody: false)
			.effect()
			.map(\.employees)
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
	}
	
	public func getLocations() -> Effect<[Location], RequestError> {
		struct GetLocations: Codable {
			let locations: [Location]
			enum CodingKeys: String, CodingKey {
				case locations = "employees"
			}
		}
		let requestBuilder: RequestBuilder<GetLocations>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getLocations,
								   queryParams: commonParams(),
								   isBody: false)
			.effect()
			.map(\.locations)
			.eraseToEffect()
	}
}
