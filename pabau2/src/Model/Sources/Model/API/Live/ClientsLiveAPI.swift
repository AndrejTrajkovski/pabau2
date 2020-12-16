import ComposableArchitecture

public struct ClientsLiveAPI: ClientsAPI, LiveAPI {
    public init () {}
    
    public var basePath: String = "https://virtserver.swaggerhub.com/Pa577/iOS/1.0.0/"
    
    public var route: String = "clients"
    
    public var requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
    
    public func getClients(search: String? = nil) -> Effect<Result<[Client], RequestError>, Never> {
        let URLString = basePath + route
        var url = URLComponents(string: URLString)
        
        var queryItems: [String: Any] = ["limit": 20, "offset": 0]
        
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
    
    #warning("FIX ME:")
    public func getItemsCount(
        clientId: Int
    ) -> Effect<Result<ClientItemsCount, RequestError>, Never> {
        let URLString = basePath + route
        
        let requestBuilder: RequestBuilder<ClientItemsCount>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getAppointments(
        clientId: Int
    ) -> EffectWithResult<[Appointment], RequestError> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[Appointment]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getPhotos(
        clientId: Int
    ) -> Effect<Result<[SavedPhoto], RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[SavedPhoto]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getFinancials(
        clientId: Int
    ) -> Effect<Result<[Financial], RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[Financial]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getForms(
        type: FormType,
        clientId: Int
    ) -> Effect<Result<[FormData], RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[FormData]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getDocuments(
        clientId: Int
    ) -> Effect<Result<[Document], RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[Document]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getCommunications(
        clientId: Int
    ) -> Effect<Result<[Communication], RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[Communication]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getAlerts(
        clientId: Int
    ) -> Effect<Result<[Alert], RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[Alert]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getNotes(
        clientId: Int
    ) -> Effect<Result<[Note], RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<[Note]>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func getPatientDetails(
        clientId: Int
    ) -> Effect<Result<PatientDetails, RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<PatientDetails>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
    
    public func post(
        patDetails: PatientDetails
    ) -> Effect<Result<PatientDetails, RequestError>, Never> {
        let URLString = basePath + route
        let requestBuilder: RequestBuilder<PatientDetails>.Type = requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(
            method: "GET",
            URLString: URLString,
            parameters: nil,
            isBody: false
        ).effect()
    }
}
