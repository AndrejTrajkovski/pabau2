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
	
	public func get(form: HTMLForm.ID) -> Effect<Result<HTMLForm, RequestError>, Never> {
		fatalError("TODO ANDREJ")
	}
	
	public func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<Result<HTMLForm, RequestError>, Never> {
		fatalError("TODO ANDREJ")
	}
	
	public func getTemplates(_ type: FormType) -> Effect<Result<[HTMLForm], RequestError>, Never> {
		struct GetTemplates: Codable {
			let templateList: 
		}
		let requestBuilder: RequestBuilder<GetEmployees>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getFormTemplates,
								   queryParams: commonAnd(other: [:]),
								   isBody: false)
			.effect()
			.map(\.employees)
			.eraseToEffect()
	}

}
