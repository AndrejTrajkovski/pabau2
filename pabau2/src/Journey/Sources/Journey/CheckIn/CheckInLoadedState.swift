import Model
import ComposableArchitecture
import Overture
import Util
import Form
import ChoosePathway

public struct CheckInLoadedState: Equatable {
	
	public var appointment: Appointment
	public let pathway: Pathway
	public let pathwayTemplate: PathwayTemplate
	
    public var patientCheckIn: CheckInPathwayState
    public var doctorCheckIn: CheckInPathwayState
    
    var isHandBackDeviceActive: Bool = false
	
    var passcodeForDoctorMode: PasscodeState?
	var isDoctorCheckInMainActive: Bool = false
}

public enum CheckInLoadedAction: Equatable {
    case didTouchHandbackDevice
    case patient(CheckInPathwayAction)
    case doctor(CheckInPathwayAction)
    case passcodeForDoctorMode(PasscodeAction)
}

extension CheckInLoadedState {
	
	public init(appointment: Appointment,
				pathway: Pathway,
				template: PathwayTemplate) {
		self.appointment = appointment
		self.pathway = pathway
		self.pathwayTemplate = template
		let patientStepStates = stepsAndEntries(pathway, template, .patient).map {
            StepState.init(stepAndEntry: $0, clientId: appointment.customerId, pathwayId: pathway.id, appointmentId: appointment.id)
		}
        
        self.patientCheckIn = CheckInPathwayState(appointment: appointment,
                                                  pathway: pathway,
                                                  pathwayTemplate: pathwayTemplate,
                                                  stepStates: patientStepStates)
		let doctorStepStates = stepsAndEntries(pathway, pathwayTemplate, .doctor).map {
            StepState.init(stepAndEntry: $0, clientId: appointment.customerId, pathwayId: pathway.id, appointmentId: appointment.id)
		}
        self.doctorCheckIn = CheckInPathwayState(appointment: appointment,
                                                 pathway: pathway,
                                                 pathwayTemplate: pathwayTemplate,
                                                 stepStates: doctorStepStates)
	}
}

let pipeToPatientAction = pipe(CheckInPathwayAction.steps,
                                 CheckInLoadedAction.patient,
                                 CheckInContainerAction.loaded)

let pipeToDoctorAction = pipe(CheckInPathwayAction.steps,
                              CheckInLoadedAction.doctor)

func toActions<Action>(_ pipeToAction: @escaping (StepsActions) -> Action, stepsActions: [Effect<StepsActions, Never>]) -> [Effect<Action, Never>] {
    return stepsActions.map { $0.map(pipeToAction) }
}

func toLoadedActions(stepsActions: [Effect<StepsActions, Never>]) -> [Effect<CheckInLoadedAction, Never>] {
    return toActions(pipeToDoctorAction, stepsActions: stepsActions)
}

func toCheckContainerAction(stepsActions: [Effect<StepsActions, Never>]) -> [Effect<CheckInContainerAction, Never>] {
    return toActions(pipeToPatientAction, stepsActions: stepsActions)
}

let getFormsForPathway = uncurry(pipe(stepsAndEntries(_:_:_:), curry(getForms(stepsAndEntries:formAPI:clientId:appId:pathwayId:))))

let getCheckInFormsForPathway = pipe(getFormsForPathway, toCheckContainerAction(stepsActions:))
let getLoadedActionsFormsForPathway = pipe(getFormsForPathway, toLoadedActions(stepsActions:))

func getLoadedActionsOneAfterAnother(_ pathway: Pathway,
                                     _ template: PathwayTemplate,
                                     _ journeyMode: JourneyMode,
                                     _ formAPI: FormAPI,
                                     _ clientId: Client.ID,
                                     _ appId: Appointment.ID) -> Effect<CheckInLoadedAction, Never> {
    let effects = with(((pathway, template, journeyMode), formAPI, clientId, appId, pathway.id), getLoadedActionsFormsForPathway)
    return Effect.concatenate(effects)
}

public func getCheckInFormsOneAfterAnother(pathway: Pathway,
                                           template: PathwayTemplate,
                                           journeyMode: JourneyMode,
                                           formAPI: FormAPI,
                                           clientId: Client.ID,
                                           appId: Appointment.ID) -> Effect<CheckInContainerAction, Never> {
    let effects = with(((pathway, template, journeyMode), formAPI, clientId, appId, pathway.id), getCheckInFormsForPathway)
    return Effect.concatenate(effects)
}

//func getCheckInForms(loadedState: CheckInLoadedState) ->

public func stepsAndEntries(_ pathway: Pathway, _ template: PathwayTemplate, _ journeyMode: JourneyMode) -> [StepAndStepEntry] {
    print("here")
    print(pathway, template)
	return template.steps
		.filter { isIn(journeyMode, $0.stepType) }
		.map { StepAndStepEntry(step: $0, entry: pathway.stepEntries[$0.id]) }
}

func getForms(stepsAndEntries: [StepAndStepEntry], formAPI: FormAPI, clientId: Client.ID, appId: Appointment.ID, pathwayId: Pathway.ID) -> [Effect<StepsActions, Never>] {
	let stepActions: [Effect<StepsActions, Never>] = stepsAndEntries.indices.compactMap { idx in
			let stepAndEntry = stepsAndEntries[idx]
        if let getForm = getForm(pathwayId,
                                 stepAndEntry.step.id,
                                 stepAndEntry.step.stepType,
                                 stepAndEntry.entry?.htmlFormInfo?.chosenFormTemplateId,
                                 stepAndEntry.entry?.htmlFormInfo?.formEntryId,
                                 formAPI,
                                 clientId,
                                 appId
        ) {
                return getForm.map { StepsActions.steps(idx: idx, action: StepAction.stepType($0)) }
			} else {
				return nil
			}
		}
	return stepActions
}

func getForm(_ pathwayId: Pathway.ID, _ stepId: Step.ID, _ stepType: StepType, _ chosenFormTemplateId: HTMLForm.ID?, _ formEntryId: FilledFormData.ID?, _ formAPI: FormAPI, _ clientId: Client.ID, _ appId:  Appointment.ID) -> Effect<StepBodyAction, Never>? {
    switch stepType {
    case .consents, .medicalhistory, .treatmentnotes, .prescriptions:
        guard let templateToGet = chosenFormTemplateId else {
            return nil
        }
        
        let pipeInits: (Result<HTMLForm, RequestError>) -> StepBodyAction = pipe(HTMLFormAction.gotForm, HTMLFormStepContainerAction.chosenForm, StepBodyAction.htmlForm)
        
        return formAPI.getForm(templateId: templateToGet, entryId: formEntryId)
            .catchToEffect()
            .map(pipeInits)
        
    case .patientdetails:
        return formAPI.getPatientDetails(clientId: clientId)
            .catchToEffect()
            .map { $0.map(ClientBuilder.init(client:))}
            .map(pipe(PatientDetailsParentAction.gotGETResponse, StepBodyAction.patientDetails))
    case .aftercares:
        return formAPI.getAftercareAndRecall(appointmentId: appId)
            .catchToEffect()
            .map(pipe(AftercareAction.gotAftercareAndRecallsResponse, StepBodyAction.aftercare))
            .eraseToEffect()
    case .photos:
        return formAPI.getPhotos(pathwayId: pathwayId, stepId: stepId)
            .catchToEffect()
            .map(pipe(PhotosFormAction.gotStepPhotos, StepBodyAction.photos))
            .eraseToEffect()
    case .lab:
        return nil
    case .video:
        return nil
    case .timeline:
        return nil
    }
}
