import ComposableArchitecture

public struct JourneyLiveAPI: JourneyAPI, LiveAPI, MockAPI {
    
    public let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
    public var basePath: String = "https://virtserver.swaggerhub.com/Pa577/iOS/1.0.0/"
    public let route: String = "journey"
    public let clients: String = "clients"
    
    public init () {}

	public func getEmployees() -> Effect<Result<[Employee], RequestError>, Never> {
        getEmployees(companyID: 1).effect()
	}

	public func getTemplates(_ type: FormType) -> Effect<Result<[FormTemplate], RequestError>, Never> {
        switch type {
        case .consent:
            return mockSuccess(FormTemplate.mockConsents, delay: 0.1)
        case .treatment:
            return mockSuccess(FormTemplate.mockTreatmentN, delay: 0.1)
        default:
            fatalError("TODO")
        }
	}

    public func getJourneys(date: Date, searchTerm: String?) -> Effect<Result<[Journey], RequestError>, Never> {
		getJourneys(date: date, searchTerm: searchTerm).effect()
	}
	
    public func getClients(search: String? = nil, offset: Int) -> Effect<Result<[Client], RequestError>, Never> {
        let URLString = basePath + clients
        var url = URLComponents(string: URLString)
        
        var queryItems: [String: Any] = ["limit": 20, "offset": offset]
        
        if let search = search {
            queryItems["search"] = search
        }
        
        url?.queryItems = APIHelper.mapValuesToQueryItems(queryItems)
        
        let requestBuilder: RequestBuilder<[Client]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: url?.string ?? URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }

    private func getJourneys(date: Date, searchTerm: String?) -> RequestBuilder<[Journey]> {
		let URLString = basePath + "journeys"
		let parameters: [String: Any]? = nil
		var url = URLComponents(string: URLString)
		url?.queryItems = APIHelper.mapValuesToQueryItems([
            "date": DateFormatter.yearMonthDay.string(from: date),
            "searchTerm": searchTerm
		])

		let requestBuilder: RequestBuilder<[Journey]>.Type = requestBuilderFactory.getBuilder()

		return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	}

    public func getServices() -> Effect<Result<[Service], RequestError>, Never> {
        let URLString = basePath + "services"
        let parameters: [String: Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "company_id": 1,
            "employee_id": 1
        ])
        
        let requestBuilder: RequestBuilder<[Service]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: (url?.string ?? URLString),
            parameters: parameters,
            isBody: false
        ).effect()
    }

    private func getEmployees(companyID: Int) -> RequestBuilder<[Employee]> {
        let URLString = basePath + "employees"
        let parameters: [String: Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "company_id": companyID
        ])

        let requestBuilder: RequestBuilder<[Employee]>.Type = requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
}
