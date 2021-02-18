import ComposableArchitecture
import Combine
import Overture

public class APIClient: LoginAPI, JourneyAPI, ClientsAPI, FormAPI {
	public func getTemplate(id: HTMLForm.ID) -> Effect<HTMLForm, RequestError> {
		struct GetTemplate: Codable {
			let form_template: [_FormTemplate]
		}
		let requestBuilder: RequestBuilder<GetTemplate>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getFormTemplateData,
								   queryParams: commonAnd(other: ["form_template_id": id.rawValue]),
								   isBody: false)
			.effect()
			.compactMap(\.form_template.first)
			.tryMap(HTMLFormBuilder.init(template:))
			.eraseToEffect()
			.map(HTMLForm.init(builder:))
			.print()
			.mapError { error in
				if let formError = error as? HTMLFormBuilderError {
					return RequestError.jsonDecoding(formError.description)
				} else {
					return error as? RequestError ?? .unknown
				}
			}
			.eraseToEffect()
	}
	
	public func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<HTMLForm, RequestError> {
		fatalError()
	}
	
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError> {
		struct GetTemplates: Codable {
			let templateList: [FormTemplateInfo]
		}
		let requestBuilder: RequestBuilder<GetTemplates>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getFormTemplates,
								   queryParams: commonAnd(other: ["form_template_type": type.rawValue]),
								   isBody: false)
			.effect()
			.map(\.templateList)
	}
	
    public init(baseUrl: String, loggedInUser: User?) {
        self.baseUrl = baseUrl
        self.loggedInUser = loggedInUser
    }

    var baseUrl: String = "https://crm.pabau.com"
    var loggedInUser: User? = nil
    let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}
