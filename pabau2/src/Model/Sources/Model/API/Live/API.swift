import ComposableArchitecture
import Combine

public class APIClient: LoginAPI, JourneyAPI, ClientsAPI, FormAPI {
	
    public init(baseUrl: String, loggedInUser: User?) {
        self.baseUrl = baseUrl
        self.loggedInUser = loggedInUser
    }

    var baseUrl: String = "https://crm.pabau.com"
    var loggedInUser: User? = nil
	let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}
