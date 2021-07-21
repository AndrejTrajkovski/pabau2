import ComposableArchitecture
import Combine
//MARK: - APIClient: ClientApi
extension APIClient {

    public func getClients(search: String?, offset: Int) -> Effect<[Client], RequestError> {
        let requestBuilder: RequestBuilder<ClientResponse>.Type = requestBuilderFactory.getBuilder()
        struct ClientResponse: Decodable, Equatable {
            public let clients: [Client]
            public enum CodingKeys: String, CodingKey {
                case clients = "appointments"
            }
        }

        var queryItems: [String: Any] = ["limit": 20, "offset": offset]

        if let search = search {
            queryItems["name"] = search
            queryItems["like_email"] = search
        }

        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getClients,
            queryParams: commonAnd(other: queryItems)
        )
        .effect()
        .map(\.clients)
        .eraseToEffect()
    }
	
	public func getItemsCount(clientId: Client.Id) -> Effect<ClientItemsCount, RequestError> {
		Effect(value: ClientItemsCount.init(id: 1, appointments: 2, photos: 4, financials: 6, treatmentNotes: 3, presriptions: 10, documents: 15, communications: 123, consents: 4381, alerts: 123, notes: 0))
			.eraseToEffect()
	}
	
	public func getFinancials(clientId: Client.Id) -> Effect<[Financial], RequestError> {
		struct FinancialResponse: Codable {
			let sales: [Financial]
		}
		let requestBuilder: RequestBuilder<FinancialResponse>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getFinancials,
								   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]))
			.effect()
			.map(\.sales)
			.eraseToEffect()
	}
		
	public func getAlerts(clientId: Client.Id) -> Effect<[Alert], RequestError> {
		struct AlertResponse: Codable {
			public let medical_alerts: [Alert]
		}
		let requestBuilder: RequestBuilder<AlertResponse>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getClientAlerts,
								   queryParams: commonAnd(other: [
									"contact_id": "\(clientId)",
									"mode": "get"
								   ]))
			.effect()
			.map(\.medical_alerts)
			.eraseToEffect()
	}
	
	public func update(clientBuilder: ClientBuilder, pathwayStep: PathwayIdStepId?) -> Effect<Client.ID, RequestError> {
		struct ClientResponse: Decodable {
			let contact_id: Client.ID
		}
		
		var queryParams = commonAnd(other: ["contact_id": clientBuilder.id?.description ?? "0"])
		merge(&queryParams, with: pathwayStep)
		
		let requestBuilder: RequestBuilder<ClientResponse>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .POST,
								   baseUrl: baseUrl,
								   path: .updateClient,
								   queryParams: queryParams,
								   body: bodyData(parameters: clientBuilder.toJSONValues())
		)
		.effect()
		.map(\.contact_id)
	}
    
	func merge(_ params: inout [String: Any], with pathwayStep: PathwayIdStepId?) {
		if let pathwayStep = pathwayStep {
			params["step_id"] = pathwayStep.step_id
			params["path_taken_id"] = pathwayStep.path_taken_id
		}
	}
	
    public func addNote(clientId: Client.Id, note: String) -> Effect<Note, RequestError> {
        Just(Note(id: 24214, content: note, date: Date()))
            .mapError { RequestError.unknown($0) }
			.eraseToEffect()
	}

    public func getAppointments(clientId: Client.Id) -> Effect<[CCAppointment], RequestError> {
		struct AppointmentResponse: Decodable {
            let appointments: [CCAppointment]
        }
        let requestBuilder: RequestBuilder<AppointmentResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClientsAppointmens,
                                   queryParams: commonAnd(other: ["id": "\(clientId)"]))
            .effect()
            .map(\.appointments)
            .eraseToEffect()
    }

    public func getServices() -> Effect<[Service], RequestError> {
        struct ServiceResponse: Codable {
            public let services: [Service]
            enum CodingKeys: String, CodingKey {
                case services = "employees"
            }
        }
        let requestBuilder: RequestBuilder<ServiceResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getServices,
                                   queryParams: commonParams()
		)
            .effect()
            .map(\.services)
            .eraseToEffect()
    }

    public func getPhotos(clientId: Client.Id) -> Effect<[SavedPhoto], RequestError> {
        struct PhotoResponse: Codable {
            public let photos: [SavedPhoto]
            enum CodingKeys: String, CodingKey {
                case photos = "employees"
            }
        }
        let requestBuilder: RequestBuilder<PhotoResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClientsPhotos,
                                   queryParams: commonAnd(other: [
                                    "contact_id": "\(clientId)"
                                   ])
		)
            .effect()
            .map(\.photos)
            .eraseToEffect()
    }
    
    public func addAlert(clientId: Client.Id, alert: String) -> Effect<Bool, RequestError> {
        struct AlertAddResponse: Codable {
            public let success: Bool
        }
        let requestBuilder: RequestBuilder<AlertAddResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .POST,
                                   baseUrl: baseUrl,
                                   path: .getClientAlerts,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)",
                                                                  "note": "\(alert)",
                                                                  "mode": "add"])
		)
            .effect()
            .map(\.success)
            .eraseToEffect()
    }

    public func getForms(type: FormType, clientId: Client.Id) -> Effect<[FilledFormData], RequestError> {
        struct FormDataResponse: Decodable {
            let forms: [FilledFormData]

            enum CodingKeys: String, CodingKey {
                case forms = "employees"
            }
        }
        let requestBuilder: RequestBuilder<FormDataResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getForms,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]))
            .effect()
			.map { $0.forms.filter { $0.templateType == type} }
            .eraseToEffect()
    }

    public func getDocuments(clientId: Client.Id) -> Effect<[Document], RequestError> {
        struct DocumentResponse: Codable {
            let documents: [Document]
            enum CodingKeys: String, CodingKey {
                case documents = "employees"
            }
        }
        let requestBuilder: RequestBuilder<DocumentResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getDocuments,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"])
		)
            .effect()
            .map(\.documents)
            .eraseToEffect()
    }

    public func getCommunications(clientId: Client.Id) -> Effect<[Communication], RequestError> {
        let requestBuilder: RequestBuilder<CommunicationResponse>.Type = requestBuilderFactory.getBuilder()
        struct CommunicationResponse: Codable {
            let communications: [Communication]
        }
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getCommunications,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"])
		)
            .effect()
            .map(\.communications)
            .eraseToEffect()
    }

    public func getNotes(clientId: Client.Id) -> Effect<[Note], RequestError> {
        let requestBuilder: RequestBuilder<NoteResponse>.Type = requestBuilderFactory.getBuilder()
        struct NoteResponse: Codable {
            public let notes: [Note]
            public enum CodingKeys: String, CodingKey {
                case notes = "employees"
            }
        }
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClientsNotes,
                                   queryParams: commonAnd(other: [
                                    "contact_id": "\(clientId)"
                                   ])
		)
            .effect()
            .map(\.notes)
            .eraseToEffect()
    }
    
    public func getAppointmentStatus() -> Effect<[AppointmentStatus], RequestError> {
        struct AppointmentStatusResponse: Decodable {
            let statuses: [AppointmentStatus]
        }
        
        let requestBuilder: RequestBuilder<AppointmentStatusResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getAppointmentsStatus,
            queryParams: commonParams()
        )
        .effect()
        .map(\.statuses)
    }
}
