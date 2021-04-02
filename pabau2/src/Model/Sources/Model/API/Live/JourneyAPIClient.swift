import ComposableArchitecture
import Util

//MARK: - JourneyAPI
extension APIClient {
	
	public func getPathwayTemplates() -> Effect<IdentifiedArrayOf<PathwayTemplate>, RequestError> {
		struct GetPathways: Decodable {
			let pathways: [PathwayTemplate]
		}
		let companyId = loggedInUser?.companyID ?? ""
		let requestBuilder: RequestBuilder<GetPathways>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getPathwaysTemplates,
								   queryParams: commonAnd(other: ["company_id" : companyId])
		)
			.effect()
			.map { IdentifiedArrayOf.init($0.pathways) }
			.eraseToEffect()
	}
	
	public func getEmployees() -> Effect<[Employee], RequestError> {
		struct GetEmployees: Decodable {
			public let employees: [Employee]
			enum CodingKeys: String, CodingKey {
				case employees
			}
		}
		let requestBuilder: RequestBuilder<GetEmployees>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getEmployees,
            queryParams: commonAnd(other: [:]
            )
        )
        .effect()
        .map(\.employees)
        .eraseToEffect()
	}
	
	public func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<[CalendarEvent], RequestError> {
		let requestBuilder: RequestBuilder<CalendarResponse>.Type = requestBuilderFactory.getBuilder()
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
        var params: [String : Any] = [
			"start_date": dateFormatter.string(from: startDate),
			"end_date": dateFormatter.string(from: endDate),
        ]
        
        if !locationIds.isEmpty {
            params["location_id"] = locationIds.map(String.init).joined(separator: ",")
        }
        
        if !employeesIds.isEmpty {
            params["user_ids"] = employeesIds.map(String.init).joined(separator: ",")
        }
        
        if !roomIds.isEmpty {
            params["room_id"] = roomIds.map(String.init).joined(separator: ",")
        }
        
		return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getAppointments,
            queryParams: commonAnd(other: params)
        )
        .effect()
        .map(\.appointments)
	}
    
    public func getShifts() -> Effect<[CalendarEvent], RequestError> {
        let requestBuilder: RequestBuilder<CalendarResponse>.Type = requestBuilderFactory.getBuilder()
        let dateFormatter = DateFormatter.yearMonthDay
        
        var params: [String : Any] = [
            "date": dateFormatter.string(from: Date()),
            "all": true,
        ]
        
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getShifts,
            queryParams: commonAnd(other: params)
        )
        .effect()
        .map(\.appointments)
    }
	
	public func getLocations() -> Effect<[Location], RequestError> {
		struct GetLocations: Decodable {
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
	
	public func match(journey: Journey, pathwayTemplateId: PathwayTemplate.ID) -> Effect<[Appointment.ID: Pathway], RequestError> {
		
		let appointmentsIds = journey.appointments.map(\.id)
		
		let body = [
			"booking_ids": appointmentsIds.map(String.init).joined(separator: ","),
			"pathway_template_id": pathwayTemplateId.description,
			"contact_id": journey.clientId.description
		]
		
		struct Response: Decodable {
			let pathway_data: [Pathway]
		}
		
		let requestBuilder: RequestBuilder<Response>.Type = requestBuilderFactory.getBuilder()
		
		return requestBuilder.init(
			method: .POST,
			baseUrl: baseUrl,
			path: .pathwaysMatch,
			queryParams: commonParams(),
			body: bodyData(parameters: body)
		)
		.effect()
		.map { pathwayResponse in
			let pathways = pathwayResponse.pathway_data
			return zip(appointmentsIds, pathways).reduce(into: [Appointment.ID: Pathway]()) {
				$0[$1.0] = $1.1
			}
		}
		.eraseToEffect()
	}
}
