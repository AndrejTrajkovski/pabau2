import ComposableArchitecture
import Combine

public class APIClient: LoginAPI, JourneyAPI, ClientsAPI, FormAPI {
    
    public init(baseUrl: String, loggedInUser: User?) {
        self.baseUrl = baseUrl
        self.loggedInUser = loggedInUser
    }

    var baseUrl: String
    var forgotPwBaseUrl: String { baseUrl }
    
    var loggedInUser: User? = nil
	let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}
