import ComposableArchitecture
//MARK: - LoginAPI: ClientApi
extension APIClient {
    public func getClients(search: String?, offset: Int) -> Effect<[Client], RequestError> {
        let requestBuilder: RequestBuilder<ClientResponse>.Type = requestBuilderFactory.getBuilder()
        struct ClientResponse: Codable, Equatable {
            public let clients: [Client]
            public enum CodingKeys: String, CodingKey {
                case clients = "appointments"
            }
        }

        var queryItems: [String: Any] = ["limit": 20, "offset": offset]

        if let search = search {
            queryItems["searchText"] = search
        }

        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: commonAnd(other: queryItems),
                                   isBody: false)
            .effect()
            .map(\.clients)
            .eraseToEffect()
    }

    public func getItemsCount(clientId: Client.ID) -> Effect<ClientItemsCount, RequestError> {
        Effect(value: ClientItemsCount.init(id: 1, appointments: 2, photos: 4, financials: 6, treatmentNotes: 3, presriptions: 10, documents: 15, communications: 123, consents: 4381, alerts: 123, notes: 0))
            .eraseToEffect()
    }

    public func getAppointments(clientId: Int) -> Effect<[Appointment], RequestError> {
        struct AppointmentResponse: Codable {
            let appointments: [Appointment]
        }
        let requestBuilder: RequestBuilder<AppointmentResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClientsAppointmens,
                                   queryParams: commonAnd(other: ["id": "\(clientId)"]),
                                   isBody: false)
            .effect()
            .map(\.appointments)
            .eraseToEffect()
    }

    public func getPhotos(clientId: Int) -> Effect<[SavedPhoto], RequestError> {
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
                                   ]),
                                   isBody: false)
            .effect()
            .map(\.photos)
            .eraseToEffect()
    }

    public func getFinancials(clientId: Int) -> Effect<[Financial], RequestError> {
        struct FinancialResponse: Codable {
            let sales: [Financial]
        }
        let requestBuilder: RequestBuilder<FinancialResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getFinancials,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]),
                                   isBody: false)
            .effect()
            .map(\.sales)
            .eraseToEffect()
    }

    public func getForms(type: FormType, clientId: Int) -> Effect<[FilledFormData], RequestError> {
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
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]),
                                   isBody: false)
            .effect()
			.map { $0.forms.filter { $0.templateInfo.type == type} }
            .eraseToEffect()
    }

    public func getDocuments(clientId: Int) -> Effect<[Document], RequestError> {
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
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]),
                                   isBody: false)
            .effect()
            .map(\.documents)
            .eraseToEffect()
    }

    public func getCommunications(clientId: Int) -> Effect<[Communication], RequestError> {
        let requestBuilder: RequestBuilder<CommunicationResponse>.Type = requestBuilderFactory.getBuilder()
        struct CommunicationResponse: Codable {
            let communications: [Communication]
        }
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getCommunications,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]),
                                   isBody: false)
            .effect()
            .map(\.communications)
            .eraseToEffect()
    }

    public func getAlerts(clientId: Int) -> Effect<[Alert], RequestError> {
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
                                   ]),
                                   isBody: false)
            .effect()
            .map(\.medical_alerts)
            .eraseToEffect()
    }

    public func getNotes(clientId: Int) -> Effect<[Note], RequestError> {
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
                                   ]),
                                   isBody: false)
            .effect()
            .map(\.notes)
            .eraseToEffect()
    }

    public func getPatientDetails(clientId: Int) -> Effect<PatientDetails, RequestError> {
        struct PatientDetailsResponse: Codable {
            let details: [PatientDetails]
            enum CodingKeys: String, CodingKey {
                case details = "appointments"
            }
        }
        let requestBuilder: RequestBuilder<PatientDetailsResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getPatientDetails,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]),
                                   isBody: false)
            .effect()
            .map(\.details)
            .tryMap {
                if let first = $0.first {
                    return first
                } else {
                    throw RequestError.apiError("No Patient Details found")
                }
            }
            .mapError { $0 as? RequestError ?? RequestError.unknown }
            .eraseToEffect()
    }

    public func post(patDetails: PatientDetails) -> Effect<PatientDetails, RequestError> {
        fatalError("TODO Cristian")
    }
}
