import ComposableArchitecture
import Util

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
								   queryParams: commonAnd(other: [:])
		)
			.effect()
			.map(\.employees)
			.eraseToEffect()
	}
	
	public func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<[CalendarEvent], RequestError> {
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
								   queryParams: commonAnd(other: params)
		)
			.effect()
			.map(\.appointments)
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
								   queryParams: commonParams()
		)
			.effect()
			.map(\.locations)
			.eraseToEffect()
	}
	
	public func createShift(shiftSheme: ShiftSchema) -> Effect<PlaceholdeResponse, RequestError> {
		let requestBuilder: RequestBuilder<PlaceholdeResponse>.Type = requestBuilderFactory.getBuilder()
		
	  
		let shiftShemeData = try? JSONEncoder().encode(shiftSheme)
		let params = shiftShemeData?.dictionary() ?? [:]
		
		return requestBuilder.init(
			method: .POST,
			baseUrl: baseUrl,
			path: .createShift,
			queryParams: commonAnd(other: params)
		)
		.effect()
	}
	
//	public func getBookoutReasons() -> Effect<[BookoutReason], RequestError> {
//		let requestBuilder: RequestBuilder<[BookoutReason]>.Type = requestBuilderFactory.getBuilder()
//		return requestBuilder.init(method: .GET,
//								   baseUrl: baseUrl,
//								   path: .getBookoutReasons,
//								   queryParams: commonParams()
//		)
//			.effect()
//	}
	
	public func getParticipants(participantSchema: ParticipantSchema) -> Effect<[Participant], RequestError> {
		struct ParticipantsResponse: Codable {
			public var participant: [Participant]
			enum CodingKeys: String, CodingKey {
				case participant = "users"
			}
		}
		
		let params = [
			"all_day": participantSchema.isAllDays,
			"location_id":participantSchema.location.id,
			"owner_uid": participantSchema.employee.id,
			"service_id": participantSchema.service.id
		] as [String : Any]
		
		let requestBuilder: RequestBuilder<ParticipantsResponse>.Type = requestBuilderFactory.getBuilder()
		
		return requestBuilder.init(
			method: .GET,
			baseUrl: baseUrl,
			path: .getUsers,
			queryParams: commonAnd(other: params)
		)
		.effect()
		.map(\.participant)
		.eraseToEffect()
	}
}
