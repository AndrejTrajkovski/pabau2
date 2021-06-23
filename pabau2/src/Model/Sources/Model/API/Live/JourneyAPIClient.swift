import ComposableArchitecture
import Util

//MARK: - JourneyAPI
extension APIClient {
    
    public func getCalendar(
        startDate: Date,
        endDate: Date,
        locationIds: Set<Location.ID>,
        employeesIds: [Employee.ID]?,
        roomIds: [Room.ID]?
    ) -> Effect<AppointmentsResponse, RequestError> {
        let requestBuilder: RequestBuilder<AppointmentsResponse>.Type = requestBuilderFactory.getBuilder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
//		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
		print(startDate.timeIntervalSince1970)
        var params: [String : Any] = [
            "start_date": dateFormatter.string(from: startDate),
            "end_date": dateFormatter.string(from: endDate),
        ]
        
		print(params)
        if !locationIds.isEmpty {
            params["location_id"] = locationIds.map(String.init).joined(separator: ",")
        }
        
        if let employeesIds = employeesIds {
            params["user_ids"] = employeesIds.map(String.init).joined(separator: ",")
        }
        
        if let roomIds = roomIds {
            params["room_id"] = roomIds.map(String.init).joined(separator: ",")
        }
        
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getAppointments,
            queryParams: commonAnd(other: params)
        )
        .effect()
    }
	
	public func getPathwayTemplate(id: PathwayTemplate.ID) -> Effect<PathwayTemplate, RequestError> {
		
		struct GetPathways: Decodable {
			let pathways: [PathwayTemplate]
		}
		
		let companyId = loggedInUser?.companyID ?? ""
		let requestBuilder: RequestBuilder<GetPathways>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getPathwaysTemplates,
								   queryParams: commonAnd(other: ["company_id" : companyId,
																  "id" : id.description])
		)
		.effect()
		.tryMap {
			if let first = $0.pathways.first {
				return first
			} else {
				throw RequestError.emptyDataResponse
			}
		}
		.mapError { $0 as? RequestError ?? .unknown($0) }
		.eraseToEffect()
	}
	
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
	
	public func getLocations() -> Effect<[Location], RequestError> {
        struct GetLocations: Decodable {
            let locations: [Location]
            enum CodingKeys: String, CodingKey {
                case locations = "employees"
            }
        }
        let requestBuilder: RequestBuilder<GetLocations>.Type = requestBuilderFactory.getBuilder()
        let result = requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getLocations,
            queryParams: commonParams()
        )
        .effect()
        .map(\.locations)
        .eraseToEffect()
        
        return result
	}
	
	public func createShift(shiftSheme: ShiftSchema) -> Effect<Shift, RequestError> {
		let requestBuilder: RequestBuilder<VoidAPIResponse>.Type = requestBuilderFactory.getBuilder()
		let shiftShemeData = try? JSONEncoder().encode(shiftSheme)
		let params = shiftShemeData?.dictionary() ?? [:]
		
		return requestBuilder.init(
			method: .POST,
			baseUrl: baseUrl,
			path: .createShift,
			queryParams: commonAnd(other: params)
		)
		.effect()
        .map { response in
            // FIXME: Returned shift from endpoint response when will be added
            Shift.mock()
        }
        .eraseToEffect()
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
			"location_id":participantSchema.locationId,
			"owner_uid": participantSchema.employeeId,
			"service_id": participantSchema.serviceId
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
	
	public func match(appointment: Appointment, pathwayTemplateId: PathwayTemplate.ID) -> Effect<Pathway, RequestError> {
		
		let body = [
			"booking_id": appointment.id.description,
			"pathway_template_id": pathwayTemplateId.description,
			"contact_id": appointment.customerId.description
		]
		
		struct Response: Decodable {
			let pathway_data: Pathway
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
		.map(\.pathway_data)
//		.tryMap { pathwayResponse in
//			guard let pathway = pathwayResponse.pathway_data.first else {
//				throw RequestError.emptyDataResponse
//			}
//			return pathway
//		}
//		.mapError { $0 as? RequestError ?? .unknown($0) }
		.eraseToEffect()
	}
	
	public func getPathway(id: Pathway.ID) -> Effect<Pathway, RequestError> {
		
		struct Response: Decodable {
			let pathway_data: Pathway
		}
		
		let requestBuilder: RequestBuilder<Response>.Type = requestBuilderFactory.getBuilder()
		
		return requestBuilder.init(
			method: .GET,
			baseUrl: baseUrl,
			path: .getPathway,
			queryParams: commonAnd(other: ["id": String(id.description)])
		)
		.effect()
		.map(\.pathway_data)
		.eraseToEffect()
	}
	
	public func getRooms() -> Effect<[Room], RequestError> {
		struct GetRooms: Decodable {
			public let employees: [Room]
			enum CodingKeys: String, CodingKey {
				case employees
			}
		}
		let requestBuilder: RequestBuilder<GetRooms>.Type = requestBuilderFactory.getBuilder()
		
		return requestBuilder.init(
			method: .GET,
			baseUrl: baseUrl,
			path: .getRooms,
			queryParams: commonAnd(other: [:]
			)
		)
		.effect()
		.map(\.employees)
		.eraseToEffect()
	}
}
