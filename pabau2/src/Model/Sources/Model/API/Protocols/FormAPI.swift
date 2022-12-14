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
    func uploadEpaperImage(image: Data, queryParams: [String: String]) -> Effect<VoidAPIResponse, RequestError>
    func getPatientDetails(clientId: Client.Id) -> Effect<Client, RequestError>
    func update(clientBuilder: ClientBuilder, pathwayStep: PathwayIdStepId?) -> Effect<Client.ID, RequestError>
    func getAftercareAndRecall(appointmentId: Appointment.ID) -> Effect<AftercareAndRecalls, RequestError>
    func saveAftercareForm(_ bookingId: Appointment.ID,
                           _ pathwayIdStepId: PathwayIdStepId,
                           _ clientId: Client.ID,
                           _ selectedAftercareIds: [AftercareTemplate.ID],
                           _ selectedRecallIds: [AftercareTemplate.ID],
                           _ profilePicId: SavedPhoto.ID?,
                           _ sharePicId: SavedPhoto.ID?) -> Effect<StepStatus, RequestError>
    
    //    func uploadImages(uploads: [PhotoUpload],
    //                      pathwayIdStepId: PathwayIdStepId) -> [Effect<VoidAPIResponse, RequestError>]
    func uploadImage(upload: PhotoUpload,
                     pathwayIdStepId: PathwayIdStepId) -> Effect<SavedPhoto, RequestError>
    func getPhotos(pathwayId: Pathway.ID, stepId: Step.ID) -> Effect<[SavedPhoto], RequestError>
}
