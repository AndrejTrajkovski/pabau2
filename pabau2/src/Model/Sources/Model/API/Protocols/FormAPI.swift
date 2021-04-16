import ComposableArchitecture

public protocol FormAPI {
	func save(form: HTMLForm, clientId: Client.ID) -> Effect<FilledFormData.ID, RequestError>
	func getForm(templateId: FormTemplateInfo.ID) -> Effect<HTMLForm, RequestError>
	func getForm(templateId: FormTemplateInfo.ID, entryId: FilledFormData.ID) -> Effect<HTMLForm, RequestError>
	func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<HTMLForm, RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError>
	func updateProfilePic(image: Data, clientId: Client.ID) -> Effect<VoidAPIResponse, RequestError>
    
    func uploadEpaperImages(images: [Data], params: [String: String]) -> Effect<VoidAPIResponse, RequestError>
    func uploadEpaperImage(image: Data, params: [String: String]) -> Effect<VoidAPIResponse, RequestError>
    func uploadClientEditedImage(image: Data, params: [String: String]) -> Effect<VoidAPIResponse, RequestError>
}
