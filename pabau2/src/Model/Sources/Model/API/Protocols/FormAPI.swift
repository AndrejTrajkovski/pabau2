import ComposableArchitecture

public protocol FormAPI {
    func updateStepStatus(_ stepStatus: StepStatus, _ pathwayStep: PathwayIdStepId, _ clientId: Client.ID, _ appointmentId: Appointment.ID) -> Effect<StepStatus, RequestError>
    func skipStep(_ pathwayStep: PathwayIdStepId, _ clientId: Client.ID, _ appointmentId: Appointment.ID) -> Effect<StepStatus, RequestError>
    func save(form: HTMLForm, clientId: Client.ID, pathwayStep: PathwayIdStepId?) -> Effect<FilledFormData.ID, RequestError>
    func getForm(templateId: FormTemplateInfo.ID,
                 entryId: FilledFormData.ID?) -> Effect<HTMLForm, RequestError>
    func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError>
    func updateProfilePic(image: Data, clientId: Client.ID) -> Effect<VoidAPIResponse, RequestError>
    
    func uploadEpaperImages(images: [Data], params: [String: String]) -> Effect<VoidAPIResponse, RequestError>
    func uploadEpaperImage(image: Data, params: [String: String]) -> Effect<VoidAPIResponse, RequestError>
    func uploadClientEditedImage(image: Data, params: [String: String]) -> Effect<VoidAPIResponse, RequestError>
    func getPatientDetails(clientId: Client.Id) -> Effect<Client, RequestError>
    func update(clientBuilder: ClientBuilder, pathwayStep: PathwayIdStepId?) -> Effect<Client.ID, RequestError>
//    func getAftercare(_ appointmentId: Appointment.ID) -> 
}
